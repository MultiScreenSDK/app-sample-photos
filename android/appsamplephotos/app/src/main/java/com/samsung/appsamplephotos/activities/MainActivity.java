package com.samsung.appsamplephotos.activities;

import android.app.Fragment;
import android.app.FragmentManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.text.Spannable;
import android.text.SpannableString;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.controllers.Callback;
import com.samsung.appsamplephotos.controllers.PhotoController;
import com.samsung.appsamplephotos.fragments.GalleryFragment;
import com.samsung.appsamplephotos.models.Gallery;
import com.samsung.appsamplephotos.utils.Constants;
import com.samsung.appsamplephotos.utils.TypefaceSpan;
import com.samsung.multiscreen.util.RunUtil;

import java.util.ArrayList;

/**
 *
 */
public class MainActivity extends BaseActivity {

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

        RunUtil.runInBackground(new Runnable() {

            @Override
            public void run() {
                getPhotoBuckets();
            }

        });

        runOnUiThread(new Runnable() {
              public void run() {
              }
          });

        prefs = getSharedPreferences(Constants.APP_PREFERENCES, Context.MODE_PRIVATE);
    }

    private void setActionBarProperties() {
        getActionBar().setHomeButtonEnabled(false);
        getActionBar().setDisplayShowHomeEnabled(false);
        SpannableString s = new SpannableString(getResources().getString(R.string.action_bar_title));
        s.setSpan(new TypefaceSpan(this,Constants.FONT_ROBOTO_LIGHT), 0, s.length(),
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        getActionBar().setTitle(s);
    }

    protected void gotoGuide() {
        boolean welcomeGuide = prefs.getBoolean(Constants.APP_PREFERENCE_WELCOME_GUIDE, false);
        if(!welcomeGuide){
            Intent intent = new Intent(this, WelcomeActivity.class);
            startActivity(intent);
        }
    }

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

    private void setFragmentView() {
        FragmentManager fragmentManager = getFragmentManager();
        Fragment newFragment = new GalleryFragment().newInstance();
        fragmentManager.beginTransaction()
                .replace(R.id.container, newFragment)
                .commit();
    }

}
