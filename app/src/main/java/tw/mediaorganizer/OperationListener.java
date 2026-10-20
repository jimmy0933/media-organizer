package tw.mediaorganizer;

public interface OperationListener {
    void onOperationProgress();
    void onOperationComplete();
    void onPermissionNeeded();
}
