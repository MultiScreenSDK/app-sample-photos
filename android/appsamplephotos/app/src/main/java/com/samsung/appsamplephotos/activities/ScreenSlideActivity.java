package com.samsung.appsamplephotos.activities;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Handler;
import android.support.v4.app.FragmentActivity;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.adapters.ScreenSlidePagerAdapter;
import com.samsung.appsamplephotos.controllers.MultiScreenController;
import com.samsung.appsamplephotos.controllers.PhotoController;
import com.samsung.appsamplephotos.models.Photo;
import com.samsung.appsamplephotos.utils.Constants;
import com.samsung.appsamplephotos.utils.ZoomOutPageTransformer;

import java.io.ByteArrayOutputStream;
import java.io.File;

public class ScreenSlideActivity extends FragmentActivity {

    private ViewPager mPager;
    private PagerAdapter mPagerAdapter;
    private int photoId;
    private int currentPosition;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_screen_slide);

        Bundle extras = getIntent().getExtras();
        if (extras !=null) photoId     =  (Integer) extras.get(Constants.PHOTO_ID);

        mPager = (ViewPager) findViewById(R.id.pager);
        mPagerAdapter = new ScreenSlidePagerAdapter(getSupportFragmentManager(),photoId);
        mPager.setAdapter(mPagerAdapter);
        mPager.setCurrentItem(photoId);
        prepareToSend();
        mPager.setPageTransformer(true, new ZoomOutPageTransformer());
        mPager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int i, float v, int i2) {
                //Log.e(Constants.APP_TAG,"onPageScrolled");
            }

            @Override
            public void onPageSelected(int position) {
                Log.e(Constants.APP_TAG,"onPageSelected");
            }

            @Override
            public void onPageScrollStateChanged(int state) {
                if (state == ViewPager.SCROLL_STATE_IDLE) {
                    Log.e(Constants.APP_TAG, "SCROLL_STATE_IDLE");
                    prepareToSend();
                }
            }
        });
    }

    public void prepareToSend() {
        if (MultiScreenController.getInstance().getCastStatus() ==  MultiScreenController.castStatusTypes.CONNECTEDTOSERVICE) {
            final int position = mPager.getCurrentItem();
            if (position != currentPosition) {
                final Handler handler = new Handler();
                handler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        currentPosition = position;
                        Photo photo = PhotoController.getInstance().getPhotoByPosition(position);
                        Uri uri = photo.getUri();
                        new sendImageTask().execute(uri);
                    }
                }, 500);
            }
        }
    }

    private class sendImageTask extends AsyncTask<Uri, Void, byte[]> {

        @Override
        protected byte[] doInBackground(Uri... params) {
            byte[] data;
            try {
                Uri uri = params[0];
                Bitmap bmp = BitmapFactory.decodeFile(uri.toString());

                ByteArrayOutputStream bos = new ByteArrayOutputStream();
                bmp.compress(Bitmap.CompressFormat.JPEG, 80, bos);
                bmp.recycle();
                data = bos.toByteArray();
            } catch (OutOfMemoryError e) {
                Log.e(Constants.APP_TAG,"OutofMemory handled");
                data = null;
            }
            return data;
        }

        @Override
        protected void onPostExecute(byte[] bytes) {
            super.onPostExecute(bytes);
            MultiScreenController.getInstance().publishToApplication(bytes);
        }

    }

}
