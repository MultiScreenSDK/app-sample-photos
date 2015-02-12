package com.samsung.appsamplephotos.controllers;

import android.content.Context;
import android.content.CursorLoader;
import android.database.Cursor;
import android.database.DatabaseUtils;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.provider.MediaStore;

import com.samsung.appsamplephotos.models.Gallery;
import com.samsung.appsamplephotos.models.Photo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Helper for handle gallery, local images.
 */
public class PhotoController {

    private static PhotoController instance;
    private Context context;
    private Callback callback;

    // Array of found photos
    private static ArrayList<Photo> arrayPhoto;

    // Array of galleries
    private ArrayList<Gallery> galleries = new ArrayList<Gallery>();

    // Current gallery
    private static Gallery gallery;

    public static final Uri sourceUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
    public static final Uri thumbUri = MediaStore.Images.Thumbnails.EXTERNAL_CONTENT_URI;
    public static final String thumb_DATA = MediaStore.Images.Thumbnails.DATA;
    public static final String thumb_IMAGE_ID = MediaStore.Images.Thumbnails.IMAGE_ID;

    /**
     * Return current PhotoController instance if not the instantiate a new one
     *
     * @return
     */
    public static PhotoController getInstance() {
        if (instance == null) {
            instance = new PhotoController();
        }
        return instance;
    }

    private PhotoController() {

    }

    static {
        arrayPhoto = new ArrayList<Photo>();
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
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
                MediaStore.Images.Media.BUCKET_ID };

        final String orderBy = MediaStore.Images.Media.BUCKET_ID + " ASC";

        Cursor bucketCursor = context.getContentResolver().query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI, columns, null,
                null, orderBy);

        int BUCKET_NAME = bucketCursor
                .getColumnIndex(MediaStore.Images.Media.BUCKET_DISPLAY_NAME);
        int BUCKET_ID = bucketCursor
                .getColumnIndex(MediaStore.Images.Media.BUCKET_ID);

        while (bucketCursor.moveToNext()) {
            Gallery data = new Gallery(bucketCursor.getString(BUCKET_ID),bucketCursor.getString(BUCKET_NAME),new ArrayList<Photo>());
            data.positionLoaded = 0;
            map.put(Integer.parseInt(data.getId()), data);
        }

        galleries = new ArrayList<Gallery>(map.values());


        if (callback != null) callback.onSuccess();
    }

    /**
     * Get images from a bucket by id. Set by param the limit of images and the offset
     *
     * @param context
     * @param bucketId
     * @param limit
     * @param offset
     * @return
     */
    public static ArrayList<Photo> getImageInfos(Context context,String bucketId, int limit, int offset) {

        ArrayList<Photo> arrayPhoto = new ArrayList<Photo>();

        String[] imageColumns = { MediaStore.Images.Media._ID,
                MediaStore.Images.ImageColumns.DATA,
                MediaStore.Images.Media.DATE_TAKEN,
                MediaStore.Images.Media.DISPLAY_NAME,
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME};
        String[] thumbColumns = { thumb_DATA };

        final String orderBy = MediaStore.Images.Media._ID + " Desc LIMIT " + offset + "," + limit;
        final String selection = MediaStore.Images.ImageColumns.BUCKET_ID
                + " = " + DatabaseUtils.sqlEscapeString(bucketId);

        CursorLoader cursorLoader = new CursorLoader(
                context,
                PhotoController.sourceUri,
                imageColumns,
                selection,
                null,
                orderBy);

        Cursor imageCursor = cursorLoader.loadInBackground();

        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;

        int COLUMN_PATH = imageCursor.getColumnIndex(MediaStore.Images.Media.DATA);
        int COLUMN_NAME = imageCursor.getColumnIndex(MediaStore.Images.Media.DISPLAY_NAME);
        int COLUMN_BUCKET = imageCursor.getColumnIndex(MediaStore.Images.Media.BUCKET_DISPLAY_NAME);
        int position = 0;
        while (imageCursor.moveToNext()) {
            int myID = imageCursor.getInt(imageCursor.getColumnIndex(MediaStore.Images.Media._ID));
            Bitmap myBitmap = MediaStore.Images.Thumbnails.getThumbnail(context.getContentResolver(), myID, MediaStore.Images.Thumbnails.MICRO_KIND, options);
            if (myBitmap != null) {
                myBitmap.recycle();
                String data = imageCursor.getString(COLUMN_NAME);

                CursorLoader thumbCursorLoader = new CursorLoader(
                        context,
                        thumbUri,
                        thumbColumns,
                        thumb_IMAGE_ID + "=" + myID,
                        null,
                        null);
                Cursor thumbCursor = thumbCursorLoader.loadInBackground();

                if (thumbCursor.moveToFirst()) {
                    String thumbPath = thumbCursor.getString(thumbCursor.getColumnIndex(thumb_DATA));

                    Photo photo = new Photo(data,myID);
                    photo.setUri(Uri.parse(imageCursor.getString(COLUMN_PATH)));
                    photo.setThumb(thumbPath);
                    photo.setTitle(imageCursor.getString(COLUMN_BUCKET));

                    photo.setPosition(position);

                    arrayPhoto.add(photo);
                    position++;
                }
                thumbCursor.close();
            }
        }

        imageCursor.close();

        return arrayPhoto;
    }

    /**
     * Return galleries array.
     *
     * @return
     */
    public ArrayList<Gallery> getGalleries() {
        return galleries;
    }

    /**
     * Setter to make default gallery
     *
     * @param gallery
     */
    public void setCurrentGallery(Gallery gallery) {
        this.gallery = gallery;
    }

    /**
     * Return current gallery
     *
     * @return
     */
    public Gallery getCurrentGallery() {
        return gallery;
    }

    /**
     * Get photo array of the current gallery
     *
     * @return
     */
    public ArrayList<Photo> getPhotos() {
        arrayPhoto = gallery.getPhotos();
        return arrayPhoto;
    }

    /**
     * Get photo from the photo array gallery by position
     * @param position
     * @return
     */
    public Photo getPhotoByPosition(int position) {
        arrayPhoto = gallery.getPhotos();
        return arrayPhoto.get(position);
    }

}
