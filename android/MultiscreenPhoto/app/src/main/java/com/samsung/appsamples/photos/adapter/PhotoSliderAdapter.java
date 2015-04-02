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

import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;

import com.samsung.appsamples.photos.App;
import com.samsung.appsamples.photos.model.Gallery;
import com.samsung.appsamples.photos.ui.FragmentPhotoSlider;

public class PhotoSliderAdapter extends FragmentStatePagerAdapter {

    /** Display photos in this bucket. */
    Gallery.Bucket mBucket;

    public PhotoSliderAdapter(FragmentManager fm, int  bucketIndex) {
        super(fm);

        //Get bucket according to bucket index.
        Gallery gallery = App.getInstance().getGallery();
        if (bucketIndex < gallery.size()) {
            mBucket = gallery.get(bucketIndex);
        }
    }


    /**
     * Get fragment by give position.
     * @param position the position in adapter.
     * @return the fragment object.
     */
    @Override
    public FragmentPhotoSlider getItem(int position) {

        //Get the image path.
        String realPath = getImagePathAtPosition(position);

        //Get the FragmentPhotoSlider instance.
        FragmentPhotoSlider fragment = FragmentPhotoSlider.newInstance(realPath);

        return fragment;
    }

    @Override
    public int getCount() {
        return mBucket == null?0:mBucket.size();
    }

    /**
     * Get the image path at given position.
     * @param position the photo position.
     * @return the photo full path.
     */
    public String getImagePathAtPosition(int position) {
        String realPath = null;

        //Get the image path.
        if (mBucket != null && position<mBucket.size()) {
            realPath = mBucket.get(position).getImagePath();
        }

        return realPath;
    }
}