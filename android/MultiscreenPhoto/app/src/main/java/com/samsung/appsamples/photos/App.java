/*******************************************************************************
 * Copyright (c) 2015 Samsung Electronics
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *******************************************************************************/

package com.samsung.appsamples.photos;

import android.app.Application;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.samsung.appsamples.photos.model.Gallery;
import com.samsung.appsamples.photos.util.ConnectivityManager;
import com.samsung.appsamples.photos.util.DiskCacheManager;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class App extends Application {

    /** The gallery object contains all the photo and bucket information. */
    private Gallery gallery = new Gallery();

    /** The application instance. */
    private static App instance;

    private ExecutorService createThumbnailsService = Executors.newFixedThreadPool(10);

    /** Used to calculate how many activity is at foreground. */
    public int activityCounter = 0;

    /** The default options used to load bitmap file. */
    private BitmapFactory.Options optionsLoadingThumbnail;

    /** The connectivity manager instance. */
    private ConnectivityManager mConnectivityManager;

    /** The disk cache manger. */
    private DiskCacheManager mDiskCacheManger;




    /**
     * Static method to return App instance.
     *
     * @return App instance.
     */
    public static App getInstance() {
        return instance;
    }

    public App() {
        instance = this;
    }

    @SuppressWarnings("deprecation")
    @Override
    public void onCreate() {
        super.onCreate();

        //Initialize thumbnail loading options.
        optionsLoadingThumbnail = new BitmapFactory.Options();
        optionsLoadingThumbnail.inJustDecodeBounds = false;
        optionsLoadingThumbnail.inSampleSize = 10;
        optionsLoadingThumbnail.inScaled = true;
        optionsLoadingThumbnail.inPreferredConfig = Bitmap.Config.RGB_565;
        optionsLoadingThumbnail.inPreferQualityOverSpeed = false;

        //Get disk manager instance.
        mDiskCacheManger = DiskCacheManager.getInstance();

        //Get connectivity manager.
        mConnectivityManager = ConnectivityManager.getInstance();
    }


    /**
     * Get gallery object which contains all the photos and buckets information.
     */
    public Gallery getGallery() {
        return gallery;
    }

    /**
     * Set the gallery.
     * @param gallery the gallery object to be used.
     */
    public void setGallery(Gallery gallery) {
        this.gallery = gallery;
    }


    /**
     * The executor maintains fixed threads which is used to mini thumbnails.
     */
    public ExecutorService getCreateThumbnailsService() {
        return createThumbnailsService;
    }

    /**
     * Set the new service to use.
     * @param createThumbnailsService the new executor.
     */
    public void setCreateThumbnailsService(ExecutorService createThumbnailsService) {
        this.createThumbnailsService = createThumbnailsService;
    }

    /**
     * The options used to loading thumbnails into UI.
     */
    public BitmapFactory.Options getOptionsLoadingThumbnail() {
        return optionsLoadingThumbnail;
    }


    /**
     * Get the disk cache manager.
     * @return
     */
    public DiskCacheManager getDiskCacheManager() {
        return mDiskCacheManger;
    }

    /**
     * Get the connectivity manager.
     * @return
     */
    public ConnectivityManager getConnectivityManager() {
        return mConnectivityManager;
    }



    /**
     * The clean up method, it should only be called when application exits.
     */
    public void cleanup() {
        //Clean up multiscreen service.
        mConnectivityManager.clearService();

        //Clean up Gallery
        for (Gallery.Bucket bucket : getGallery()) {
            bucket.clear();
        }
        getGallery().clear();
    }


}
