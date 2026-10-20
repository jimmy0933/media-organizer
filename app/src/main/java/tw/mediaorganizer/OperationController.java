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
}
