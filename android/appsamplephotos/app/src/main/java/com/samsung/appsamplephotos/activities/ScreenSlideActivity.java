package com.samsung.appsamplephotos.activities;

import android.net.Uri;
import android.os.AsyncTask;
import android.os.Handler;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.os.Bundle;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.adapters.ScreenSlidePagerAdapter;
import com.samsung.appsamplephotos.helpers.MultiScreenHelper;
import com.samsung.appsamplephotos.models.Photo;
import com.samsung.appsamplephotos.utils.Constants;
import com.samsung.appsamplephotos.utils.ZoomOutPageTransformer;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * This class handle the photo preview pager. If a connection is available
 * send the image to the device as a publish message
 */
public class ScreenSlideActivity extends BaseActivity {

    private ViewPager mPager;
    private PagerAdapter mPagerAdapter;

    // Id of the currently photo displayed
    private int photoId;

    // Position of the currently photo displayed
    private int currentPosition;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_screen_slide);

        setBackButton();

        // Set the activity in the base activity
        screenSlideActivity = this;

        // Try to get the photo id selected
        Bundle extras = getIntent().getExtras();
        if (extras !=null) photoId     =  (Integer) extras.get(Constants.PHOTO_ID);

        mPager = (ViewPager) findViewById(R.id.pager);
        mPagerAdapter = new ScreenSlidePagerAdapter(getSupportFragmentManager(),photoId);
        mPager.setAdapter(mPagerAdapter);
        mPager.setCurrentItem(photoId);

        // Prepare photo to send when activity start (send photo by default)
        prepareToSend(true);

        // Set the scroll effect
        mPager.setPageTransformer(true, new ZoomOutPageTransformer());

        // Set the page change listener
        mPager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int i, float v, int i2) {

            }

            @Override
            public void onPageSelected(int position) {

            }

            @Override
            public void onPageScrollStateChanged(int state) {
                // Prepare photo for send just the stop scrolling
                if (state == ViewPager.SCROLL_STATE_IDLE) {
                    prepareToSend(false);
                }
            }
        });
    }

    /**
     * Set back button in the action bar
     */
    public void setBackButton() {
        getActionBar().setHomeButtonEnabled(true);
        getActionBar().setIcon(getResources().getDrawable(R.drawable.ic_back));
    }

    /**
     * Prepare a image to convert to bytes and send to the client after time end only when a connection is set
     * @param onFirstTime
     */
    public void prepareToSend(boolean onFirstTime) {
        if (MultiScreenHelper.getInstance().getCastStatus() ==  MultiScreenHelper.castStatusTypes.CONNECTEDTOSERVICE) {
            final int position = mPager.getCurrentItem();
            if (position != currentPosition || onFirstTime) {
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

    /**
     * Async task to convert photo to bytes, when task finish publish a message to
     * the client
     */
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
            MultiScreenHelper.getInstance().publishToApplication(bytes);
        }

    }

    /**
     * Set current activity null in teh base activity when close preview pager
     */
    @Override
    protected void onStop() {
        super.onStop();
        screenSlideActivity = null;
    }
}
