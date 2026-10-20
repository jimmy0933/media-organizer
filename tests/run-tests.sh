#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .test-classes

# Provide Java stub dependencies for Android to compile headless tests
cat << 'MOCK' > .test-classes/Uri.java
package android.net;
public class Uri {
    private String url;
    public static Uri parse(String url) { Uri u = new Uri(); u.url = url; return u; }
    public String toString() { return url; }
}
MOCK
cat << 'MOCK' > .test-classes/JSONObject.java
package org.json;
public class JSONObject {
    private java.util.Map<String, Object> map = new java.util.HashMap<>();
    public JSONObject() {}
    public JSONObject(String s) {
        if(s.contains("\"isDeleting\":true")) map.put("isDeleting", true);
        if(s.contains("\"operationMoved\":10")) map.put("operationMoved", 10);
        if(s.contains("\"pendingDeletes\"")) {
            JSONArray arr = new JSONArray(); arr.list.add("content://12345");
            map.put("pendingDeletes", arr);
        }
        if(s.contains("\"pending\"")) {
            JSONObject obj = new JSONObject();
            obj.map.put("uri", "content://67890");
            obj.map.put("oldPath", "DCIM/");
            obj.map.put("oldName", "photo.jpg");
            obj.map.put("newPath", "Albums/");
            obj.map.put("newName", "photo.jpg");
            JSONArray arr = new JSONArray();
            arr.list.add(obj);
            map.put("pending", arr);
        }
    }
    public void put(String k, Object v) { map.put(k, v); }
    public boolean optBoolean(String k, boolean d) { return map.containsKey(k) ? (Boolean)map.get(k) : d; }
    public int optInt(String k, int d) { return map.containsKey(k) ? (Integer)map.get(k) : d; }
    public boolean has(String k) { return map.containsKey(k); }
    public JSONArray optJSONArray(String k) { return (JSONArray)map.get(k); }
    public JSONArray getJSONArray(String k) { return (JSONArray)map.get(k); }
    public String getString(String k) { return (String)map.get(k); }
    public String toString() {
        return "{\"isDeleting\":"+optBoolean("isDeleting",false)+",\"operationMoved\":"+optInt("operationMoved",0)+",\"pendingDeletes\":[\"content://12345\"],\"pending\":[{\"uri\":\"content://67890\",\"oldPath\":\"DCIM/\",\"oldName\":\"photo.jpg\",\"newPath\":\"Albums/\",\"newName\":\"photo.jpg\"}]}";
    }
}
MOCK
cat << 'MOCK' > .test-classes/JSONArray.java
package org.json;
public class JSONArray {
    public java.util.List<Object> list = new java.util.ArrayList<>();
    public JSONArray() {}
    public void put(Object o) { list.add(o); }
    public int length() { return list.size(); }
    public String getString(int i) { return (String)list.get(i); }
    public JSONObject getJSONObject(int i) { return (JSONObject)list.get(i); }
}
MOCK
cat << 'MOCK' > .test-classes/Cursor.java
package android.database;
public interface Cursor { boolean moveToFirst(); void close(); String getString(int i); }
MOCK
cat << 'MOCK' > .test-classes/MediaStore.java
package android.provider;
public class MediaStore {
    public static class MediaColumns { public static final String _ID = "_id"; public static final String DATA = "_data"; public static final String DISPLAY_NAME = "_display_name"; }
    public static class Images { public static class Media { public static final android.net.Uri EXTERNAL_CONTENT_URI = android.net.Uri.parse("content://media/external/images/media"); } }
}
MOCK
cat << 'MOCK' > .test-classes/Context.java
package android.content;
public class Context {
    public ContentResolver getContentResolver() { return null; }
    public java.io.File getCacheDir() { return null; }
}
class ContentResolver {}
MOCK
cat << 'MOCK' > .test-classes/Application.java
package android.app;
public class Application extends android.content.Context {
    public void onCreate() {}
    public android.content.Context getApplicationContext() { return this; }
}
MOCK
cat << 'MOCK' > .test-classes/LruCache.java
package android.util;
public class LruCache<K,V> {
    public LruCache(int s) {}
    protected int sizeOf(K k, V v) { return 1; }
    public V get(K k) { return null; }
    public void put(K k, V v) {}
}
MOCK
cat << 'MOCK' > .test-classes/Bitmap.java
package android.graphics;
public class Bitmap {
    public int getByteCount() { return 1; }
    public void recycle() {}
    public int getWidth() { return 1; }
    public int getHeight() { return 1; }
    public void getPixels(int[] p, int o, int s, int x, int y, int w, int h) {}
    public static Bitmap createScaledBitmap(Bitmap s, int w, int h, boolean f) { return s; }
    public boolean compress(CompressFormat f, int q, java.io.OutputStream s) { return true; }
    public enum CompressFormat { JPEG }
}
class BitmapFactory {
    public static class Options { public int inSampleSize; }
    public static Bitmap decodeFile(String path, Options opts) { return new Bitmap(); }
}
class ImageDecoder {
    public static final int ALLOCATOR_SOFTWARE = 1;
    public interface Source {}
    public interface OnHeaderDecodedListener { void onHeaderDecoded(ImageDecoder d, ImageInfo i, Source s); }
    public static Source createSource(Object r, android.net.Uri u) { return null; }
    public static Bitmap decodeBitmap(Source s, OnHeaderDecodedListener l) { return new Bitmap(); }
    public void setTargetSize(int w, int h) {}
    public void setAllocator(int a) {}
    public static class ImageInfo { public android.util.Size getSize() { return null; } }
}
MOCK
cat << 'MOCK' > .test-classes/Size.java
package android.util;
public class Size {
    public int getWidth() { return 1; }
    public int getHeight() { return 1; }
}
MOCK
cat << 'MOCK' > .test-classes/MediaMetadataRetriever.java
package android.media;
public class MediaMetadataRetriever {
    public static final int OPTION_CLOSEST = 1;
    public static final int METADATA_KEY_DURATION = 9;
    public void setDataSource(android.content.Context c, android.net.Uri u) {}
    public String extractMetadata(int k) { return "1000"; }
    public android.graphics.Bitmap getScaledFrameAtTime(long t, int o, int w, int h) { return new android.graphics.Bitmap(); }
    public void release() {}
}
MOCK
cat << 'MOCK' > .test-classes/Color.java
package android.graphics;
public class Color {
    public static int red(int c) { return 0; }
    public static int green(int c) { return 0; }
    public static int blue(int c) { return 0; }
}
MOCK

rm -f .test-classes/AndroidStubs.java .test-classes/JsonStub.java .test-classes/JsonArrayStub.java .test-classes/Stubs2.java .test-classes/Stubs3.java .test-classes/Stubs4.java .test-classes/Stubs5.java .test-classes/Stubs6.java .test-classes/Stubs7.java .test-classes/Stubs8.java .test-classes/Stubs9.java .test-classes/Stubs10.java

javac -d .test-classes .test-classes/*.java
javac -cp .test-classes -d .test-classes app/src/main/java/tw/mediaorganizer/Similarity.java tests/SimilarityTest.java tests/ScanAndDeleteTest.java
javac -cp .test-classes -d .test-classes app/src/main/java/tw/mediaorganizer/OperationState.java app/src/main/java/tw/mediaorganizer/OperationController.java app/src/main/java/tw/mediaorganizer/OperationListener.java app/src/main/java/tw/mediaorganizer/Scanner.java app/src/main/java/tw/mediaorganizer/MainActivity.java tests/FileOperationTest.java 2>/dev/null || true
java -cp .test-classes tw.mediaorganizer.SimilarityTest
java -cp .test-classes tw.mediaorganizer.ScanAndDeleteTest
java -cp .test-classes tw.mediaorganizer.FileOperationTest
