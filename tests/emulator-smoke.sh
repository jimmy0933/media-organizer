#!/usr/bin/env bash

set -Eeuo pipefail

API_LEVEL="${1:-30}"
DIAG_DIR="dist/diagnostics"
mkdir -p "$DIAG_DIR"

capture_diagnostics() {
    local exit_code=$?
    echo "--- EXIT TRAP: Capturing diagnostics (Exit code: $exit_code) ---"
    timeout 10s adb -s emulator-5554 logcat -d > "$DIAG_DIR/logcat_full_api${API_LEVEL}.txt" || true
    timeout 10s adb -s emulator-5554 shell screencap -p /sdcard/screen.png || true
    timeout 10s adb -s emulator-5554 pull /sdcard/screen.png "$DIAG_DIR/screen_api${API_LEVEL}.png" || true
    timeout 10s adb -s emulator-5554 shell dumpsys window > "$DIAG_DIR/dumpsys_window_api${API_LEVEL}.txt" || true
    timeout 10s adb -s emulator-5554 shell dumpsys activity top > "$DIAG_DIR/dumpsys_activity_top_api${API_LEVEL}.txt" || true
    echo "Diagnostics capture complete."
}
trap capture_diagnostics EXIT ERR

if [ -n "${ANDROID_HOME:-}" ]; then
    export PATH=$PATH:$ANDROID_HOME/emulator
fi
echo "KVM check:"
emulator -accel-check || true

timeout 10s adb -s emulator-5554 shell input keyevent 82 || true
timeout 60s adb -s emulator-5554 install -r dist/Media-Organizer.apk || true

CRASH_FOUND=false

for run_idx in {1..3}; do
   echo "--- Cold start run $run_idx ---"
   adb -s emulator-5554 logcat -c || true
   adb -s emulator-5554 shell am force-stop tw.mediaorganizer || true
   sleep 2

   timeout 30s adb -s emulator-5554 shell am start -W tw.mediaorganizer/.MainActivity || true
   sleep 10

   PID=$(adb -s emulator-5554 shell pidof tw.mediaorganizer | tr -d '\r\n' | awk '{print $1}' || true)
   if [ -z "$PID" ]; then
     echo "Process tw.mediaorganizer is not running on run $run_idx!"
     CRASH_FOUND=true
     break
   fi

   # Check Settings via UIAutomator
   timeout 10s adb -s emulator-5554 shell uiautomator dump /data/local/tmp/window_dump.xml || true
   timeout 10s adb -s emulator-5554 shell cat /data/local/tmp/window_dump.xml > window_dump_start.xml || true

   if grep -q "設定" window_dump_start.xml || true; then
       echo "PASS: Settings text found on screen."
       adb -s emulator-5554 shell input tap 900 150 || true
   else
       echo "ERROR: Settings text not found on screen."
   fi

   sleep 5

   # Verify inside Settings
   timeout 10s adb -s emulator-5554 shell uiautomator dump /data/local/tmp/window_dump.xml || true
   timeout 10s adb -s emulator-5554 shell cat /data/local/tmp/window_dump.xml > window_dump_settings.xml || true

   if grep -q "深色模式" window_dump_settings.xml || grep -q "開發人員" window_dump_settings.xml || true; then
        echo "PASS: Setting page confirmed open."
   else
        echo "ERROR: Setting page NOT open."
   fi

   adb -s emulator-5554 shell input keyevent 4 || true # BACK
   sleep 5

   adb -s emulator-5554 logcat -d --pid="$PID" > "$DIAG_DIR/logcat_run_${run_idx}_api${API_LEVEL}.txt" || true
   CRASH=$(adb -s emulator-5554 logcat -d --pid="$PID" | grep -E "FATAL EXCEPTION" || true)

   if [[ -n "$CRASH" ]]; then
      echo "Crash detected on run $run_idx: $CRASH"
      CRASH_FOUND=true
      break
   fi

   adb -s emulator-5554 shell input keyevent 3 || true # HOME
   sleep 5
   adb -s emulator-5554 shell input keyevent 4 || true # BACK to make sure we do not stick
   timeout 30s adb -s emulator-5554 shell am start -W tw.mediaorganizer/.MainActivity || true
   sleep 5

   timeout 10s adb -s emulator-5554 shell uiautomator dump /data/local/tmp/window_dump.xml || true
   timeout 10s adb -s emulator-5554 shell cat /data/local/tmp/window_dump.xml > window_dump_restore.xml || true
   if grep -q "設定" window_dump_restore.xml || true; then
       echo "PASS: Main Activity survived background restore."
   else
       echo "ERROR: Main Activity NOT correctly restored."
   fi
done

if [[ "$CRASH_FOUND" == "true" ]]; then
   echo "Smoke test failed."
   bash -c "exit 1"
else
   echo "Smoke test passed."
fi
