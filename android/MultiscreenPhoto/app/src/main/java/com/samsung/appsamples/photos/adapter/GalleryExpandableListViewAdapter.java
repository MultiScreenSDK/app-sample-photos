/*******************************************************************************
 * Copyright (c) 2015 Samsung Electronics
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *******************************************************************************/

package com.samsung.appsamples.photos.adapter;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.samsung.appsamples.photos.ui.ActivityPhotoSlider;
import com.samsung.appsamples.photos.App;
import com.samsung.appsamples.photos.Constants;
import com.samsung.appsamples.photos.model.Gallery;
import com.samsung.appsamples.photos.model.Photo;
import com.samsung.appsamples.photos.R;
import com.samsung.appsamples.photos.util.DiskCacheManager;
import com.samsung.appsamples.photos.util.Util;
import com.samsung.multiscreen.util.RunUtil;

import java.io.File;


/**
 * The Gallery adapter.
 */
public class GalleryExpandableListViewAdapter extends BaseExpandableListAdapter {
    /** The context object */
    private final Context mContext;

    /** The screen width which is used to calculate the cell size. */
    private int width = 0;

    /** The width and height of thumbnails. */
    private int thumbnail_wh = 0;
    private LayoutInflater inflater;

    /** Reference to the gallery object. */
    Gallery gallery = App.getInstance().getGallery();

    public GalleryExpandableListViewAdapter(Context context) {
        mContext = context;

        //Update screen width and smallest thumbnail size.
        updateWidth();

        inflater = (LayoutInflater) context
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }


    @Override
    public int getGroupCount() {
        return gallery.size();
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        int counter = 0;

        //Get the photo bucket according to group position.
        Gallery.Bucket bucket = gallery.get(groupPosition);

        //Update the count according to bucket size.
        //One line has 5 photos.
        if (bucket != null) {
            counter = (int) Math.ceil(bucket.size() / 5.0);
        }

        //Return the children count.
        return counter;
    }

    @Override
    public Object getGroup(int groupPosition) {
        return gallery.get(groupPosition);
    }

    @Override
    public Object getChild(int groupPosition, int childPosition) {
        Photo child = null;

        //Get photo bucket object according to group position.
        Gallery.Bucket bucket = gallery.get(groupPosition);

        //Get child from child position.
        if (bucket != null && childPosition < bucket.size()) {
            child = bucket.get(childPosition);
        }
        return child;
    }

    @Override
    public long getGroupId(int groupPosition) {
        return groupPosition;
    }

    @Override
    public long getChildId(int groupPosition, int childPosition) {
        return childPosition;
    }

    @Override
    public boolean hasStableIds() {
        return false;
    }

    @Override
    public boolean isChildSelectable(int groupPosition, int childPosition) {
        return true;
    }


    private static class ViewHolder {
        public ImageView[] imageViews;
        public View fadeLine;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded, View convertView, ViewGroup parent) {

        //Get bucket title.
        String headerTitle = ((Gallery.Bucket) getGroup(groupPosition)).getName();
        if (convertView == null) {
            convertView = inflater.inflate(R.layout.header_gallery_layout_expandablelistview, null);
        }

        TextView lblListHeader = (TextView) convertView.findViewById(R.id.bucketTitle);
        ImageView fadeLine = (ImageView) convertView.findViewById(R.id.fadeLine);
        lblListHeader.setTypeface(Util.customFont(mContext));
        lblListHeader.setText(headerTitle);

        //Change visibility of bottom fade line.
        if (isExpanded) fadeLine.setVisibility(View.GONE);
        else fadeLine.setVisibility(View.VISIBLE);
        return convertView;
    }

    /**
     * Returns total amount of child types.
     */
    public int getChildTypeCount() {
        return 2;
    }

    public int getChildType(int groupPosition, int childPosition) {
        return (childPosition % 2) == 0 ? 0 : 1;
    }

