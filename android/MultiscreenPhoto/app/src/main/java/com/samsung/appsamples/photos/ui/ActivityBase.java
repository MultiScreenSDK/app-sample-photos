/*******************************************************************************
 * Copyright (c) 2015 Samsung Electronics
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *******************************************************************************/


package com.samsung.appsamples.photos.ui;

import android.app.FragmentManager;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.text.Spannable;
import android.text.SpannableString;
import android.view.Menu;
import android.view.MenuItem;
import android.view.WindowManager;

import com.samsung.appsamples.photos.App;
import com.samsung.appsamples.photos.Constants;
import com.samsung.appsamples.photos.R;
import com.samsung.appsamples.photos.util.ConnectivityManager;
import com.samsung.appsamples.photos.util.TypefaceSpan;
import com.samsung.appsamples.photos.util.Util;

/**
 * Does the MultiScreen SDK method calls and establish a unique action bar and cast icon.
 * This class is inherited from other ActionBarActivity to reuse methods
 * for the action bar.
 */
public class ActivityBase extends ActionBarActivity implements ConnectivityManager.ServiceChangedListener {

    /** The request code */
    static final int PICK_SERVICE_REQUEST = 1;

    /** the cast menu */
    private MenuItem connectivityMenuItem;

    /**
     * Implements of ServiceChangedListener. Called when TV service is changed.
     */
    @Override
    public void onServiceChanged() {
        //Update cast icon accordingly.
        updateCastIconState();
    }

    /**
     * The icon status.
     */
    enum IconStatus {
        Connected, //TV is connected.
        Found,     //TV is found.
        Nothing    //No TV is found.
    }

    /**********************************************************************************************
     * Android Activity Lifecycle methods
     *********************************************************************************************/
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Set fullscreen the main window and the screen always visible
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        //Set up action bar properties.
        setActionBarProperties();

        //Add this activity to service change listener list.
        App.getInstance().getConnectivityManager().addServiceChangedListener(this);
    }

    public void onStart() {
        super.onStart();

        //Add this service change listener.
        App.getInstance().getConnectivityManager().addServiceChangedListener(this);

        //Start discovery if TV is not connected.
        if (!App.getInstance().getConnectivityManager().isTVConnected()) {
            //stop the discovery and start a new discovery.
            App.getInstance().getConnectivityManager().restartDiscovery();
        }

        //Increase the activity counter.
        App.getInstance().activityCounter++;

        //Update the cast icon.
        updateCastIconState();
    }

    public void onStop() {

        //Remove the service change listener.
        App.getInstance().getConnectivityManager().removeServiceChangedListener(this);

        //Decrease the activity counter.
        App.getInstance().activityCounter--;


        if (App.getInstance().activityCounter == 0) {
            //We know that app is moving to background.
            //Stop discovery.
            App.getInstance().getConnectivityManager().stopDiscovery();
        }
        super.onStop();
    }


    /**********************************************************************************************
     * Android Activity methods override
     *********************************************************************************************/

    /**
     * Called when configuration is changed such as screen rotation.
     * @param newConfig new configuration.
     */
    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        //Use default implementation.
        super.onConfigurationChanged(newConfig);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_activity_gallery, menu);

        // Set the cast icon in main menu
        connectivityMenuItem = menu.findItem(R.id.action_connectivity);

        //Update cast icon status.
        updateCastIconState();

        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Detect the menu item selected
        switch (item.getItemId()) {
            case R.id.action_connectivity:
                // Start Service fragment when cast icon is selected
                Intent intent = new Intent(getApplicationContext(), ActivityService.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
                startActivityForResult(intent, PICK_SERVICE_REQUEST);
                return true;
            case R.id.action_more:
                // Start More activity when more option is selected from the overflow menu
                Intent intentMore = new Intent(getApplicationContext(), ActivityMore.class);
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
            overridePendingTransition(0, 0);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // Check which request we're responding to
        if (requestCode == PICK_SERVICE_REQUEST) {

            // Make sure the request was successful
            if (resultCode == RESULT_OK) {
                //Returned from Service list screen.
                //Update cast icon.
                updateCastIconState();
            }
        }
    }


    /**********************************************************************************************
     * Private methods
     *********************************************************************************************/

    /**
     * Set the action bar properties like title, font type
     */
    private void setActionBarProperties() {
        //Disable the back button in actionbar.
        getSupportActionBar().setDisplayHomeAsUpEnabled(false);

        //Set the title with customized font.
        SpannableString s = new SpannableString(getResources().getString(R.string.activity_name));
        s.setSpan(new TypefaceSpan(this, Constants.FONT_ROBOTO_LIGHT), 0, s.length(),
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        getSupportActionBar().setTitle(s);
    }

    /**
     * Set the cast icon according of services status
     */
    private void setCastIcon(IconStatus status) {
        if (connectivityMenuItem != null) {
            switch (status) {
                case Connected:
                    //TV is connected, show the connected cast icon.
                    connectivityMenuItem.setVisible(true);
                    connectivityMenuItem.setIcon(getResources().getDrawable(R.drawable.ic_cast_on));
                    break;
                case Found:
                    //TV is found, show the cast icon.
                    connectivityMenuItem.setVisible(true);
                    connectivityMenuItem.setIcon(getResources().getDrawable(R.drawable.ic_cast_off));
                    break;
                case Nothing:
                    //TV is not found, hide the cast icon.
                    connectivityMenuItem.setVisible(false);
                    break;
                default:
                    //Other cases, hide the cast icon.
                    connectivityMenuItem.setVisible(false);
                    break;
            }
        }
    }

    /**
     * Update cast icon state.
     */
    private void updateCastIconState() {
        //Check if WiFi is connected.
        if (Util.isWiFiConnected()) {
            if (App.getInstance().getConnectivityManager().isTVConnected()) {
                //Update cast icon if TV is connected.
                setCastIcon(IconStatus.Connected);
            } else {
                if (App.getInstance().getConnectivityManager().getServiceAdapter().getCount() > 0) {
                    //One or more TV.
                    setCastIcon(IconStatus.Found);
                } else {
                    //Hide the cast icon.
                    setCastIcon(IconStatus.Nothing);
                }
            }
        } else {
            //Hide the cast icon when WiFi is not connected.
            setCastIcon(IconStatus.Nothing);
        }
    }

}
