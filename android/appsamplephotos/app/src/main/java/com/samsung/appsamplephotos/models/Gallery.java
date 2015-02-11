package com.samsung.appsamplephotos.models;

import java.util.ArrayList;

/**
 * Created by Koombea on 1/14/15.
 */
public class Gallery {
    public String id;
    public String name;
    public String date;
    public ArrayList<Photo> photos;
    public boolean isOpen;

    public Gallery(String id, String name, ArrayList<Photo> photos) {
        super();
        this.id = id;
        this.name = name;
        this.photos = photos;
    }

    public String getId() {
        return this.id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDate() {
        return this.date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public ArrayList<Photo> getPhotos() {
        return this.photos;
    }

    public void addPhoto(Photo photo) {
        this.photos.add(photo);
    }

    public void removePhoto(Photo photo) {
        this.photos.remove(photo);
    }

    public void clearPhotos() {
        this.photos.clear();
    }

}
