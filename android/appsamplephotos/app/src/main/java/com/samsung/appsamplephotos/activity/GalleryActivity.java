package com.samsung.appsamplephotos.activity;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.database.DatabaseUtils;
import android.os.AsyncTask;
import android.os.Bundle;
import android.provider.MediaStore;
import android.text.Spannable;
import android.text.SpannableString;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.widget.ExpandableListView;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.adapter.PhotoAdapter;
import com.samsung.appsamplephotos.helper.PhotoHelper;
import com.samsung.appsamplephotos.util.Callback;
import com.samsung.appsamplephotos.model.Gallery;
import com.samsung.appsamplephotos.util.Constants;
import com.samsung.appsamplephotos.util.TypefaceSpan;
import com.samsung.appsamplephotos.util.Utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * This is the main activity, make a request for buckets in the background task
 * and set the "Camera" bucket as default.
 *
 * Extends from BaseActivity in order to set the action bar and cast icon status. If first time launch
 * shows the Welcome page.
 */
public class GalleryActivity extends BaseActivity {

    private ArrayList<Gallery> galleries = new ArrayList<Gallery>();
    private SharedPreferences prefs;

    PhotoAdapter listAdapter;
    ExpandableListView expListView;

    List<String> listDataHeader;

    HashMap<String,Cursor> listDataChild;

    private Cursor cursor;
    /*
     * Column index for the Thumbnails Image IDs.
     */
    private int columnIndex;

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        //No call for super(). Bug on API Level > 11.
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        setFullScreen();
        setupView();
        gotoGuide();
    }

    public void setupView() {


        expListView = (ExpandableListView) findViewById(R.id.lvExp);
        setActionBarProperties();
        new LoadGalleryTask().execute();
        //getPhotoBuckets();
        prefs = getSharedPreferences(Constants.APP_PREFERENCES, Context.MODE_PRIVATE);

       // prepareListData();

    }

    private void expandGroups() {
        int count = 0;
        for (Gallery gallery :  galleries) {
            if (gallery.isOpen) expListView.expandGroup(count);
            count++;
        }
    }



    /**
     * Set the action bar properties like title, font type
     */
    private void setActionBarProperties() {
        getActionBar().setHomeButtonEnabled(false);
        getActionBar().setDisplayShowHomeEnabled(false);
        SpannableString s = new SpannableString(getResources().getString(R.string.action_bar_title));
        s.setSpan(new TypefaceSpan(this,Constants.FONT_ROBOTO_LIGHT), 0, s.length(),
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        getActionBar().setTitle(s);
    }

    /**
     * Hide the system status bar from screen
     */
    public void setFullScreen() {
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    /**
     * If first time launch shows the welcome page guide
     */
    protected void gotoGuide() {
        boolean welcomeGuide = prefs.getBoolean(Constants.APP_PREFERENCE_WELCOME_GUIDE, false);
        if(!welcomeGuide){
            Intent intent = new Intent(this, WelcomeActivity.class);
            startActivity(intent);
        }
    }

    /**
     * Method to get the buckets from external content uri, or get the cached galleries
     */
    private void getPhotoBuckets() {
        if ((photoHelper.getGalleries() != null) && (photoHelper.getGalleries().size() > 0)) {
            galleries = photoHelper.getGalleries();
            setFragmentView();
        } else {
            photoHelper.findBuckets(this, new Callback() {
                @Override
                public void onSuccess() {
                    galleries.clear();
                    galleries = photoHelper.getGalleries();
                    setFragmentView();
                }

                @Override
                public void onError(Object error) {

                }
            });
        }
    }
    private static final String TAG = "ImageGridActivity";


    /**
     * Set the gallery fragment in the screen
     */
    private void setFragmentView() {
        listDataHeader = new ArrayList<String>();
        //listDataChild = new HashMap<String, List<String>>();
        listDataChild = new HashMap<String, Cursor>();
        int count = 0;
        for (Gallery gallery : galleries) {
            // Adding child data
            listDataHeader.add(gallery.getName());

            cursor = PhotoHelper.getInstance().getPhotoCursor(this,gallery.getId());

            /*String[] projection = {MediaStore.Images.Media._ID,
                    MediaStore.Images.Media.DISPLAY_NAME,
                    MediaStore.Images.Media.MINI_THUMB_MAGIC,MediaStore.Images.Media.DATA,MediaStore.Images.ImageColumns._ID };
            final String selection = MediaStore.Images.ImageColumns.BUCKET_ID
                    + " = " + DatabaseUtils.sqlEscapeString(gallery.getId());
            // Create the cursor pointing to the SDCard
            cursor = managedQuery( MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                    projection, // Which columns to return
                    selection,       // Return all rows
                    null,
                    null);*/
            // Get the column index of the Thumbnails Image ID
            columnIndex = cursor.getColumnIndex(MediaStore.Images.Media.DATA);

            gallery.cursor = cursor;

            listDataChild.put(listDataHeader.get(count), cursor);
            count = count + 1;
        }

        PhotoHelper.getInstance().setGalleries(galleries);



        runOnUiThread(new Runnable() {
            public void run() {

                listAdapter = new PhotoAdapter(GalleryActivity.this, listDataHeader, listDataChild,columnIndex);

                expListView.setAdapter(listAdapter);

                expandGroups();

                ViewTreeObserver vto = expListView.getViewTreeObserver();

                vto.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
                    @Override
                    public void onGlobalLayout() {
                        if(android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.JELLY_BEAN_MR2) {
                            expListView.setIndicatorBounds(expListView.getRight()- Utils.getDipsFromPixel(GalleryActivity.this, 60), expListView.getWidth() - Utils.getDipsFromPixel(GalleryActivity.this, 20));
                        } else {
                            expListView.setIndicatorBoundsRelative(expListView.getRight() - Utils.getDipsFromPixel(GalleryActivity.this, 60), expListView.getWidth() - Utils.getDipsFromPixel(GalleryActivity.this, 20));
                        }
                    }
                });

            }
        });
    }

    /**
     * Get the buckets task
     */
    private class LoadGalleryTask extends AsyncTask<Void, Integer, Long> {

        protected Long doInBackground(Void... urls) {
            getPhotoBuckets();
            return null;
        }

    }

}
