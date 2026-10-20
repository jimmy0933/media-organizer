package tw.mediaorganizer;

import android.app.Application;
import android.util.LruCache;
import android.graphics.Bitmap;
import android.content.Context;

public class App extends Application {
    public static Context context;
    public static final LruCache<String, Bitmap> thumbCache = new LruCache<String, Bitmap>(50 * 1024 * 1024) {
        @Override
        protected int sizeOf(String key, Bitmap value) {
            return value.getByteCount();
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        context = getApplicationContext();
    }
}
