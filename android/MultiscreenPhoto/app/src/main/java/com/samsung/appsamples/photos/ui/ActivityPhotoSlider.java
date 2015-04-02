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

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.View;
import android.widget.Scroller;

import com.samsung.appsamples.photos.App;
import com.samsung.appsamples.photos.Constants;
import com.samsung.appsamples.photos.R;
import com.samsung.appsamples.photos.adapter.PhotoSliderAdapter;
import com.samsung.appsamples.photos.util.Util;
import com.samsung.multiscreen.Service;

import java.io.File;
import java.lang.reflect.Field;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;


/**
 * The photo slide activity.
 */
public class ActivityPhotoSlider extends ActivityBase {
    private ViewPager mPager;
    private PhotoSliderAdapter mPagerAdapter;

    /** The bucket index in Gallery. */
    private int mBucketIndex = -1;

    /** The photo offset in bucket. */
    private int mOffset = - 1;

    /** The index of current page. */
    private int mCurrentPage = 0;

    /**
     * The flag shows it is the first time to send photo.
     * We use this flag to send the first photo.
     */
    private boolean isFirstTime = true;

    /** The target TV width. */
    public static final int TV_SCREEN_WIDTH = 1920;

    /** The target TV height. */
    public static final int TV_SCREEN_HEIGHT = 1080;

    /** The blocking sending queue. */
    LinkedBlockingQueue<String> sendingQueue;

    /** The executor for sending photo to TV. */
    ExecutorService sendPhotoService = Executors.newSingleThreadExecutor();

    /** Whether or not the sending photo thread should be running. */
    boolean isRunning = true;

    /** reference to the multiscreen service. */
    private Service service = null;

    /** The delay time to hide action bar. */
    private static final int HIDE_ACTION_BAR_DELAY = 3000;

    /** The thread to hide actionbar. */
    private Runnable hideActionBarRunnable;

    /** The handler to hide actionbar. */
    private Handler hideActionBarHandler;

