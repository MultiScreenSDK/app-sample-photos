package com.samsung.appsamplephotos.activity;

import android.database.Cursor;
import android.database.DatabaseUtils;
import android.os.AsyncTask;
import android.os.Handler;
import android.provider.MediaStore;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.os.Bundle;
import android.view.View;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.adapter.ScreenSlidePagerAdapter;
import com.samsung.appsamplephotos.helper.MultiScreenHelper;
import com.samsung.appsamplephotos.helper.PhotoHelper;
import com.samsung.appsamplephotos.logger.Log;
import com.samsung.appsamplephotos.model.Gallery;
import com.samsung.appsamplephotos.util.Constants;
import com.samsung.appsamplephotos.util.ZoomOutPageTransformer;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import static android.view.View.*;

/**
 * This class handle the photo preview pager. If a connection is available
 * send the image to the device as a publish message
 */
public class ScreenSlideActivity extends BaseActivity implements OnClickListener {

    private ViewPager mPager;
    private PagerAdapter mPagerAdapter;

    // Id of the currently photo displayed
    //private int photoId;
    private int groupPosition;
    private int childPosition;

    // Position of the currently photo displayed
    private int currentPosition;

    private Cursor cursor;
    private Gallery gallery;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_screen_slide);

        setBackButton();

        // Set the activity in the base activity
        screenSlideActivity = this;

        // Try to get the photo id selected
        Bundle extras = getIntent().getExtras();
        //if (extras !=null) photoId     =  (Integer) extras.get(Constants.PHOTO_ID);
        if (extras !=null) {
            groupPosition     =  (Integer) extras.get(Constants.GROUP_POSITION);
            childPosition     =  (Integer) extras.get(Constants.CHILD_POSITION);
        }

        gallery = PhotoHelper.getInstance().getGallery(groupPosition);

        cursor = gallery.cursor;





        String[] projection = {MediaStore.Images.Media._ID,
                MediaStore.Images.Media.DISPLAY_NAME,
                MediaStore.Images.Media.MINI_THUMB_MAGIC,MediaStore.Images.Media.DATA,MediaStore.Images.ImageColumns._ID };
        final String selection = MediaStore.Images.ImageColumns.BUCKET_ID
                + " = " + DatabaseUtils.sqlEscapeString(gallery.getId());
        // Create the cursor pointing to the SDCard
        Cursor newCursor  = managedQuery( MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection, // Which columns to return
                selection,       // Return all rows
                null,
                null);

        mPager = (ViewPager) findViewById(R.id.pager);
        mPagerAdapter = new ScreenSlidePagerAdapter(getSupportFragmentManager(),newCursor);
        mPager.setAdapter(mPagerAdapter);
        mPager.setCurrentItem(childPosition);

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

        mPager.setOnSystemUiVisibilityChangeListener(
                new OnSystemUiVisibilityChangeListener() {
                    @Override
                    public void onSystemUiVisibilityChange(int vis) {
                        if ((vis & SYSTEM_UI_FLAG_LOW_PROFILE) != 0) {
                            getActionBar().hide();
                        } else {
                            getActionBar().show();
                        }
                    }
                });

        // Start low profile mode and hide ActionBar
        mPager.setSystemUiVisibility(SYSTEM_UI_FLAG_LOW_PROFILE);
        //getActionBar().hide();
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
            getIntent().putExtra(Constants.CHILD_POSITION,position);
            if (position != currentPosition || onFirstTime) {
                final Handler handler = new Handler();
                handler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        currentPosition = position;
                        Log.e(Constants.APP_TAG,"Esta posicion se jodio:" + String.valueOf(position) + " - Cursor size: " + String.valueOf(cursor.getCount()));
                        if (cursor.moveToPosition(position)) {
                            //Bundle bundle = new Bundle();
                            //photoIdSelected = PhotoHelper.getInstance().getGallery(_groupPosition).cursor;
                            String path = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DATA));
                            //bundle.putString(Constants.PHOTO_ID,path);
                            //fragment.setArguments(bundle);
                            new SendImageTask().execute(path);
                        }
                        //Photo photo = photoHelper.getPhotoByPosition(position);

                    }
                }, 500);
            }
        }
    }

    /**
     * Async task to convert photo to bytes, when task finish publish a message to
     * the client
     */
    private class SendImageTask extends AsyncTask<String, Void, byte[]> {

        @Override
        protected byte[] doInBackground(String... params) {
            byte[] data;
            try {
                final File file = new File(params[0]);
                int fileSize = (int) file.length();
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

    /**
     * Set on the ImageView in the ViewPager children fragments, to enable/disable low profile mode
     * when the ImageView is touched.
     */
    @Override
    public void onClick(View v) {
        final int vis = mPager.getSystemUiVisibility();
        if ((vis & SYSTEM_UI_FLAG_LOW_PROFILE) != 0) {
            mPager.setSystemUiVisibility(SYSTEM_UI_FLAG_VISIBLE);
        } else {
            mPager.setSystemUiVisibility(SYSTEM_UI_FLAG_LOW_PROFILE);
        }
    }
}
