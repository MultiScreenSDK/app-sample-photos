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
package com.samsung.appsamples.photos.ui;

import android.app.LoaderManager;
import android.content.CursorLoader;
import android.content.Intent;
import android.content.Loader;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.database.Cursor;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.ViewConfiguration;

import com.samsung.appsamples.photos.App;
import com.samsung.appsamples.photos.Constants;
import com.samsung.appsamples.photos.R;
import com.samsung.appsamples.photos.model.Gallery;
import com.samsung.appsamples.photos.model.Photo;
import com.samsung.appsamples.photos.util.Util;

import java.lang.reflect.Field;
import java.util.Collections;
import java.util.Comparator;
import java.util.ConcurrentModificationException;
import java.util.Iterator;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * The Gallery activity.
 */
public class ActivityGallery extends ActivityBase implements LoaderManager.LoaderCallbacks<Cursor> {
    /**
     * The loader's unique id.
     */
    private static final int LOADER_ID = 100;

    private FragmentGalleryExpandableListView fragment;
    private SharedPreferences prefs;

    private ExecutorService loadPhotoService = Executors.newSingleThreadExecutor();
    private ExecutorService loadThumbnailsService = Executors.newSingleThreadExecutor();

    /**
     * Set it to true when loading thumbnails.
     * Any cursor update will be ignore until loading is done.
     */
    private boolean isLoadingThumb = false;
    /**
     * Keep the size of last cursor.
     */
    private int lastCursorSize = 0;


