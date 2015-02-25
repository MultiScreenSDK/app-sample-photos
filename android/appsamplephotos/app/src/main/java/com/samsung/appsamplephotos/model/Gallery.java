package com.samsung.appsamplephotos.model;

import android.database.Cursor;

import java.util.ArrayList;

/**
 * Gallery wrapper class
 */
public class Gallery {

    // Bucket id
    private String id;

    // Bucket name
    private String name;

    // Used to store the photo array
    private ArrayList<Photo> photos;

    // Number of the position loaded for pagination
    public int positionLoaded;

    // Keep the number of photos loaded in the main screen
    public int photoLoaded;

    // Used to store the number of bucket photos.
    public int count;

    // Property to check if the bucket windows is open or not in the display screen
    public boolean isOpen;

    public Cursor cursor;

    /**
     * Gallery constructor, required an id, a name and the array of
     * photos (it would be a empty array)
     *
     * @param id
     * @param name
     * @param photos
     */
    public Gallery(String id, String name, ArrayList<Photo> photos) {
        super();
        this.id = id;
        this.name = name;
        this.photos = photos;
    }

    // MARK - Id property Getter and Setter
    public String getId() {
        return this.id;
    }

    public void setId(String id) {
        this.id = id;
    }

    // MARK - Bucket name property Getter and Setter
    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    // MARK - Photos property Getter
    public ArrayList<Photo> getPhotos() {
        return this.photos;
    }

    // Add photo to the gallery array
    public void addPhoto(Photo photo) {
        this.photos.add(photo);
    }

    // Remove photo from the gallery array
    public void removePhoto(Photo photo) {
        this.photos.remove(photo);
    }

    // Clear photos from gallery
    public void clearPhotos() {
        this.photos.clear();
    }

}
