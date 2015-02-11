package com.samsung.appsamplephotos.controllers;

import android.app.Activity;
import android.content.Context;
import android.content.CursorLoader;
import android.database.Cursor;
import android.database.DatabaseUtils;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.AsyncTask;
import android.provider.MediaStore;
import android.util.Log;

import com.samsung.appsamplephotos.models.Gallery;
import com.samsung.appsamplephotos.models.Photo;
import com.samsung.appsamplephotos.utils.Constants;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Created by Nestor on 1/21/15.
 */
public class PhotoController {

    private static PhotoController instance;
    private Activity activity;
    private Callback callback;
    private static ArrayList<Photo> arrayPhoto;
    private ArrayList<Gallery> galleries = new ArrayList<Gallery>();
    private static Gallery gallery;

    public static final Uri sourceUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
    public static final Uri thumbUri = MediaStore.Images.Thumbnails.EXTERNAL_CONTENT_URI;
    public static final String thumb_DATA = MediaStore.Images.Thumbnails.DATA;
    public static final String thumb_IMAGE_ID = MediaStore.Images.Thumbnails.IMAGE_ID;

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

    public void findBuckets(final Activity activity,final Callback callback) {
        this.activity = activity;
        this.callback = callback;
        if (activity != null) getPhotoBuckets();
        //adToGallery();
    }

    public static ArrayList<Photo> getImageInfos(Context context,String bucketId) {

        ArrayList<Photo> arrayPhoto = new ArrayList<Photo>();

        String[] imageColumns = { MediaStore.Images.Media._ID,
                MediaStore.Images.ImageColumns.DATA,
                MediaStore.Images.Media.DATE_TAKEN,
                MediaStore.Images.Media.DISPLAY_NAME,
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME};
        String[] thumbColumns = { thumb_DATA };

        final String orderBy = MediaStore.Images.Media._ID + " Desc";
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

    public void getPhotoBuckets() {

        Map<Integer, Gallery> map = new HashMap<Integer, Gallery>();
        galleries.clear();

        String[] columns = new String[] {
                MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
                MediaStore.Images.Media.BUCKET_ID };

        final String orderBy = MediaStore.Images.Media.BUCKET_ID + " ASC";

        Cursor bucketCursor = activity.getContentResolver().query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI, columns, null,
                null, orderBy);

        int BUCKET_NAME = bucketCursor
                .getColumnIndex(MediaStore.Images.Media.BUCKET_DISPLAY_NAME);
        int BUCKET_ID = bucketCursor
                .getColumnIndex(MediaStore.Images.Media.BUCKET_ID);

        while (bucketCursor.moveToNext()) {
            Gallery data = new Gallery(bucketCursor.getString(BUCKET_ID),bucketCursor.getString(BUCKET_NAME),new ArrayList<Photo>());
            map.put(Integer.parseInt(data.getId()), data);
        }

        galleries = new ArrayList<Gallery>(map.values());


        if (callback != null) callback.onSuccess();
    }

    /*public void adToGallery() {
        galleries.clear();
        Iterator it = hashMap.entrySet().iterator();
        if (it.hasNext()) {
            while (it.hasNext()) {
                Map.Entry e = (Map.Entry) it.next();
                Gallery gallery = new Gallery(e.getKey().toString(),e.getKey().toString(),(ArrayList<Photo>) e.getValue());
                gallery.setName(e.getKey().toString());
                galleries.add(gallery);
            }
        }
        callback.onSuccess();
    }*/

    public ArrayList<Gallery> getGalleries() {
        Log.e(Constants.APP_TAG,"Tamaño: " + arrayPhoto.size());
        return galleries;
    }

    public ArrayList<Photo> getPhotos() {
        arrayPhoto = gallery.getPhotos();
        return arrayPhoto;
    }

    /*public Photo getPhoto(Photo photo) {
        int index = arrayPhoto.indexOf(photo);
        return getPhotoByPosition(index);
    }*/

    public Photo getPhotoByPosition(int position) {
        arrayPhoto = gallery.getPhotos();
        return arrayPhoto.get(position);
    }

    public void setCurrentGallery(Gallery gallery) {
        this.gallery = gallery;
    }

    public Gallery getCurrentGallery() {
        return gallery;
    }
}
