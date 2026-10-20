package tw.mediaorganizer;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class OperationController {
    public final OperationState state = new OperationState();
    private final ExecutorService fileWorker = Executors.newSingleThreadExecutor();
    private final ExecutorService thumbWorker = Executors.newFixedThreadPool(2);

    private static OperationController instance;

    public static synchronized OperationController getInstance() {
        if (instance == null) instance = new OperationController();
        return instance;
    }

    public ExecutorService getFileWorker() { return fileWorker; }
    public ExecutorService getThumbWorker() { return thumbWorker; }

    // Quick accessors for legacy code compatibility
    public boolean isDeleting() { return state.isDeleting; }
    public boolean undoing() { return state.undoing; }
    public boolean operationHasSuccess() { return state.operationHasSuccess; }
    public boolean fileBusy() { return state.fileBusy; }

    public String getDestination() { return state.destination; }
    public void setDestination(String dest) { state.destination = dest; }

    public java.util.List<Scanner.Item> getPendingDeletes() { return state.pendingDeletes; }
    public void setPendingDeletes(java.util.List<Scanner.Item> pending) { state.pendingDeletes = pending; }

    public java.util.List<MainActivity.MoveRecord> getPending() { return state.pending; }
    public void setPending(java.util.List<MainActivity.MoveRecord> pending) { state.pending = pending; }

    public int getOperationMoved() { return state.operationMoved; }
    public void setOperationMoved(int moved) { state.operationMoved = moved; }

    public int getOperationFailed() { return state.operationFailed; }
    public void setOperationFailed(int failed) { state.operationFailed = failed; }

    public int getOperationDeleted() { return state.operationDeleted; }
    public void setOperationDeleted(int deleted) { state.operationDeleted = deleted; }
    public void addOperationDeleted(int delta) { state.operationDeleted += delta; }

    public int getOperationDeleteFailed() { return state.operationDeleteFailed; }
    public void setOperationDeleteFailed(int failed) { state.operationDeleteFailed = failed; }

    public void setDeleting(boolean deleting) { state.isDeleting = deleting; }
    public void setUndoing(boolean undoing) { state.undoing = undoing; }
    public void setOperationHasSuccess(boolean success) { state.operationHasSuccess = success; }
    public void setFileBusy(boolean busy) { state.fileBusy = busy; }

}
