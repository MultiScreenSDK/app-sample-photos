package com.samsung.appsamplephotos.activities;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Handler;
import android.provider.MediaStore;
import android.support.v4.app.FragmentActivity;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.WindowManager;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.adapters.ScreenSlidePagerAdapter;
import com.samsung.appsamplephotos.controllers.MultiScreenController;
import com.samsung.appsamplephotos.controllers.PhotoController;
import com.samsung.appsamplephotos.fragments.ServiceFragment;
import com.samsung.appsamplephotos.models.Photo;
import com.samsung.appsamplephotos.utils.Constants;
import com.samsung.appsamplephotos.utils.ZoomOutPageTransformer;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

import static android.graphics.Bitmap.*;

public class ScreenSlideActivity extends BaseActivity {

    private ViewPager mPager;
    private PagerAdapter mPagerAdapter;
    private int photoId;
    private int currentPosition;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_screen_slide);

        getActionBar().setHomeButtonEnabled(true);
        getActionBar().setIcon(getResources().getDrawable(R.drawable.ic_back));


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

            }

            @Override
            public void onPageSelected(int position) {

            }

            @Override
            public void onPageScrollStateChanged(int state) {
                if (state == ViewPager.SCROLL_STATE_IDLE) {
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
                        Photo photo = photoHelper.getPhotoByPosition(position);
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
                final File file = new File(uri.getPath());
                int fileSize = (int)file.length();
                data = new byte[fileSize];
                InputStream is = new BufferedInputStream(new FileInputStream(file));
                is.read(data, 0, fileSize);
                is.close();
            } catch (IOException e) {
                data = null;
            } catch (Exception e) {
                e.printStackTrace();
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
