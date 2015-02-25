package com.samsung.appsamplephotos.helper;

import android.app.Activity;
import android.content.Context;
import android.database.Cursor;
import android.database.DatabaseUtils;
import android.net.Uri;
import android.provider.MediaStore;

import com.samsung.appsamplephotos.model.Gallery;
import com.samsung.appsamplephotos.model.Photo;
import com.samsung.appsamplephotos.util.Callback;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Helper for handle gallery, local images.
 */
public class PhotoHelper {

    private static PhotoHelper instance;
    private Context context;
    private Callback callback;

    // Array of galleries
    private ArrayList<Gallery> galleries = new ArrayList<Gallery>();

    public static final Uri sourceUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
    public static final Uri thumbUri = MediaStore.Images.Thumbnails.EXTERNAL_CONTENT_URI;
    public static final String thumb_DATA = MediaStore.Images.Thumbnails.DATA;
    public static final String thumb_IMAGE_ID = MediaStore.Images.Thumbnails.IMAGE_ID;

    /**
     * Return current PhotoHelper instance if not the instantiate a new one
     *
     * @return
     */
    public static PhotoHelper getInstance() {
        if (instance == null) {
            instance = new PhotoHelper();
        }
        return instance;
    }

    private PhotoHelper() {

    }

    /**
     * Initialize bucket/folder search
     *
     * @param context
     * @param callback
     */
    public void findBuckets(final Context context,final Callback callback) {
        this.context = context;
        this.callback = callback;
        if (context != null) getPhotoBuckets();
    }

    /**
     * Get galleries array by image's folder found
     */
    public void getPhotoBuckets() {

        Map<Integer, Gallery> map = new HashMap<Integer, Gallery>();
        galleries.clear();

        String[] columns = new String[] {
                MediaStore.Images.Media.BUCKET_ID,
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
                "count(*) AS count" };

        String BUCKET_GROUP_BY =
                "1) GROUP BY 1,(2";

        final String orderBy = MediaStore.Images.Media.BUCKET_DISPLAY_NAME + " ASC, MAX(datetaken) DESC";

        Cursor bucketCursor = context.getContentResolver().query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI, columns, BUCKET_GROUP_BY,
                null, orderBy);

        int BUCKET_NAME = bucketCursor
                .getColumnIndex(MediaStore.Images.Media.BUCKET_DISPLAY_NAME);
        int BUCKET_ID = bucketCursor
                .getColumnIndex(MediaStore.Images.Media.BUCKET_ID);
        int BUCKET_COUNT = bucketCursor
                .getColumnIndex("count");

        while (bucketCursor.moveToNext()) {
            Gallery data = new Gallery(bucketCursor.getString(BUCKET_ID),bucketCursor.getString(BUCKET_NAME),new ArrayList<Photo>());
            data.positionLoaded = 0;
            data.count = bucketCursor.getInt(BUCKET_COUNT);
            if (data.getName().equals("Camera")) {
                data.isOpen = true;
                map.put(0, data);
            } else {
                data.isOpen = false;
                map.put(bucketCursor.getPosition() + 1, data);
            }
        }

        galleries = new ArrayList<Gallery>(map.values());

        if (callback != null) callback.onSuccess();
    }

    public Cursor getPhotoCursor(Context context,String galleryId) {
        String[] projection = {MediaStore.Images.Media._ID,
                MediaStore.Images.Media.DISPLAY_NAME,
                MediaStore.Images.Media.MINI_THUMB_MAGIC,MediaStore.Images.Media.DATA,MediaStore.Images.ImageColumns._ID };
        final String selection = MediaStore.Images.ImageColumns.BUCKET_ID
                + " = " + DatabaseUtils.sqlEscapeString(galleryId);
        // Create the cursor pointing to the SDCard
        Cursor cursor = ((Activity)context).managedQuery( MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection, // Which columns to return
                selection,       // Return all rows
                null,
                null);
        return cursor;
    }

    /**
     * Return galleries array.
     * @return
     */
    public ArrayList<Gallery> getGalleries() {
        return galleries;
    }

    /**
     * Set an array of galleries
     * @param galleries
     */
    public void setGalleries(ArrayList<Gallery> galleries) {
        this.galleries = galleries;
    }

    /**
     * Return a gallery from galleries array by position
     * @param position
     * @return
     */
    public Gallery getGallery(int position) {
        return this.galleries.get(position);
    }

}
