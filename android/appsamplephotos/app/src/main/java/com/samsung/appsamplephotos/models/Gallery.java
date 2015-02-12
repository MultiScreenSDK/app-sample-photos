package com.samsung.appsamplephotos.models;

import java.util.ArrayList;

/**
 * Gallery wrapper class
 */
public class Gallery {

    private String id;
    private String name;
    private ArrayList<Photo> photos;
    public int positionLoaded;
    public int count;
    public boolean isOpen;

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