    /**********************************************************************************************
     * Android Activity Lifecycle methods
     *********************************************************************************************/

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_gallery);
        if (savedInstanceState == null) {
            fragment = new FragmentGalleryExpandableListView();

            getSupportFragmentManager().beginTransaction()
                    .add(R.id.container, fragment)
                    .commit();
        }

        // Initializing the Loader
        getLoaderManager().initLoader(LOADER_ID, null, this);

        prefs = getSharedPreferences(Constants.APP_PREFERENCES, MODE_PRIVATE);

        //Force show the menu icon at actionbar.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            try {
                ViewConfiguration config = ViewConfiguration.get(this);
                Field menuKeyField = ViewConfiguration.class.getDeclaredField("sHasPermanentMenuKey");

                if (menuKeyField != null) {
                    menuKeyField.setAccessible(true);
                    menuKeyField.setBoolean(config, false);
                }
            } catch (Exception e) {
            }
        }

        //Display welcome screen for the first time.
        gotoGuide();
    }

    public void onDestroy() {

        //Clean up everything before existing.
        try {
            App.getInstance().getConnectivityManager().stopDiscovery();
            App.getInstance().cleanup();
        } catch (Exception e) {
        }
        super.onDestroy();
    }


    /**********************************************************************************************
     * Android Activity methods override
     *********************************************************************************************/

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        //Refresh the list to adjust size.
        if (fragment != null) fragment.refresh();
    }


    @Override
    public void onBackPressed() {

        //Close the executor service when users press back key.
        closeExecutorServices();

        //Finish the application.
        super.onBackPressed();
    }


    /**********************************************************************************************
     * LoaderManager.LoaderCallbacks implementation
     *********************************************************************************************/

    @Override
    public Loader<Cursor> onCreateLoader(int i, Bundle bundle) {
        //Log.d(Constants.APP_TAG, "Cursor onCreateLoader is called.");
        String[] imageColumns = {MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
                MediaStore.Images.Media.BUCKET_ID,
                MediaStore.Images.Media._ID,
                MediaStore.Images.ImageColumns.DATA,
                MediaStore.Images.Media.DATE_TAKEN};
        CursorLoader cursorLoader = new CursorLoader(
                this,
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                imageColumns,
                null,
                null,
                //Sort the folders by name and its taken time.
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME + " ASC, " +
                        MediaStore.Images.Media.DATE_TAKEN + " DESC"
        );
        return cursorLoader;
    }


    @Override
    public void onLoadFinished(Loader<Cursor> cursorLoader, final Cursor cursor) {

        //Called when cursor is loaded.
        //Check if it is a valid cursor update.
        if (fragment != null && cursorLoader.getId() == LOADER_ID &&
                cursor != null && !isLoadingThumb && lastCursorSize != cursor.getCount()) {

            //Get the cursor size
            lastCursorSize = cursor.getCount();

            //Cancel the previous tasks if it is not finished.
            if (loadPhotoService.isShutdown()) {
                if (!loadPhotoService.isTerminated()) {
                    loadPhotoService.shutdownNow();
                }
                loadPhotoService = Executors.newSingleThreadExecutor();
            }

            //Load cursor into Gallery at background.
            loadPhotoService.execute(new Runnable() {
                @Override
                public void run() {
                    try {
                        loadPhoto(cursor);
                    } catch (Exception e) {
                    }
                }
            });
            loadPhotoService.shutdown();
        }
    }


    /**
     * Called when Cursor is reset.
     *
     * @param cursorLoader
     */
    @Override
    public void onLoaderReset(Loader<Cursor> cursorLoader) {
        //When cursor is reset, clean up executor service.
        try {
            closeExecutorServices();
        }catch (Exception e){}
    }


    /**********************************************************************************************
     * Private methods
     *********************************************************************************************/

    /**
     * Show the guide screen at the first time only.
     */
    private void gotoGuide() {

        //Check the value in preference storage.
        boolean welcomeGuide = prefs.getBoolean(Constants.APP_PREFERENCE_WELCOME_GUIDE, false);

        //When the welcome screen is not displayed before, launch ActivityWelcome activity.
        if (!welcomeGuide) {
            Intent intent = new Intent(this, ActivityWelcome.class);
            startActivity(intent);
        }
    }

    /**
     * Close all the executor services.
     */
    private void closeExecutorServices() {
        if (!loadPhotoService.isTerminated()) {
            //Shut down the service if if loading photo service is not finished.
            loadPhotoService.shutdownNow();
        }

        if (!loadThumbnailsService.isTerminated()) {
            //Shut down the service if loading thumbnail service is not finished.
            loadThumbnailsService.shutdownNow();
        }

        if (!App.getInstance().getCreateThumbnailsService().isTerminated()) {
            //Shut down the service if creating thumbnail service is not finished.
            App.getInstance().getCreateThumbnailsService().shutdownNow();
        }
    }


    /**
     * Load photo into Gallery. There are two main steps.
     * Remove buckets/photos which does not exist anymore,
     * and add new buckets/photos.
     *
     * @param cursor The cursor with new data.
     */
    private void loadPhoto(Cursor cursor) {

        //Get the column indexes.
        int bucketNameColumnIndex = cursor.getColumnIndex(MediaStore.Images.Media.BUCKET_DISPLAY_NAME);
        int bucketIDColumnIndex = cursor.getColumnIndex(MediaStore.Images.Media.BUCKET_ID);
        int photoPathColumnIndex = cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA);
        int photoIDColumnIndex = cursor.getColumnIndex(MediaStore.Images.Media._ID);
        int photoIDColumnTakenIndex = cursor.getColumnIndex(MediaStore.Images.Media.DATE_TAKEN);

        //Create a new gallery object.
        Gallery newGallery = new Gallery();

        //Move the cursor to the first position.
        if (cursor.moveToFirst()) {
            Gallery.Bucket bucket = null;
            do {

                //Read bucket id.
                int bucketID = cursor.getInt(bucketIDColumnIndex);

                //Read bucket name.
                String bucketName = cursor.getString(bucketNameColumnIndex);

                //Read photo id.
                int id = cursor.getInt(photoIDColumnIndex);

                //Read image path.
                String imagePath = cursor.getString(photoPathColumnIndex);

                //Read photo taken date.
                int dateTaken = cursor.getInt(photoIDColumnTakenIndex);

                //Read photo's orientation.
                int orientation = Util.getExifOrientation(imagePath);

                String thumbPath = null;
                if (bucket == null) {
                    bucket = new Gallery.Bucket(bucketID, bucketName);
                } else if (bucketID != bucket.getId()) {//different from prev bucket.

                    //If previous bucket does not exist in bucket, add it directly.
                    if (!newGallery.contains(bucket)) {
                        newGallery.add(bucket);
                    }

                    //Get the bucket from Gallery by bucket id.
                    bucket = newGallery.getBucketById(bucketID);
                    if (bucket == null) {
                        //The bucket id does not exist. Create a new bucket.
                        bucket = new Gallery.Bucket(bucketID, bucketName);
                    }
                }

                //Create the photo object.
                Photo photo = new Photo(id, imagePath, -1, thumbPath, bucketID,
                        bucketName, dateTaken, orientation);

                //Add the photo into bucket.
                bucket.add(photo);

            } while (!cursor.isClosed() && cursor.moveToNext());

            //add last bucket.
            if (bucket != null) {
                newGallery.add(bucket);
            }
        }


        //Set change flag to false.
        boolean changeFlag = false;


        //Get the existing gallery object.
        Gallery exisingGallery = App.getInstance().getGallery();

        //Set camera folder is not opened.
        boolean isCameraOpened = false;

        //Set the gallery if it is the first time.
        //expand the first camera folder.
        if (exisingGallery.size() == 0) {//first time
            App.getInstance().setGallery(newGallery);

            //make sure Camera folder is opened by default.
            for (Gallery.Bucket bucket : App.getInstance().getGallery()) {

                //Only open the first camera folder.
                if (bucket.getName().equalsIgnoreCase("camera") && !isCameraOpened) {
                    isCameraOpened = true;
                    bucket.setVisibility(true);
                }
            }

            //Something changed.
            changeFlag = true;

            //Only load thumbnails for the first time.
            loadThumbnails();
        } else {
            //remove bucket and photos
            Iterator<Gallery.Bucket> iteExistingGallery = exisingGallery.iterator();
            while (iteExistingGallery.hasNext()) {
                Gallery.Bucket bucket = iteExistingGallery.next();
                //Log.d(Constants.APP_TAG, "Checking bucket " + bucket.name);

                if (newGallery.contains(bucket)) {
                    Gallery.Bucket bucketInNewGallery = newGallery.get(newGallery.indexOf(bucket));

                    //Remove all the photos which is not in the bucket of new gallery.
                    if (bucket.retainAll(bucketInNewGallery)) {
                        changeFlag = true;
                    }
                } else {
                    //new data does not contain this bucket. Remove it.
                    bucket.clear();
                    iteExistingGallery.remove();
                    changeFlag = true;
                }
            }

            //Add new bucket and photos.
            Iterator<Gallery.Bucket> iteNewGallery = newGallery.iterator();
            while (iteNewGallery.hasNext()) {
                Gallery.Bucket bucket = iteNewGallery.next();
                if (exisingGallery.contains(bucket)) {

                    //Bucket exists. Check if there is any new photo.
                    Gallery.Bucket bucketInExistingGallery = exisingGallery.get(exisingGallery.indexOf(bucket));

                    bucket.removeAll(bucketInExistingGallery);
                    if (bucket.size() > 0) {
                        changeFlag = true;
                        bucketInExistingGallery.addAll(0, bucket);
                    }
                } else {
                    //This is a new bucket. Add it.
                    exisingGallery.add(bucket);
                    changeFlag = true;
                }
            }
        }


        //We only update the adapter when content is changed.
        if (changeFlag) {

            //Sort the bucket name.
            Collections.sort(App.getInstance().getGallery(), new Comparator<Gallery.Bucket>() {
                @Override
                public int compare(Gallery.Bucket lhs, Gallery.Bucket rhs) {
                    return lhs.getName().compareToIgnoreCase(rhs.getName());
                }
            });
            fragment.updateAdapter();
        }
    }

    /**
     * Load thumbnail image path at background. It won't block the UI thread.
     */
    private void loadThumbnails() {

        //Set true, ignore the cursor update during loading thumbnails.
        isLoadingThumb = true;
        loadThumbnailsService.execute(new Runnable() {
            @Override
            public void run() {
                final Gallery exisingGallery = App.getInstance().getGallery();

                //Load all the photo thumbnails information into gallery.
                try {
                    Iterator<Gallery.Bucket> iteGallery = exisingGallery.iterator();
                    while (iteGallery.hasNext()) {
                        Gallery.Bucket bucket = iteGallery.next();
                        Iterator<Photo> ite = bucket.iterator();
                        while (ite.hasNext()) {
                            Photo photo = ite.next();
                            if (photo.getThumbPath() == null || photo.getThumbId() < 0) {
                                Gallery.loadThumbnailInfo(photo);
                            }

                        }
                    }
                } catch (ConcurrentModificationException cme) {
                }

                //Change isLoadingThumb to false, the following cursor update will not be ignored.
                isLoadingThumb = false;
            }
        });
        loadThumbnailsService.shutdown();
    }
}
