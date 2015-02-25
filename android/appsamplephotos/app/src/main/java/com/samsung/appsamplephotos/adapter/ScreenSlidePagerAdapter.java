package com.samsung.appsamplephotos.adapter;

import android.database.Cursor;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;

import com.samsung.appsamplephotos.fragment.ScreenSlidePageFragment;
import com.samsung.appsamplephotos.util.Constants;

/**
 * Created by Koombea on 1/21/15.
 */
public class  ScreenSlidePagerAdapter extends FragmentStatePagerAdapter {


    Cursor cursor;

    public ScreenSlidePagerAdapter(FragmentManager fm, Cursor cursor) {
        super(fm);
        this.cursor = cursor;
    }

    @Override
    public android.support.v4.app.Fragment getItem(int position) {
        ScreenSlidePageFragment fragment = new ScreenSlidePageFragment();
        if (cursor.moveToPosition(position)) {
            Bundle bundle = new Bundle();
            String path = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DATA));
            bundle.putString(Constants.PHOTO_ID,path);
            fragment.setArguments(bundle);
        }
        return fragment;
    }

    @Override
    public int getCount() {
        return cursor.getCount();
    }

}