    @Override
    public View getChildView(final int groupPosition, final int childPosition, boolean isLastChild, View convertView, ViewGroup parent) {
        ViewHolder holder = null;

        //Get child type.
        int itemType = getChildType(groupPosition, childPosition);

        if (convertView == null) {
            //Create a new ViewHolder.
            holder = new ViewHolder();

            //Load different according to child type.
            if ((itemType % 2) == 0) {
                convertView = inflater.inflate(R.layout.list_item, null);
            } else {
                convertView = inflater.inflate(R.layout.list_item2, null);
            }


            //Get UI components.
            holder.imageViews = new ImageView[5];
            holder.imageViews[0] = (ImageView) convertView.findViewById(R.id.image1);
            holder.imageViews[1] = (ImageView) convertView.findViewById(R.id.image2);
            holder.imageViews[2] = (ImageView) convertView.findViewById(R.id.image3);
            holder.imageViews[3] = (ImageView) convertView.findViewById(R.id.image4);
            holder.imageViews[4] = (ImageView) convertView.findViewById(R.id.image5);
            holder.fadeLine = convertView.findViewById(R.id.fadeLine);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        //Set cell properties.
        setCellProperties(itemType, holder);

        //Load thumbnails.
        loadPathImages(holder, groupPosition, childPosition);

        //Do not show the bottom line if it is the last child.
        if (isLastChild) holder.fadeLine.setVisibility(View.VISIBLE);
        else holder.fadeLine.setVisibility(View.GONE);

        return convertView;
    }

    /**
     * Update grid cell size.
     */
    private void setCellProperties(int itemType, ViewHolder holder) {
        if ((itemType % 2) == 0) {
            //The left side has a bigger square.
            holder.imageViews[0].getLayoutParams().height = thumbnail_wh * 2;

            //The right side has four small square.
            holder.imageViews[1].getLayoutParams().height = thumbnail_wh;
            holder.imageViews[2].getLayoutParams().height = thumbnail_wh;
            holder.imageViews[3].getLayoutParams().height = thumbnail_wh;
            holder.imageViews[4].getLayoutParams().height = thumbnail_wh;
        } else {
            //The left side has four small square. These are top two cells.
            holder.imageViews[0].getLayoutParams().height = thumbnail_wh;
            holder.imageViews[1].getLayoutParams().height = thumbnail_wh;

            //The right side has one bigger square.
            holder.imageViews[2].getLayoutParams().height = thumbnail_wh * 2;

            //The left side has four small square. These are bottom two cells.
            holder.imageViews[3].getLayoutParams().height = thumbnail_wh;
            holder.imageViews[4].getLayoutParams().height = thumbnail_wh;
        }

        //Update the image view to default settings.
        for (ImageView imageView : holder.imageViews) {
            setImageViewProperty(imageView);
        }
    }


    /**
     * Set property of image view to default.
     * @param imageView the image view object to be set.
     */
    private void setImageViewProperty(ImageView imageView) {
        //Set to display nothing.
        imageView.setImageDrawable(null);

        //Set background color.
        imageView.setBackgroundColor(mContext.getResources().getColor(R.color.background_cell_gray));
    }

    /**
     * Set the click listener for image view.
     * @param imageView the image view object to set listener.
     * @param groupPosition the bucket offset in Gallery.
     * @param offset the child offset in group.
     */
    public void setOnClickListener(ImageView imageView, final int groupPosition, final int offset) {

        //Set click listener for the image view object.
        imageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickItem(groupPosition, offset);
            }
        });
    }

    /**
     * Called when item is clicked. Will open slider screen.
     * @param groupPosition the bucket offset in Gallery.
     * @param offset the photo offset in bucket.
     */
    public void onClickItem(final int groupPosition, final int offset) {
        Intent intent = new Intent(mContext, ActivityPhotoSlider.class);
        intent.putExtra(Constants.GROUP_POSITION, groupPosition);
        intent.putExtra(Constants.PHOTO_OFFSET_IN_BUCKET, offset);
        mContext.startActivity(intent);
    }

    /**
     * Load the photo into image views.
     * @param holder the position holder.
     * @param groupPosition the bucket offset in Gallery.
     * @param childPosition the child position in the group.
     */
    private void loadPathImages(ViewHolder holder, int groupPosition, int childPosition) {
        Gallery.Bucket bucket = gallery.get(groupPosition);

        //Load image view one by one.
        if (bucket != null) {
            for (int i = 0; i <= 4; i++) {

                //Get image view from holder.
                final ImageView imageView = holder.imageViews[i];

                //Calculate the photo offset in bucket.
                int offset = childPosition * 5 + i;

                //Load the photo if the offset is within bucket.
                if (offset < bucket.size()) {
                    final Photo photo = bucket.get(offset);

                    RunUtil.runInBackground(new Runnable() {
                        @Override
                        public void run() {
                            loadImage(imageView, photo);
                        }
                    });
                    setOnClickListener(imageView, groupPosition, offset);
                } else {
                    //we remove the other images which does not exists any more.
                    setImageViewProperty(imageView);
                    imageView.setOnClickListener(null);
                }
            }
        }
    }

    @Override
    public void onGroupExpanded(int groupPosition) {
        super.onGroupExpanded(groupPosition);

        //Expand bucket.
        setBucketVisibility(groupPosition, true);
    }

    @Override
    public void onGroupCollapsed(int groupPosition) {
        super.onGroupCollapsed(groupPosition);

        //Collapse the bucket.
        setBucketVisibility(groupPosition, false);
    }


    /**
     * Update the bucket visibility.
     *
     * @param groupPosition the bucket offset in Gallery.
     * @param value         the visibility value.
     */
    private void setBucketVisibility(int groupPosition, boolean value) {
        if (groupPosition > gallery.size()) {
            return;
        }

        Gallery.Bucket bucket = gallery.get(groupPosition);
        bucket.setVisibility(value);
    }


    /**
     * Load photo into ImageView.
     *
     * @param imageView the ImageView object to show the photo.
     * @param photo     the photo to be loaded.
     */
    private void loadImage(final ImageView imageView, final Photo photo) {
        if (photo != null && imageView != null) {
            if (photo.getThumbPath() == null || photo.getThumbId() <= 0) {
                Gallery.loadThumbnailInfo(photo);
            }

            final String thumbnailPath = photo.getThumbPath();
            if (thumbnailPath != null) {
                //Log.d(Constants.APP_TAG, "loading thumbnail file name=" + photo.getThumbPath());

                //Try to load bitmap from disk cache first.
                Bitmap bitmap = App.getInstance().getDiskCacheManager().getBitmapFromDiskCache(Util.getThumbnailImageKey(thumbnailPath));
                if (bitmap != null) {
                    //loading thumbnail from disk cache.
                    loadBitmapToImageView(bitmap, imageView);
                } else {
                    File file = new File(thumbnailPath);

                    //Check if thumbnail file exists. Load thumbnail directly when it exists.
                    if (file.exists()) {
                        loadSampleDownImage(thumbnailPath, thumbnailPath, photo.getOrientation(), imageView);
                    } else {
                        //the path is stored in media store, but thumbnails are deleted.
                        //Load and scale down the original image.
                        loadSampleDownImage(photo.getImagePath(), thumbnailPath, photo.getOrientation(), imageView);
                    }
                }
            } else {
                loadSampleDownImage(photo.getImagePath(), thumbnailPath, photo.getOrientation(), imageView);
            }
        }

    }

    /**
     * Resize the full image and load resized image into ImageView.
     *
     * @param path      the path of the full image.
     * @param imageView the ImageView object to show the photo.
     */
    private void loadSampleDownImage(String path, String thumbnailPath, int orientation, final ImageView imageView) {
        if (path != null && imageView != null) {
            try {
                Bitmap bitmap = null;

                //This is for the bigger thumbnail.
                if (imageView.getLayoutParams().height == thumbnail_wh*2) {
                    bitmap = Util.decodeSampledBitmapFromFile(path,
                            Constants.TARGET_THUMBNAIL_SIZE*2, Constants.TARGET_THUMBNAIL_SIZE*2, true);
                } else {
                    bitmap = Util.decodeSampledBitmapFromFile(path,
                            Constants.TARGET_THUMBNAIL_SIZE, Constants.TARGET_THUMBNAIL_SIZE, true);
                }

                //Rotate the bitmap according to orientation.
                Bitmap bm = Util.rotateBitmap(orientation, bitmap);

                //Add the bitmap into disk cache.
                DiskCacheManager.addCompressedBitmapToCache(Util.getThumbnailImageKey(thumbnailPath), 65, bitmap);

                //Load the rotated bitmap into image view.
                loadBitmapToImageView(bm, imageView);
            } catch (OutOfMemoryError error) {
                //catch the out of memory error.
                System.gc();
            }
        }
    }

    /**
     * Load the bitmap into ImageView object.
     * @param bitmap the bitmap to be loaded.
     * @param imageView The image view object to display the bitmap.
     */
    private void loadBitmapToImageView(final Bitmap bitmap, final ImageView imageView) {
        RunUtil.runOnUI(new Runnable() {
            @Override
            public void run() {
                imageView.setImageBitmap(bitmap);
            }
        });
    }


    /**
     * Get current screen size and calculate the smallest thumbnail grid cell size.
     */
    public void updateWidth() {

        //Get the screen size.
        width = Util.getDisplaySize().x;

        //Calculate smallest thumbnail size.
        thumbnail_wh = width / 4;
    }
}
