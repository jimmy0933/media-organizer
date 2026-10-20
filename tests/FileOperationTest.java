package tw.mediaorganizer;

import java.io.File;
import android.net.Uri;

public class FileOperationTest {
    public static void testOpStateSerialization() {
        try {
            File dir = new File(".");
            OperationState state = new OperationState();
            state.isDeleting = true;
            state.operationMoved = 10;
            state.pendingDeletes = new java.util.ArrayList<>();
            Scanner.Item item = new Scanner.Item();
            item.uri = Uri.parse("content://12345");
            state.pendingDeletes.add(item);

            MainActivity.MoveRecord move = new MainActivity.MoveRecord();
            move.uri = Uri.parse("content://67890");
            move.oldPath = "DCIM/";
            move.oldName = "photo.jpg";
            move.newPath = "Albums/";
            move.newName = "photo.jpg";
            state.pending = new java.util.ArrayList<>();
            state.pending.add(move);

            // This test is headless, so we bypass actual SQLite cursor verification via mock / logic testing.
            // Since OperationState.load does not have context, we must test its JSON fields.
            OperationController op = OperationController.getInstance();
            op.state.isDeleting = state.isDeleting;
            op.state.operationMoved = state.operationMoved;
            op.state.pendingDeletes = state.pendingDeletes;
            op.state.pending = state.pending;

            op.state.save(dir, op);

            OperationController loadedOp = new OperationController();
            loadedOp.state.load(dir, loadedOp);

            if(!loadedOp.state.isDeleting) throw new RuntimeException("Missing isDeleting property");
            if(loadedOp.state.operationMoved != 10) throw new RuntimeException("Missing operationMoved property");
            if(loadedOp.state.pendingDeletes == null || loadedOp.state.pendingDeletes.isEmpty()) throw new RuntimeException("Missing pendingDeletes property");
            if(loadedOp.state.pending == null || loadedOp.state.pending.isEmpty()) throw new RuntimeException("Missing pending property");
            if(!loadedOp.state.pending.get(0).oldPath.equals("DCIM/")) throw new RuntimeException("Missing oldPath property");

            new File(dir, "op-state.json").delete();
            System.out.println("PASS op-state.json integration checks passed structurally in headless environment.");
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Test failed");
        }
    }
    public static void main(String[] args) {
        testOpStateSerialization();
    }
}
