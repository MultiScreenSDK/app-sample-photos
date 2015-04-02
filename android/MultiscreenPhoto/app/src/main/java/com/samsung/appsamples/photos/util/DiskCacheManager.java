package com.samsung.appsamples.photos.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.util.Log;

import com.samsung.appsamples.photos.App;
import com.samsung.appsamples.photos.Constants;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.concurrent.Executors;
import java.util.concurrent.RejectedExecutionException;

/**
 * Disk cache manger to maintain a Lru disk cache.
 */
public class DiskCacheManager {

    /** An singleton instance of this class */
    private static DiskCacheManager instance = null;

    /** A lock used to synchronize creation of this object and access to the service map. */
    protected static final Object lock = new Object();

    /** The LruDiskCache. */
    private DiskLruCache mDiskLruCache;

    /** The lock used to synchronize read/write operation. */
    private final Object mDiskCacheLock = new Object();
    private boolean mDiskCacheStarting = true;

    /** Default disk cache size. */
    private static final long DISK_CACHE_SIZE = 1024 * 1024 * 200; // 200MB

    /** default disk cache subfolder in cache folder. */
    private static final String DISK_CACHE_SUBDIR = "SamsungPhotoSample";

    /** default index. */
    private static final int DISK_CACHE_INDEX = 0;

    /**
     * Returns the instance.
     *
     * @return
     */
    public static DiskCacheManager getInstance() {
        if (instance == null) {
            synchronized (lock) {
                if (instance == null) {
                    instance = new DiskCacheManager();
                }
            }
        }
        return instance;
    }

    public DiskCacheManager() {

        // Initialize disk cache on background thread
        File cacheDir = getDiskCacheDir(App.getInstance(), DISK_CACHE_SUBDIR);
        new InitDiskCacheTask().execute(cacheDir);
    }

    /**
     * The async task to initialize the disk cache.
     */
    class InitDiskCacheTask extends AsyncTask<File, Void, Void> {
        @Override
        protected Void doInBackground(File... params) {
            synchronized (mDiskCacheLock) {
                File cacheDir = params[0];
                long cacheSize = DISK_CACHE_SIZE;

                //Get available space for the disk cache.
                long availableSize = Util.getAvailableSpaceSize();

                if (availableSize < DISK_CACHE_SIZE) {
                    //Available space is not enough, use half of the available space.
                    cacheSize = (int) (availableSize / 2);
                    Log.e(Constants.APP_TAG, "There is NOT enough disk space, use smaller size: " +
                            cacheDir);
                }

                //Create dis cache with given cache size.
                try {
                    mDiskLruCache = DiskLruCache.open(cacheDir, 1, 1, cacheSize);
                } catch (IOException ioe) {
                }

                // Finished initialization
                mDiskCacheStarting = false;

                // Wake any waiting threads
                mDiskCacheLock.notifyAll();
            }
            return null;
        }
    }



    /**
     * Check if certain keys exists in disk cache.
     * @param path the image path which should be return by Util.getXXXImageKey() method.
     * @return true if key exists, otherwise false.
     */
    public boolean containsKey(String path) {
        if (mDiskLruCache == null) {
            return false;
        }

        final String key = Util.hashKeyForDisk(path);

        // Also add to disk cache
        synchronized (mDiskCacheLock) {
            try {
                return mDiskLruCache.get(key) != null;
            } catch (IOException ioe) {
            }
            return false;
        }
    }

