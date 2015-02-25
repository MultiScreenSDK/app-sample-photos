package com.samsung.appsamplephotos.activity;

import android.app.FragmentManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.AsyncTask;
import android.support.v4.content.LocalBroadcastManager;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.util.Callback;
import com.samsung.appsamplephotos.helper.MultiScreenHelper;
import com.samsung.appsamplephotos.helper.PhotoHelper;
import com.samsung.appsamplephotos.fragment.ServiceFragment;
import com.samsung.appsamplephotos.util.Constants;

import android.os.Handler;

/**
 * Does the MultiScreen SDK method calls and establish a unique action bar and cast icon.
 * This class is inherited from other FragmentActivities to reuse methods
 * for the action bar.
 */
public class BaseActivity extends ActionBarActivity {

    private MenuItem connectivityMenuItem;
    public PhotoHelper photoHelper;
    public MultiScreenHelper msHelper;
    public ScreenSlideActivity screenSlideActivity;

    private static final int HIDE_ACTION_BAR_DELAY = 3000;
    private Runnable hideActionBarRunnable;
    private Handler hideActionBarHandler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Set fullscreen the main window and the screen always visible
        //getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
        //        WindowManager.LayoutParams.FLAG_FULLSCREEN);
        //getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        // Start find devices task
        new findDevicesTask().execute();

        // Register a local broadcast receiver to know when a service is selected
        LocalBroadcastManager.getInstance(this).registerReceiver(mMessageReceiver,
                new IntentFilter(Constants.SERVICE_SELECTED));

        // Register a local broadcast receiver to know when a service is detected or lost
        LocalBroadcastManager.getInstance(this).registerReceiver(mMessageReceiver,
                new IntentFilter(Constants.SERVICE_EVENT));

        photoHelper = PhotoHelper.getInstance();
        msHelper = MultiScreenHelper.getInstance();

        hideActionBarHandler = new Handler();
    }

    public void hideActionBar() {
        if (hideActionBarRunnable != null) {
            hideActionBarHandler.removeCallbacks(hideActionBarRunnable);
        }
        getSupportActionBar().hide();
    }

    public void showActionBar() {

        if (!getSupportActionBar().isShowing()) getSupportActionBar().show();

        if (hideActionBarRunnable != null) {
            hideActionBarHandler.removeCallbacks(hideActionBarRunnable);
        }

        hideActionBarRunnable = new Runnable() {
            @Override
            public void run() {
                getSupportActionBar().hide();
            }
        };

        hideActionBarHandler.postDelayed(hideActionBarRunnable, HIDE_ACTION_BAR_DELAY);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);

        // Set the cast icon in main menu
        connectivityMenuItem = menu.findItem(R.id.action_connectivity);
        setCastIcon();

        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Detect the menu item selected
        switch (item.getItemId()) {
            case R.id.action_connectivity:
                new findDevicesTask().execute();
                // Start Service fragment when cast icon is selected
                Intent intent = new Intent(getApplicationContext(), ServiceFragment.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
                startActivity(intent);
                return true;
            case R.id.action_more:
                // Start More activity when more option is selected from the overflow menu
                Intent intentMore = new Intent(getApplicationContext(), MoreActivity.class);
                intentMore.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
                startActivity(intentMore);
                return true;
            case android.R.id.home:
                // Go back when home/back icon is selected
                onBackPressed();
                break;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onBackPressed() {
        // Go back to the previous Fragment in BackStack or call super onBackPressed to close an Activity
        FragmentManager fm = getFragmentManager();
        if (fm.getBackStackEntryCount() > 0) {
            fm.popBackStack();
        } else {
            super.onBackPressed();
            overridePendingTransition(0,0);
        }
    }

    /**
     * Set the cast icon according of services status
     */
    public void setCastIcon() {
        if (connectivityMenuItem != null) {
            if (MultiScreenHelper.getInstance().getCastStatus() == MultiScreenHelper.castStatusTypes.SERVICESFOUND) {
                connectivityMenuItem.setVisible(true);
                connectivityMenuItem.setIcon(getResources().getDrawable(R.drawable.ic_cast_off));
            } else if (MultiScreenHelper.getInstance().getCastStatus() == MultiScreenHelper.castStatusTypes.CONNECTEDTOSERVICE) {
                connectivityMenuItem.setVisible(true);
                connectivityMenuItem.setIcon(getResources().getDrawable(R.drawable.ic_cast_on));
            } else if (MultiScreenHelper.getInstance().getCastStatus() == MultiScreenHelper.castStatusTypes.NOSERVICES) {
                connectivityMenuItem.setVisible(false);
            }
        }
    }

    /**
     * Calls connectApplication multiScreen helper method, pass by param the context and the callback
     * to get the response from the SDK.
     */
    public void connectApplication() {
        MultiScreenHelper.getInstance().connectApplication(this, new Callback() {
            @Override
            public void onSuccess() {
                // Connect to application successfully, update cast icon and launch the app on the client
                setCastIcon();
            }

            @Override
            public void onError(Object error) {
                // Connection to the application refused, try to get available devices in local network
                new findDevicesTask().execute();
            }
        });
    }

    /**
     * Task to start find devices
     */
    private class findDevicesTask extends AsyncTask<Void, Void, Void> {

        @Override
        protected Void doInBackground(Void... params) {
            findDevices();
            return null;
        }
    }

    /**
     * Call the findServices SDK method to start researching for clients in local network. It send the context
     * and a callback by param to know if there are clients available or not.
     * If there are detected devices the call onSuccess, if there are not detected devices the OnError callback.
     */
    private void findDevices() {
        MultiScreenHelper.getInstance().findServices(this, new Callback() {
            @Override
            public void onSuccess() {
                // Services detected, update cast icon
                setCastIcon();
            }

            @Override
            public void onError(Object error) {
                // Find devices fails
                MultiScreenHelper.getInstance().setCastStatus(MultiScreenHelper.castStatusTypes.NOSERVICES);
                setCastIcon();
            }
        });
        // Start search for available services in local network
        MultiScreenHelper.getInstance().startSearch();
    }

    /**
     * Receive notifications for service changes. In case the receive service is null starts
     * fin service and set the cast icon to change the status. Otherwise, establish connection
     * to the TV application.
     */
    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            setCastIcon();
            String service = intent.getStringExtra(Constants.SERVICE);
            if (intent.getAction().equals(Constants.SERVICE_EVENT)) {
                if (service == Constants.NO_SERVICE) {
                    new findDevicesTask().execute();
                    if (screenSlideActivity != null) screenSlideActivity.prepareToSend(true);
                }
            } else if (intent.getAction().equals(Constants.SERVICE_SELECTED)) {
                if (service != Constants.NO_SERVICE) {
                    connectApplication();
                }
            }
        }
    };
}