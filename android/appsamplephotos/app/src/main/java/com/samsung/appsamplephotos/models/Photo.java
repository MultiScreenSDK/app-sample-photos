package com.samsung.appsamplephotos.models;

import android.graphics.Bitmap;
import android.net.Uri;

/**
 * Created by Koombea on 1/14/15.
 */
public class Photo {

    private int resourceId;
    public Uri uri;
    public String date;
    public String thumb;
    private Bitmap image;
    private String title;
    private int position;

    public Photo(String title, int resourceId) {
        super();
        this.title = title;
        this.resourceId = resourceId;
    }

    public Bitmap getImage() {
        return this.image;
    }

    public void setImage(Bitmap image) {
        this.image = image;
    }

    public String getTitle() {
        return this.title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDate() {
        return this.date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public Uri getUri() {
        return this.uri;
    }

    public void setUri(Uri uri) {
        this.uri = uri;
    }

    public String getThumb() {
        return this.thumb;
    }

    public void setThumb(String thumb) {
        this.thumb = thumb;
    }

    public int getResourceId() {
        return this.resourceId;
    }

    public void setPosition(int position) {
        this.position = position;
    }

    public int getPosition() {
        return this.position;
    }
}
