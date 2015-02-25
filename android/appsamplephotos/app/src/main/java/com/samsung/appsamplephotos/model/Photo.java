package com.samsung.appsamplephotos.model;

import android.graphics.Bitmap;
import android.net.Uri;

/**
 * Photo wrapper class
 */
public class Photo {

    // Photo id
    private int resourceId;

    // Has the path location of the picture
    public Uri uri;

    // Photo date taken
    public String date;

    // Used to set the thumbnail path
    public String thumb;

    // Used to set the picture bitmap (never used for this sample)
    private Bitmap image;

    // Picture name
    private String title;

    // Photo position into array
    private int position;

    /**
     * Photo constructor, required a title and image id.
     *
     * @param title
     * @param resourceId
     */
    public Photo(String title, int resourceId) {
        super();
        this.title = title;
        this.resourceId = resourceId;
    }

    // MARK - Image property Getter and Setter
    public Bitmap getImage() {
        return this.image;
    }

    public void setImage(Bitmap image) {
        this.image = image;
    }

    // MARK - Title property Getter and Setter
    public String getTitle() {
        return this.title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    // MARK - Created date property Getter and Setter
    public String getDate() {
        return this.date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    // MARK - Original picture path property Getter and Setter
    public Uri getUri() {
        return this.uri;
    }

    public void setUri(Uri uri) {
        this.uri = uri;
    }

    // MARK - Thumb path property Getter and Setter
    public String getThumb() {
        return this.thumb;
    }

    public void setThumb(String thumb) {
        this.thumb = thumb;
    }

    // MARK - Picture id property Getter
    public int getResourceId() {
        return this.resourceId;
    }

    // MARK - Position in the array property Getter and Setter
    public int getPosition() {
        return this.position;
    }

    public void setPosition(int position) {
        this.position = position;
    }

}