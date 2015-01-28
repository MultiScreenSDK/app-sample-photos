package com.samsung.appsamplephotos.adapters;

import android.app.Fragment;

import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;

import com.samsung.appsamplephotos.controllers.PhotoController;
import com.samsung.appsamplephotos.fragments.ScreenSlidePageFragment;
import com.samsung.appsamplephotos.models.Photo;
import com.samsung.appsamplephotos.utils.Constants;

/**
 * Created by Nestor on 1/21/15.
 */
public class  ScreenSlidePagerAdapter extends FragmentStatePagerAdapter {

    int photoIdSelected;

    public ScreenSlidePagerAdapter(FragmentManager fm, int photoId) {
        super(fm);
        photoIdSelected = photoId;
    }

    @Override
    public android.support.v4.app.Fragment getItem(int position) {
        ScreenSlidePageFragment fragment = new ScreenSlidePageFragment();
        Bundle bundle = new Bundle();
        photoIdSelected = PhotoController.getInstance().getPhotos().get(position).getPosition();
        bundle.putInt(Constants.PHOTO_ID,photoIdSelected);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public int getCount() {
        return PhotoController.getInstance().getPhotos().size();
    }
}
