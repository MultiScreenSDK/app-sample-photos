package com.samsung.appsamples.photos.model;

import android.os.Parcel;

public class Photo {

    private int imageID;
    private String imagePath;
    private int thumbId;
    private String thumbPath;
    private int bucketId;
    private String bucketName;
    private int dateTaken;
    private int orientation;

    public Photo(int id) {
        this.imageID = id;
    }

    public Photo(int id, String imagePath, int thumbId, String thumbPath, int bucketId, String bucketName, int dateTaken, int orientation) {
        this.imageID = id;
        this.imagePath = imagePath;
        this.thumbId = thumbId;
        this.thumbPath = thumbPath;
        this.bucketId = bucketId;
        this.bucketName = bucketName;
        this.dateTaken = dateTaken;
        this.orientation = orientation;
    }

    public Photo(Parcel source) {
        imageID = source.readInt();
        imagePath = source.readString();
        thumbPath = source.readString();
        bucketId = source.readInt();
        bucketName = source.readString();
        dateTaken = source.readInt();
    }

    public int getImageID() {
        return imageID;
    }

    public void setImageID(int imageID) {
        this.imageID = imageID;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public String getThumbPath() {
        return thumbPath;
    }

    public void setThumbPath(String thumbPath) {
        this.thumbPath = thumbPath;
    }


    public int getBucketId() {
        return bucketId;
    }

    public void setBucketId(int bucketId) {
        this.bucketId = bucketId;
    }

    public String getBucketName() {
        return bucketName;
    }

    public void setBucketName(String bucketName) {
        this.bucketName = bucketName;
    }

    public int getDateTaken() {
        return dateTaken;
    }

    public void setDateTaken(int dateTaken) {
        this.dateTaken = dateTaken;
    }


    public int getThumbId() {
        return thumbId;
    }

    public void setThumbId(int thumbId) {
        this.thumbId = thumbId;
    }


    /**
     * Get photo orientation.
     */
    public int getOrientation() {
        return orientation;
    }

    /**
     * Set photo orientation.
     * @param orientation the new orientation value.
     */
    public void setOrientation(int orientation) {
        this.orientation = orientation;
    }


    @Override
    public boolean equals(Object obj) {
        if (obj == null || !(obj instanceof Photo)) {
            return false;
        }

        //We compare image id, image path and date of taken.
        Photo p = (Photo) obj;

        boolean sameImagePath = false;
        if (p.imagePath == null && imagePath == null) {
            sameImagePath = true;
        } else if (p.imagePath != null && imagePath != null) {
            sameImagePath = p.imagePath.equals(imagePath);
        }

        return p.imageID == imageID && sameImagePath && p.dateTaken == dateTaken;
    }

}
