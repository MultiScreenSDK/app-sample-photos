package com.samsung.appsamplephotos.helpers;

import android.content.Context;
import android.database.Cursor;
import android.database.DatabaseUtils;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.provider.MediaStore;

import com.samsung.appsamplephotos.models.Gallery;
import com.samsung.appsamplephotos.models.Photo;
import com.samsung.appsamplephotos.utils.Callback;

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

    /**
     * Get images from a bucket by id. Set by param the limit of images and the offset
     *
     * @param context
     * @param gallery
     * @param limit
     * @param offset
     * @return
     */
    public static ArrayList<Photo>  getImageInfos(Context context,Gallery gallery, int limit, int offset) {

        // Retrieve the bucketId for query
        String bucketId = gallery.getId();

        // Instantiate an Array of photos
        ArrayList<Photo> arrayPhoto = new ArrayList<Photo>();

        // Set the columns projection
        String[] imageColumns = { MediaStore.Images.Media._ID,
                MediaStore.Images.ImageColumns.DATA,
                MediaStore.Images.Media.DATE_TAKEN,
                MediaStore.Images.Media.DISPLAY_NAME,
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME};
        String[] thumbColumns = { thumb_DATA };

        // Set the order by date desc, from limit and offset to make pagination
        final String orderBy = MediaStore.Images.Media.DATE_TAKEN + " Desc LIMIT " + String.valueOf(limit) + " OFFSET " + String.valueOf(offset);

        // Where clause, get the photos where the bucketId is equals to the requested bucket
        final String selection = MediaStore.Images.ImageColumns.BUCKET_ID
                + " = " + DatabaseUtils.sqlEscapeString(bucketId);

        // Establish a cursor for query over the external source (EXTERNAL_CONTENT_URI)
        Cursor imageCursor = context.getContentResolver().query(PhotoHelper.sourceUri,
                imageColumns,
                selection,
                null,
                orderBy);

        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;

        // Set the columns position
        int COLUMN_PATH = imageCursor.getColumnIndex(MediaStore.Images.Media.DATA);
        int COLUMN_NAME = imageCursor.getColumnIndex(MediaStore.Images.Media.DISPLAY_NAME);
        int COLUMN_BUCKET = imageCursor.getColumnIndex(MediaStore.Images.Media.BUCKET_DISPLAY_NAME);

        // Initialize the current position into photo array
        int position = gallery.getPhotos().size();

        // Check if photo has thumbnail, per each photo in the cursor.
        while (imageCursor.moveToNext()) {

            // Get the photo id
            int photoId = imageCursor.getInt(imageCursor.getColumnIndex(MediaStore.Images.Media._ID));

            // Get the micro thumbnail if exist
            Bitmap myBitmap = MediaStore.Images.Thumbnails.getThumbnail(context.getContentResolver(), photoId, MediaStore.Images.Thumbnails.MICRO_KIND, options);

            // If has bitmap then add a new photo object thumbnail to the photo array
            if (myBitmap != null) {
                myBitmap.recycle();

                // Get the image path
                String data = imageCursor.getString(COLUMN_NAME);

                // Establish a cursor query for thumbnail
                Cursor thumbCursor = context.getContentResolver().query(thumbUri,
                        thumbColumns,
                        thumb_IMAGE_ID + "=" + photoId,
                        null,
                        null);

                if (thumbCursor.moveToFirst()) {

                    // Get the thumbnail path location
                    String thumbPath = thumbCursor.getString(thumbCursor.getColumnIndex(thumb_DATA));

                    // Create a new photo object and set properties
                    Photo photo = new Photo(data,photoId);
                    photo.setUri(Uri.parse(imageCursor.getString(COLUMN_PATH)));
                    photo.setThumb(thumbPath);
                    photo.setTitle(imageCursor.getString(COLUMN_BUCKET));
                    photo.setPosition(position);

                    // Add a new photo
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
