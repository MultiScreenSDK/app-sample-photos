package com.samsung.appsamplephotos.activities;

import android.app.Fragment;
import android.app.FragmentManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.Spannable;
import android.text.SpannableString;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.utils.Callback;
import com.samsung.appsamplephotos.fragments.GalleryFragment;
import com.samsung.appsamplephotos.models.Gallery;
import com.samsung.appsamplephotos.utils.Constants;
import com.samsung.appsamplephotos.utils.TypefaceSpan;

import java.util.ArrayList;

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

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        //No call for super(). Bug on API Level > 11.
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        setupView();
        gotoGuide();
    }

    public void setupView() {
        setActionBarProperties();
        new LoadGalleryTask().execute();
        prefs = getSharedPreferences(Constants.APP_PREFERENCES, Context.MODE_PRIVATE);
    }

    /**
     * Srt the action bar properties like title, font type
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

    /**
     * Set the gallery fragment in the screen
     */
    private void setFragmentView() {
        runOnUiThread(new Runnable() {
            public void run() {
                FragmentManager fragmentManager = getFragmentManager();
                Fragment newFragment = new GalleryFragment().newInstance();
                fragmentManager.beginTransaction()
                        .replace(R.id.container, newFragment)
                        .commit();
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