    /**
     * Add bitmap object into disk cache with given key.
     * @param path the image key which is returned by Util.getXXXImageKey() method.
     * @param bitmap the bitmap object to be cached.
     */
    public void addBitmapToDiskCache(String path, Bitmap bitmap) {
        if (path == null || bitmap == null) {
            return;
        }

        //Get the hash key for the image path.
        final String key = Util.hashKeyForDisk(path);

        // Also add to disk cache
        synchronized (mDiskCacheLock) {
            try {
                if (mDiskLruCache != null && mDiskLruCache.get(key) == null) {
                    OutputStream out = null;
                    try {
                        DiskLruCache.Snapshot snapshot = mDiskLruCache.get(key);
                        if (snapshot == null) {
                            final DiskLruCache.Editor editor = mDiskLruCache.edit(key);
                            if (editor != null) {
                                out = editor.newOutputStream(DISK_CACHE_INDEX);
                                bitmap.compress(
                                        Bitmap.CompressFormat.JPEG, 100, out);
                                editor.commit();
                                out.close();
                            }
                        } else {
                            snapshot.getInputStream(DISK_CACHE_INDEX).close();
                        }
                    } catch (final IOException e) {
                        Log.e(Constants.APP_TAG, "addBitmapToCache - " + e);
                    } catch (Exception e) {
                        Log.e(Constants.APP_TAG, "addBitmapToCache - " + e);
                    } finally {
                        try {
                            if (out != null) {
                                out.close();
                            }
                        } catch (IOException e) {
                        }
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }


    /**
     * Add byte array of bitmap into disk cache with given key.
     * @param path the key which is returned by Util.getXXXImageKey() method.
     * @param bytes the byte array to be stored.
     */
    public void addBitmapToDiskCache(String path, byte[] bytes) {
        if (path == null || bytes == null) {
            return;
        }

        //Get the hash key for the image path.
        final String key = Util.hashKeyForDisk(path);

        // Also add to disk cache
        synchronized (mDiskCacheLock) {
            try {
                if (mDiskLruCache != null && mDiskLruCache.get(key) == null) {
                    OutputStream out = null;
                    try {
                        DiskLruCache.Snapshot snapshot = mDiskLruCache.get(key);
                        if (snapshot == null) {
                            final DiskLruCache.Editor editor = mDiskLruCache.edit(key);
                            if (editor != null) {
                                out = editor.newOutputStream(DISK_CACHE_INDEX);
                                out.write(bytes);
                                editor.commit();
                                out.close();
                            }
                        } else {
                            snapshot.getInputStream(DISK_CACHE_INDEX).close();
                        }
                    } catch (final IOException e) {
                        Log.e(Constants.APP_TAG, "addBitmapToCache - " + e);
                    } catch (Exception e) {
                        Log.e(Constants.APP_TAG, "addBitmapToCache - " + e);
                    } finally {
                        try {
                            if (out != null) {
                                out.close();
                            }
                        } catch (IOException e) {
                        }
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Read the cache bitmap file directly from cache.
     *
     * @param bmpPath the bitmap key which is returned by Util.getXXXImageKey() method.
     * @return bitmap object.
     */
    public Bitmap getBitmapFromDiskCache(String bmpPath) {
        if (bmpPath == null) {
            return null;
        }

        //Get the hash key for the image path.
        final String key = Util.hashKeyForDisk(bmpPath);


        Bitmap bitmap = null;
        synchronized (mDiskCacheLock) {
            while (mDiskCacheStarting) {
                try {
                    mDiskCacheLock.wait();
                } catch (InterruptedException e) {
                }
            }
            if (mDiskLruCache != null) {
                InputStream inputStream = null;
                try {
                    final DiskLruCache.Snapshot snapshot = mDiskLruCache.get(key);
                    if (snapshot != null) {
                        inputStream = snapshot.getInputStream(DISK_CACHE_INDEX);
                        if (inputStream != null) {
                            FileDescriptor fd = ((FileInputStream) inputStream).getFD();

                            // Decode bitmap, but we don't want to sample so give
                            // MAX_VALUE as the target dimensions

                            final BitmapFactory.Options options = new BitmapFactory.Options();
                            options.inJustDecodeBounds = false;
                            bitmap = BitmapFactory.decodeFileDescriptor(fd, null, options);
                        }
                    }
                } catch (final IOException e) {
                    Log.e(Constants.APP_TAG, "getBitmapFromDiskCache - " + e);
                } finally {
                    try {
                        if (inputStream != null) {
                            inputStream.close();
                        }
                    } catch (IOException e) {
                    }
                }
            }
            return bitmap;
        }
    }


    /**
     * Read the cache bitmap file directly from cache.
     *
     * @param bmpPath the bitmap key which is returned by Util.getXXXImageKey() method.
     * @return bitmap object.
     */
    public byte[] getByteArrayFromDiskCache(String bmpPath) {

        //Get the hash key for the image path.
        final String key = Util.hashKeyForDisk(bmpPath);

        byte[] bytes = null;

        synchronized (mDiskCacheLock) {
            while (mDiskCacheStarting) {
                try {
                    mDiskCacheLock.wait();
                } catch (InterruptedException e) {
                }
            }
            if (mDiskLruCache != null) {
                ByteArrayOutputStream bos = new ByteArrayOutputStream();
                InputStream inputStream = null;

                //Read the cached bitmap int byte array.
                try {
                    final DiskLruCache.Snapshot snapshot = mDiskLruCache.get(key);
                    if (snapshot != null) {
                        inputStream = snapshot.getInputStream(DISK_CACHE_INDEX);
                        if (inputStream != null) {
                            FileInputStream fis = (FileInputStream) inputStream;

                            byte[] buffer = new byte[1024];
                            int bytesRead;
                            while ((bytesRead = fis.read(buffer)) != -1) {
                                bos.write(buffer, 0, bytesRead);
                            }

                            bytes = bos.toByteArray();
                        }
                    }
                } catch (final IOException e) {
                    Log.e(Constants.APP_TAG, "getBitmapFromDiskCache - " + e);
                } finally {
                    try {
                        if (inputStream != null) {
                            inputStream.close();
                        }
                    } catch (IOException e) {
                    }
                    try {
                        bos.close();
                    } catch (IOException e) {
                    }
                }
            }
            return bytes;
        }
    }


    /**
     * Compress the bitmap first with given compress rate, then save it into dis cache.
     * @param key the bitmap key which is returned by Util.getXXXImageKey() method.
     * @param compressRate compress rate.
     * @param bitmap the bitmap object to be cached.
     */
    public static void addCompressedBitmapToCache(final String key, final int compressRate, final Bitmap bitmap) {

        //Parameters validation check.
        if (key == null || bitmap == null || bitmap.isRecycled()) {
            return;
        }

        //Check if the executor service is already terminated.
        if (App.getInstance().getCreateThumbnailsService().isTerminated()) {
            //Create a new service when it is terminated.
            App.getInstance().setCreateThumbnailsService(Executors.newFixedThreadPool(10));
        }


        //Add protection to make sure the ExecutorService won't reject the execution.
        try {
            App.getInstance().getCreateThumbnailsService().execute(new Runnable() {
                @Override
                public void run() {
                    byte[] bytes = null;
                    ByteArrayOutputStream bos = new ByteArrayOutputStream();
                    try {

                        //Compress bitmap to JEPG format with compress rate.
                        bitmap.compress(Bitmap.CompressFormat.JPEG, compressRate, bos);

                        //Output the data to byte array.
                        bytes = bos.toByteArray();

                        //add the bitmap into disk cache.
                        instance.addBitmapToDiskCache(key, bytes);

                    } catch (IllegalStateException ise) {
                    } finally {
                        try {
                            //Close the ByteArrayOutputStream
                            bos.close();
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                }
            });
        } catch (RejectedExecutionException ree) {
        }
    }


    /**
     * Creates a unique subdirectory of the designated mMultiscreenApp cache directory.
     * @param context
     * @param subFolder the subfolder name in application cache folder.
     * @return the file object of cache folder.
     */
    public static File getDiskCacheDir(Context context, String subFolder) {
        //Add application cache folder.
        final String cachePath = context.getCacheDir().getPath();

        //Return the file object of the given subfolder in cache folder.
        return new File(cachePath + File.separator + subFolder);
    }


}
