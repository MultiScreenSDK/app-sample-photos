package com.samsung.appsamplephotos.controllers;

import android.app.Activity;
import android.database.Cursor;
import android.net.Uri;
import android.os.AsyncTask;
import android.provider.MediaStore;

import com.samsung.appsamplephotos.models.Gallery;
import com.samsung.appsamplephotos.models.Photo;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Created by Nestor on 1/21/15.
 */
public class PhotoController {

    private static PhotoController instance;
    private Activity activity;
    private Callback callback;
    private ArrayList<Photo> arrayPhoto = new ArrayList<Photo>();
    private ArrayList<Gallery> galleries = new ArrayList<Gallery>();

    public static PhotoController getInstance() {
        if (instance == null) {
            instance = new PhotoController();
        }
        return instance;
    }

    private PhotoController() {

    }

    public void findPhotos(final Activity activity,final Callback callback) {
        this.activity = activity;
        this.callback = callback;
        new LoadImagesTask().execute();
    }

    private class LoadImagesTask extends AsyncTask<Void, Void, Void> {
        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            arrayPhoto.clear();
        }

        @Override
        protected Void doInBackground(Void... params) {
            String[] projection = {
                    MediaStore.Images.Media._ID,
                    MediaStore.Images.Media.DATA,
                    MediaStore.Images.Media.DATE_TAKEN,
                    MediaStore.Images.Media.DISPLAY_NAME,
                    MediaStore.Images.Thumbnails.DATA,
                    MediaStore.Images.Media.BUCKET_DISPLAY_NAME
            };
            Cursor cursor = activity.getContentResolver().query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                    projection,
                    null,
                    null,
                    MediaStore.Images.Media._ID + " Desc");

            int COLUMN_ID = cursor.getColumnIndex(MediaStore.Images.Media._ID);
            int COLUMN_PATH = cursor.getColumnIndex(MediaStore.Images.Media.DATA);
            int COLUMN_DATE = cursor.getColumnIndex(MediaStore.Images.Media.DATE_TAKEN);
            int COLUMN_NAME = cursor.getColumnIndex(MediaStore.Images.Media.DISPLAY_NAME);
            int COLUMN_THUMB = cursor.getColumnIndex(MediaStore.Images.Thumbnails.DATA);
            int COLUMN_BUCKET = cursor.getColumnIndex(MediaStore.Images.Media.BUCKET_DISPLAY_NAME);

            if (cursor.getCount() > 0) {
                while (cursor.moveToNext()) {
                    int id = cursor.getInt(COLUMN_ID);
                    String data = cursor.getString(COLUMN_NAME);
                    Photo photo = new Photo(data,id);
                    photo.setUri(Uri.parse(cursor.getString(COLUMN_PATH)));
                    photo.setDate(cursor.getString(COLUMN_DATE));
                    photo.setThumb(cursor.getString(COLUMN_THUMB));
                    photo.setTitle(cursor.getString(COLUMN_BUCKET));
                    arrayPhoto.add(photo);
                }
            }
            return null;
        }

        @Override
        protected void onPostExecute(Void result) {
            groupImagesByDate();
        }
    }

    public void groupImagesByDate() {
        ConcurrentHashMap<String,ArrayList<Photo>> hashMap = new ConcurrentHashMap<String,ArrayList<Photo>>();
        ArrayList<Photo> photoArray;
        for (Photo photo : arrayPhoto) {
            photo.setPosition(arrayPhoto.indexOf(photo));
            Iterator it = hashMap.entrySet().iterator();
            if (it.hasNext()) {
                while (it.hasNext()) {
                    Map.Entry e = (Map.Entry) it.next();
                    if (photo.getTitle().equals(e.getKey().toString())) {
                        photoArray = (ArrayList<Photo>) e.getValue();
                        photoArray.add(photo);
                        hashMap.put(photo.getTitle(),photoArray);
                    } else {
                        if (!hashMap.containsKey(photo.getTitle())) {
                            photoArray = new ArrayList<Photo>();
                            photoArray.add(photo);
                            hashMap.put(photo.getTitle(), photoArray);
                        }
                    }
                    System.out.println(e.getKey() + " " + e.getValue());
                }
            } else {
                photoArray = new ArrayList<Photo>();
                photoArray.add(photo);
                hashMap.put(photo.getTitle(),photoArray);
            }
        }
        adToGallery(hashMap);
    }

    public void adToGallery(ConcurrentHashMap<String,ArrayList<Photo>> hashMap) {
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
    }

    public ArrayList<Gallery> getGalleries() {
        return galleries;
    }

    public ArrayList<Photo> getPhotos() {
        return arrayPhoto;
    }

    public Photo getPhoto(Photo photo) {
        int index = arrayPhoto.indexOf(photo);
        return getPhotoByPosition(index);
    }

    public Photo getPhotoByPosition(int position) {
        return arrayPhoto.get(position);
    }

}
