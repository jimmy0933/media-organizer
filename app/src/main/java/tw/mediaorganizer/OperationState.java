package tw.mediaorganizer;

import android.net.Uri;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class OperationState {
    public boolean isDeleting = false, undoing = false, operationHasSuccess = false, fileBusy = false;
    public int operationMoved = 0, operationFailed = 0, operationDeleted = 0, operationDeleteFailed = 0;
    public String destination = null;
    public List<Scanner.Item> pendingDeletes = null;
    public List<MainActivity.MoveRecord> pending = null;

    public void save(File dir, OperationController op) throws Exception {
        File temp = new File(dir, "op-state-temp.json");
        File f = new File(dir, "op-state.json");
        JSONObject root = new JSONObject();
        root.put("isDeleting", op.state.isDeleting);
        root.put("undoing", op.state.undoing);
        root.put("operationHasSuccess", op.state.operationHasSuccess);
        root.put("operationMoved", op.state.operationMoved);
        root.put("operationFailed", op.state.operationFailed);
        root.put("operationDeleted", op.state.operationDeleted);
        root.put("operationDeleteFailed", op.state.operationDeleteFailed);
        if (op.state.pendingDeletes != null && !op.state.pendingDeletes.isEmpty()) {
            JSONArray deletes = new JSONArray();
            for (Scanner.Item i : op.state.pendingDeletes) deletes.put(i.uri.toString());
            root.put("pendingDeletes", deletes);
        }
        if (op.state.pending != null && !op.state.pending.isEmpty()) {
            JSONArray moves = new JSONArray();
            for (MainActivity.MoveRecord r : op.state.pending) {
                JSONObject obj = new JSONObject();
                obj.put("uri", r.uri.toString());
                obj.put("oldPath", r.oldPath);
                obj.put("oldName", r.oldName);
                obj.put("newPath", r.newPath);
                obj.put("newName", r.newName);
                moves.put(obj);
            }
            root.put("pending", moves);
        }
        try (FileOutputStream out = new FileOutputStream(temp)) {
            out.write(root.toString().getBytes("UTF-8"));
            out.getFD().sync();
        }
        if (!temp.renameTo(f)) {
            temp.delete();
            throw new java.io.IOException("Failed to rename temp file to op-state.json");
        }
    }

    public void load(File dir, OperationController op) throws Exception {
        File f = new File(dir, "op-state.json");
        if (!f.exists()) return;
        try (InputStream in = new FileInputStream(f)) {
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            byte[] b = new byte[4096]; int n;
            while ((n = in.read(b)) > 0) out.write(b, 0, n);
            JSONObject root = new JSONObject(out.toString("UTF-8"));

            // Upgrade/legacy fallback support
            op.state.isDeleting = root.optBoolean("isDeleting", root.optBoolean("op().isDeleting", false));
            op.state.undoing = root.optBoolean("undoing", root.optBoolean("op().undoing", false));
            op.state.operationHasSuccess = root.optBoolean("operationHasSuccess", root.optBoolean("op().operationHasSuccess", false));
            op.state.operationMoved = root.optInt("operationMoved", root.optInt("op().operationMoved", 0));
            op.state.operationFailed = root.optInt("operationFailed", root.optInt("op().operationFailed", 0));
            op.state.operationDeleted = root.optInt("operationDeleted", root.optInt("op().operationDeleted", 0));
            op.state.operationDeleteFailed = root.optInt("operationDeleteFailed", root.optInt("op().operationDeleteFailed", 0));

            JSONArray deletes = root.optJSONArray("pendingDeletes");
            if (deletes == null && root.has("op().pendingDeletes")) {
                deletes = root.getJSONArray("op().pendingDeletes");
            }
            if (deletes != null) {
                op.state.pendingDeletes = new ArrayList<>();
                for (int i = 0; i < deletes.length(); i++) {
                    Scanner.Item item = new Scanner.Item();
                    item.uri = Uri.parse(deletes.getString(i));
                    op.state.pendingDeletes.add(item);
                }
                if (op.state.pendingDeletes.isEmpty()) { op.state.pendingDeletes = null; } else { op.state.fileBusy = true; }
            }

            JSONArray moves = root.optJSONArray("pending");
            if (moves == null && root.has("op().pending")) {
                moves = root.getJSONArray("op().pending");
            }
            if (moves != null) {
                op.state.pending = new ArrayList<>();
                for (int i = 0; i < moves.length(); i++) {
                    JSONObject o = moves.getJSONObject(i);
                    MainActivity.MoveRecord r = new MainActivity.MoveRecord();
                    r.uri = Uri.parse(o.getString("uri"));
                    r.oldPath = o.getString("oldPath");
                    r.oldName = o.getString("oldName");
                    r.newPath = o.getString("newPath");
                    r.newName = o.getString("newName");
                    op.state.pending.add(r);
                }
                if (op.state.pending.isEmpty()) { op.state.pending = null; } else { op.state.fileBusy = true; }
            }
        }
    }
}
