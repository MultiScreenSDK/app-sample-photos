package com.samsung.appsamplephotos.activities;

import android.app.FragmentManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.AsyncTask;
import android.support.v4.app.FragmentActivity;
import android.support.v4.content.LocalBroadcastManager;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.WindowManager;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.controllers.Callback;
import com.samsung.appsamplephotos.controllers.MultiScreenController;
import com.samsung.appsamplephotos.fragments.ServiceFragment;
import com.samsung.appsamplephotos.utils.Constants;

/**
 * Does the MultiScreen SDK method calls and establish a unique action bar and cast icon.
 * This class is inherited from other FragmentActivities to reuse methods
 * for the action bar.
 */
public class BaseActivity extends FragmentActivity {

    private MenuItem connectivityMenuItem;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Set fullscreen the main window and the screen always visible
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        // Start find devices task
        new findDevicesTask().execute();

        // Register a local broadcast receiver to know when a service is selected
        LocalBroadcastManager.getInstance(this).registerReceiver(mMessageReceiver,
                new IntentFilter(Constants.SERVICE_SELECTED));

        LocalBroadcastManager.getInstance(this).registerReceiver(mMessageReceiver,
                new IntentFilter(Constants.SERVICE_EVENT));
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
            if (MultiScreenController.getInstance().getCastStatus() == MultiScreenController.castStatusTypes.SERVICESFOUND) {
                connectivityMenuItem.setVisible(true);
                connectivityMenuItem.setIcon(getResources().getDrawable(R.drawable.ic_cast_off));
            } else if (MultiScreenController.getInstance().getCastStatus() == MultiScreenController.castStatusTypes.CONNECTEDTOSERVICE) {
                connectivityMenuItem.setVisible(true);
                connectivityMenuItem.setIcon(getResources().getDrawable(R.drawable.ic_cast_on));
            } else if (MultiScreenController.getInstance().getCastStatus() == MultiScreenController.castStatusTypes.NOSERVICES) {
                connectivityMenuItem.setVisible(false);
            }
        }
    }

    /**
     * Calls connectApplication multiScreen helper method, pass by param the context and the callback
     * to get the response from the SDK.
     */
    public void connectApplication() {
        MultiScreenController.getInstance().connectApplication(this, new Callback() {
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
        MultiScreenController.getInstance().findServices(this, new Callback() {
            @Override
            public void onSuccess() {
                // Services detected, update cast icon
                setCastIcon();
            }

            @Override
            public void onError(Object error) {
                // Find devices fails
                MultiScreenController.getInstance().setCastStatus(MultiScreenController.castStatusTypes.NOSERVICES);
                setCastIcon();
            }
        });
        // Start search for available services in local network
        MultiScreenController.getInstance().startSearch();
    }

    /*private void launchApplication() {
        MultiScreenController.getInstance().launchApplication(new Callback() {
            @Override
            public void onSuccess() {

            }

            @Override
            public void onError(Object error) {

            }
        });
    }*/

    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String service = intent.getStringExtra(Constants.SERVICE);
            if (service == "null") {
                new findDevicesTask().execute();
                setCastIcon();
            } else
                connectApplication();
        }
    };
}