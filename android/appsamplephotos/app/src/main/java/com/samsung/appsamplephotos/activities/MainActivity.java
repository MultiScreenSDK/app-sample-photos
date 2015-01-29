package com.samsung.appsamplephotos.activities;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.adapters.GalleryAdapter;
import com.samsung.appsamplephotos.controllers.Callback;
import com.samsung.appsamplephotos.controllers.MultiScreenController;
import com.samsung.appsamplephotos.controllers.PhotoController;
import com.samsung.appsamplephotos.fragments.ServiceFragment;
import com.samsung.appsamplephotos.models.Gallery;
import com.samsung.appsamplephotos.utils.Constants;
import com.samsung.multiscreen.Service;

import java.util.ArrayList;
import java.util.List;

import se.emilsjolander.stickylistheaders.ExpandableStickyListHeadersListView;
import se.emilsjolander.stickylistheaders.StickyListHeadersListView;


public class MainActivity extends Activity {

    private GalleryAdapter galleryAdapter;
    private ArrayList<Gallery> galleries = new ArrayList<Gallery>();
    private ExpandableStickyListHeadersListView galleryListView;
    private SharedPreferences prefs;
    private Menu menu;
    private MenuItem connectivityMenuItem;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        LocalBroadcastManager.getInstance(this).registerReceiver(mMessageReceiver,
                new IntentFilter(Constants.SERVICE_SELECTED));
        setupView();
        //gotoGuide();
    }

    public void setupView() {

        new findDevicesTask().execute();
        findPhotos();

        prefs = getSharedPreferences(Constants.APP_PREFERENCES, Context.MODE_PRIVATE);
        galleryListView = (ExpandableStickyListHeadersListView)findViewById(R.id.galleryListView);
        galleryListView.setOnHeaderClickListener(new StickyListHeadersListView.OnHeaderClickListener() {
            @Override
            public void onHeaderClick(StickyListHeadersListView l, View header, int itemPosition, long headerId, boolean currentlySticky) {
                if(galleryListView.isHeaderCollapsed(headerId)){
                    galleryListView.expand(headerId);
                }else {
                    galleryListView.collapse(headerId);
                }
            }
        });
    }

    protected void gotoGuide() {
        boolean welcomeGuide = prefs.getBoolean(Constants.APP_PREFERENCE_WELCOME_GUIDE, false);
        if(!welcomeGuide){
            Intent intent = new Intent(this, WelcomeActivity.class);
            startActivity(intent);
        }
    }

    public void reloadAdapter() {
        if (galleryAdapter != null) {
            galleryAdapter.notifyDataSetChanged();
        } else {
            galleryAdapter = new GalleryAdapter(this,galleries);
            galleryListView.setAdapter(galleryAdapter);
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_main, menu);
        this.menu = menu;
        connectivityMenuItem = menu.findItem(R.id.action_connectivity);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == R.id.action_connectivity) {
            if (MultiScreenController.getInstance().getCastStatus() != MultiScreenController.castStatusTypes.CONNECTEDTOSERVICE) {
                startActivity(new Intent(getApplicationContext(), ServiceFragment.class));
            } else {
                MultiScreenController.getInstance().disconnectApplication(new Callback() {
                    @Override
                    public void onSuccess() {
                        if (MultiScreenController.getInstance().getCastStatus() == MultiScreenController.castStatusTypes.SERVICESFOUND) {
                            connectivityMenuItem.setIcon(getResources().getDrawable(R.drawable.btn_cast_off));
                        } else if (MultiScreenController.getInstance().getCastStatus() == MultiScreenController.castStatusTypes.NOSERVICES) {
                            connectivityMenuItem.setVisible(false);
                        }
                    }

                    @Override
                    public void onError(Object error) {

                    }
                });
            }
            return true;
        }
        if (id == R.id.action_settings) {
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private class findDevicesTask extends AsyncTask<Void, Void, Void> {

        @Override
        protected Void doInBackground(Void... params) {
            findDevices();
            return null;
        }
    }

    private void findDevices() {
        MultiScreenController.getInstance().findServices(this, new Callback() {
            @Override
            public void onSuccess() {
                connectivityMenuItem.setVisible(true);
            }

            @Override
            public void onError(Object error) {
                if (MultiScreenController.getInstance().getServices().isEmpty()) {
                    MultiScreenController.getInstance().setCastStatus(MultiScreenController.castStatusTypes.NOSERVICES);
                    connectivityMenuItem.setVisible(false);
                }
            }
        });
        MultiScreenController.getInstance().startSearch();
    }

    private void findPhotos() {
        PhotoController.getInstance().findPhotos(this, new Callback() {
            @Override
            public void onSuccess() {
                galleries.clear();
                galleries = PhotoController.getInstance().getGalleries();
                reloadAdapter();
            }

            @Override
            public void onError(Object error) {

            }
        });
    }

    public void connectApplication() {
        MultiScreenController.getInstance().connectApplication(this, new Callback() {
            @Override
            public void onSuccess() {
                connectivityMenuItem.setIcon(getResources().getDrawable(R.drawable.btn_cast_on));
                launchApplication();
            }

            @Override
            public void onError(Object error) {

            }
        });
    }

    public void launchApplication() {
        MultiScreenController.getInstance().launchApplication(new Callback() {
            @Override
            public void onSuccess() {

            }

            @Override
            public void onError(Object error) {

            }
        });
    }

    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String service = intent.getStringExtra(Constants.SERVICE);
            connectApplication();
        }
    };

}