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


package com.samsung.appsamples.photos.model;

import android.content.ContentResolver;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.provider.MediaStore;

import com.samsung.appsamples.photos.App;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.Executors;
import java.util.concurrent.RejectedExecutionException;

/**
 * Created by Bin Liu on 3/10/2015.
 */

public class Gallery extends ArrayList<Gallery.Bucket> {


    /**
     * Define the thumbnail type to be displayed.
     */
    public static final int THUMB_TYPE = MediaStore.Images.Thumbnails.MINI_KIND;

    /**
     * The photo bucket class.
     */
    public static class Bucket extends CopyOnWriteArrayList<Photo> {
        /**
         * If false, do not display the photos.
         */
        private boolean mVisible = false;
        private int mId;
        private String mName;

        public Bucket(int id, String name) {
            this.setId(id);
            this.setName(name);
            mVisible = false;
        }

        /**
         * Set the visibility of the bucket.
         *
         * @param value the visibility value.
         */
        public void setVisibility(boolean value) {
            mVisible = value;
        }

        /**
         * Check if the bucket is visible.
         *
         * @return true if it is visible otherwise false.
         */
        public boolean isVisible() {
            return mVisible;
        }

        @Override
        public boolean equals(Object o) {
            if (!(o instanceof Bucket) || o == null) {
                return false;
            }

            Bucket b = (Bucket) o;
            return b.getId() == this.getId();
        }

        /**
         * Get bucket id.
         */
        public int getId() {
            return mId;
        }

        /**
         * Set the bucket id.
         *
         * @param id the bucket id.
         */
        public void setId(int id) {
            this.mId = id;
        }

        /**
         * Get bucket name.
         */
        public String getName() {
            return mName;
        }

        /**
         * Set bucket name.
         *
         * @param name the name of bucket.
         */
        public void setName(String name) {
            this.mName = name;
        }
    }

    /**
     * Return bucket by id.
     * @param bucketId the bucket id.
     * @return the bucket found.
     */
    public Bucket getBucketById(int bucketId) {
        Iterator<Bucket> ite = iterator();
        while (ite.hasNext()) {
            Bucket bucket = ite.next();
            if (bucketId == bucket.getId()) {
                return bucket;
            }
        }
        return null;
    }

    /**
     * Get thumbnail path by given image id.
     *
     * @param photo The photo object which need to load thumbnail information.
     */
    public static void loadThumbnailInfo(final Photo photo) {
        if (photo == null) {
            return;
        }

        final ContentResolver resolver = App.getInstance().getContentResolver();
        Cursor cursor = MediaStore.Images.Thumbnails.queryMiniThumbnail(
                resolver, photo.getImageID(),
                THUMB_TYPE,
                null);
        if (cursor != null && cursor.getCount() > 0) {
            cursor.moveToFirst();
            String thumbPath = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Thumbnails.DATA));
            photo.setThumbPath(thumbPath);

            int thumbId = cursor.getInt(cursor.getColumnIndex(MediaStore.Images.Thumbnails._ID));
            photo.setThumbId(thumbId);

            File file = new File(thumbPath);
            if (!file.exists()) {
                forceCreateThumbnailAsync(resolver, photo.getImageID());
            }
        } else {
            forceCreateThumbnailAsync(resolver, photo.getImageID());
        }
        cursor.close();
    }


    /**
     * Force to create the thumbnail if it does not exits.
     *
     * @param resolver the content resolver.
     * @param id       the image id.
     */
    private static void forceCreateThumbnailAsync(final ContentResolver resolver, final int id) {
        if (App.getInstance().getCreateThumbnailsService().isTerminated()) {
            App.getInstance().setCreateThumbnailsService(Executors.newFixedThreadPool(10));
        }

        try {
            App.getInstance().getCreateThumbnailsService().execute(new Runnable() {
                @Override
                public void run() {
                    Bitmap bitmap = null;
                    try {
                        bitmap = forceCreateThumbnail(resolver, id);
                    } catch (Exception e) {
                    } finally {
                        if (bitmap != null && !bitmap.isRecycled()) {
                            bitmap.recycle();
                        }
                    }
                }
            });
        } catch (RejectedExecutionException ree) {
        }


    }

    /**
     * Create thumbnail if it does not exist or return it.
     *
     * @param resolver the content resolver.
     * @param id       the image id.
     * @return the Bitmap of the created thumbnail
     */
    private static Bitmap forceCreateThumbnail(final ContentResolver resolver, final int id) {
        Bitmap bitmap = null;
        try {
            bitmap = MediaStore.Images.Thumbnails.getThumbnail(resolver,
                    id, THUMB_TYPE,
                    App.getInstance().getOptionsLoadingThumbnail());
        } catch (Exception e) {

        }
        return bitmap;
    }
}