    /**********************************************************************************************
     * Android Activity Lifecycle methods
     *********************************************************************************************/

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_screen_slide);

        //Enable the back key in actionbar.
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        //Create the sending queue.
        sendingQueue = new LinkedBlockingQueue<String>();

        //Create sending photo service.
        sendPhotoService.execute(sendingPhotoThread);
        sendPhotoService.shutdown();

        //Get view pager.
        mPager = (ViewPager) findViewById(R.id.pager);

        //Use customized scroller to control the wipe speed.
        try {

            //Create customized scroller.
            FixedSpeedScroller scroller = new FixedSpeedScroller(mPager.getContext());

            //Set duration to 500 milliseconds.
            scroller.setFixedDuration(500);

            //Set the mScroller field.
            Field fieldScroller = ViewPager.class.getDeclaredField("mScroller");
            fieldScroller.setAccessible(true);
            fieldScroller.set(mPager, scroller);
        } catch (NoSuchFieldException e) {
        } catch (IllegalArgumentException e) {
        } catch (IllegalAccessException e) {
        }

        if (savedInstanceState != null) {
            //Read bucket index from intent.
            mBucketIndex = savedInstanceState.getInt(Constants.GROUP_POSITION, -1);

            //Read the photo offset in bucket.
            mOffset = savedInstanceState.getInt(Constants.PHOTO_OFFSET_IN_BUCKET, 0);
        } else {

            //Read parameters passed in intent.
            Intent intent = getIntent();
            if (intent != null) {
                //Read bucket index from intent.
                mBucketIndex = intent.getIntExtra(Constants.GROUP_POSITION, -1);

                //Read the photo offset in bucket.
                mOffset = intent.getIntExtra(Constants.PHOTO_OFFSET_IN_BUCKET, 0);
            }
        }

        if (mBucketIndex>=0 && mOffset >=0) {

            //Create the page adapter.
            mPagerAdapter = new PhotoSliderAdapter(getSupportFragmentManager(), mBucketIndex);
            mPager.setAdapter(mPagerAdapter);

            //Set up view pager.
            mPager.setOnPageChangeListener(mOnPageChangeListener);
            mPager.setCurrentItem(mOffset);
        }

        mPager.setOnSystemUiVisibilityChangeListener(
                new View.OnSystemUiVisibilityChangeListener() {
                    @Override
                    public void onSystemUiVisibilityChange(int vis) {
                        if ((vis & View.SYSTEM_UI_FLAG_LOW_PROFILE) != 0) {
                            getSupportActionBar().hide();
                        } else {
                            getSupportActionBar().show();
                        }
                    }
                });

        // Start low profile mode and hide ActionBar
        mPager.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LOW_PROFILE);

        //Set current page.
        mCurrentPage = mOffset;

        //It is the first time to run the activity.
        isFirstTime = true;

        //Create the hide actionbar handler.
        hideActionBarHandler = new Handler();
    }


    public void onDestroy() {
        super.onDestroy();

        //remove the reference.
        service = null;

        //Change flag to false, try to stop the sending photo thread.
        isRunning = false;

        //Shutdown the sending photo service.
        if (!sendPhotoService.isTerminated()) {
            sendPhotoService.shutdownNow();
        }
    }

    /**********************************************************************************************
     * Android Activity methods override
     *********************************************************************************************/

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);

        //Save the bucket index.
        outState.putInt(Constants.GROUP_POSITION, mBucketIndex);

        //Save the current page.
        outState.putInt(Constants.PHOTO_OFFSET_IN_BUCKET, mCurrentPage);
    }

    /**********************************************************************************************
     * Other methods
     *********************************************************************************************/

    /**
     * Called when TV service is changed.
     */
    @Override
    public void onServiceChanged() {
        super.onServiceChanged();

        //When the TV is connected at slider screen, send photo to TV immediately.
        if (App.getInstance().getConnectivityManager().isTVConnected()) {

            //Only send the photo when the service is changed.
            if (!App.getInstance().getConnectivityManager().getService().equals(service)) {
                service = App.getInstance().getConnectivityManager().getService();
                putImageIntoQueue();
            }
        } else {
            //Reset the service when it is not connected anymore.
            service = null;
        }
    }


    private ViewPager.OnPageChangeListener mOnPageChangeListener = new ViewPager.OnPageChangeListener() {
        @Override
        public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
            if (positionOffset == 0) {

                //For the fist time connect to TV at slider screen.
                if (isFirstTime) {

                    //Set to false to make sure it won't send again.
                    isFirstTime = false;

                    //update current page.
                    mCurrentPage = mPager.getCurrentItem();

                    //Put the image into sending queue.
                    putImageIntoQueue();
                }
            }
        }

        @Override
        public void onPageSelected(int position) {
        }

        @Override
        public void onPageScrollStateChanged(int state) {
            if (state == ViewPager.SCROLL_STATE_IDLE) {
                //Log.d(Constants.APP_TAG, "currentPage=" + mPager.getCurrentItem());
                //Send the photo to TV when page is changed.
                if (mCurrentPage != mPager.getCurrentItem()) {

                    //update current page.
                    mCurrentPage = mPager.getCurrentItem();

                    //Put the image into sending queue.
                    putImageIntoQueue();
                }
            }
        }
    };

    /**
     * The thread to send photo to TV.
     */
    private Runnable sendingPhotoThread = new Runnable() {
        @Override
        public void run() {
            while (isRunning) {
                String filePath = null;

                //Take one file from sending queue.
                //It is blocked until there is a file available.
                try {
                    filePath = sendingQueue.take();
                } catch (InterruptedException ie) {
                }
                //Log.d(Constants.APP_TAG, "sendingPhotoThread - took one file to send.");

                //Fetch the last one there is are more items.
                while (sendingQueue.size() > 0) {
                    filePath = sendingQueue.poll();
                }

                //If this is the only photo, send it to TV.
                if (filePath != null) {
                    File photoFile = new File(filePath);

                    //Make sure file exists and the sending photo thread is running.
                    if (photoFile.exists() && isRunning) {
                        //send photo to TV.
                        sendPhotoToTV(filePath);
                    }
                }
            }
        }
    };


    /**
     * Put the image file name into sending queue.
     */
    void putImageIntoQueue() {
        if (!App.getInstance().getConnectivityManager().isTVConnected()) {
            return;
        }

        //Get the photo path.
        String imagePath = mPagerAdapter.getImagePathAtPosition(mCurrentPage);

        //Put the path into
        if (imagePath != null) {
            try {
                sendingQueue.put(imagePath);
            } catch (InterruptedException e) {
            }
        }
    }

    /**
     * Load image data by give path and send it to TV.
     *
     * @param imagePath the image path.
     */
    private void sendPhotoToTV(String imagePath) {

        //long start_time = System.currentTimeMillis();
        final byte[] bytes = loadImage(imagePath);

        if (bytes != null) {
            try {

                //Send a signal to TV app to notify that we are going to send photo data.
                App.getInstance().getConnectivityManager().sendToTV(Constants.EVENT_PHOTO_TRANSFER_START, null);

                //Sending photo data to TV app.
                App.getInstance().getConnectivityManager().sendToTV(Constants.EVENT_SHOW_PHOTO, "", bytes);
                //Log.e(Constants.APP_TAG, "bytes size sent to TV: " + bytes.length);
            } catch (Throwable throwable) {
                //catch all the error from SDK and ignore.
                Log.e(Constants.APP_TAG, "Error/Exception from SDK, ignore: " + throwable.toString());
                return;
            }
            //long end_time = System.currentTimeMillis();
            //final long time = end_time - start_time;
            //Log.d(Constants.APP_TAG, "Total load and send time: " + time);


            //
            //Debug purpose only.
            // Show a toast message on screen about the photo sending time and size.
            //Disable the output
            //
            //final int len = bytes.length;
            //RunUtil.runOnUI(new Runnable() {
            //    @Override
            //     public void run() {
            //         if (ActivityPhotoSlider.this != null) {
            //             try {
            //                 Toast.makeText(ActivityPhotoSlider.this,
            //                         "Sent to TV in " + time + " milliseconds. Size=" + len / 1000 + " KBs",
            //                         Toast.LENGTH_LONG).show();
            //             } catch (Exception e) {
            //             }
            //         }
            //     }
            // });

        }
    }


    /**
     * Loading resized image if it is bigger than default size,
     * then compress it and save to disk cache.
     *
     * @param path the image path to be loaded.
     * @return byte array of image.
     */
    byte[] loadImage(String path) {
        byte[] bytes = null;
        final File file = new File(path);
        if (!file.exists()) {
            return null;
        }

        //The start up time for performance test only.
        //Long startTime = System.currentTimeMillis();

        //Get the disk cache key.
        String key = Util.getTVImageKey(path);

        //Read the bitmap from disk cache to byte array.
        bytes = App.getInstance().getDiskCacheManager().getByteArrayFromDiskCache(key);

        if (bytes == null) {
            //Load the image if it is not cached in disk.
            bytes = Util.decodeSampledBitmapByteArrayFromFile(path, TV_SCREEN_WIDTH,
                    TV_SCREEN_HEIGHT, false);
            if (bytes != null) {
                //add the bitmap into disk cache.
                App.getInstance().getDiskCacheManager().addBitmapToDiskCache(key, bytes);
                //Log.d(Constants.APP_TAG, "Save the final image into disk, saved size=" + bytes.length);
            }
        }

        //The following code is for the performance test.
        //Long endTime = System.currentTimeMillis();
        //Long processTime = endTime - startTime;
        //Log.d(Constants.APP_TAG, "Load image Time (milliSeconds): " + processTime);

        return bytes;
    }

    /**
     * Hide actionbar.
     */
    public void hideActionBar() {

        //Remove the runnable if it is already running.
        if (hideActionBarRunnable != null) {
            hideActionBarHandler.removeCallbacks(hideActionBarRunnable);
        }

        //Hide the action bar.
        getSupportActionBar().hide();
    }

    /**
     * Show actionbar.
     */
    public void showActionBar() {

        //Show the actionbar if it is not showing.
        if (!getSupportActionBar().isShowing()) getSupportActionBar().show();

        //Remove the existing hide runnable.
        if (hideActionBarRunnable != null) {
            hideActionBarHandler.removeCallbacks(hideActionBarRunnable);
        }

        //Create a new hide actionbar runnable.
        hideActionBarRunnable = new Runnable() {
            @Override
            public void run() {
                getSupportActionBar().hide();
            }
        };

        //Call the runnable after certain dealy.
        hideActionBarHandler.postDelayed(hideActionBarRunnable, HIDE_ACTION_BAR_DELAY);
    }


    /**
     * Custom Scroller of ViewPager.
     */
    public static class FixedSpeedScroller extends Scroller {

        /** The duration value. */
        private int mDuration = 1000;

        public FixedSpeedScroller(Context context) {
            super(context);
        }

        @Override
        public void startScroll(int startX, int startY, int dx, int dy, int duration) {
            // Ignore received duration, use fixed one instead
            super.startScroll(startX, startY, dx, dy, mDuration);
        }

        @Override
        public void startScroll(int startX, int startY, int dx, int dy) {
            // Ignore received duration, use fixed one instead
            super.startScroll(startX, startY, dx, dy, mDuration);
        }

        /**
         * Set the duration value.
         *
         * @param duration the new duration value.
         */
        public void setFixedDuration(int duration) {
            mDuration = duration;
        }
    }
}
