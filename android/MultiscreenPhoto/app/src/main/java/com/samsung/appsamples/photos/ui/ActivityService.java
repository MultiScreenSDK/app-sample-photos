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


import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.View;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.samsung.appsamples.photos.App;
import com.samsung.appsamples.photos.R;
import com.samsung.appsamples.photos.util.ConnectivityManager;
import com.samsung.appsamples.photos.util.Util;
import com.samsung.multiscreen.Service;

/**
 * Display the list of services available, and check if there is a connection
 * established to a device.
 */
public class ActivityService extends FragmentActivity implements ConnectivityManager.ServiceChangedListener {

    private TextView selectedTextView;
    private TextView connectedToTextView;
    private ListView deviceListView;
    private LinearLayout connectedToLayout;
    //private LinearLayout containerLayout;
    private LinearLayout selectedToLayout;
    private TextView tvSelectedTextView;
    private RelativeLayout backgroundLayout;
    private Button disconnectButton;
    private View dividerBlackLine;
    private View dividerLine;


    /**********************************************************************************************
     * Android Activity Lifecycle methods
     *********************************************************************************************/

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //Set to full screen.
        setFullScreen();
        setContentView(R.layout.fragment_service);

        //Set up UI views.
        setupScreenObjects();

        //Update the UI views.
        updateView();

        //Set device list adapter.
        deviceListView.setAdapter(App.getInstance().getConnectivityManager().getServiceAdapter());

        //Register itself to service change listener list.
        App.getInstance().getConnectivityManager().addServiceChangedListener(this);

        //Start to discovery service, to make the tv list updated.
        App.getInstance().getConnectivityManager().startDiscovery();
    }

    public void onDestroy() {
        super.onDestroy();

        //Remove itself from the service change listener list.
        App.getInstance().getConnectivityManager().removeServiceChangedListener(this);

        //If the TV is connected already, we will stop discovery when exit.
        if (App.getInstance().getConnectivityManager().isTVConnected()) {
            App.getInstance().getConnectivityManager().stopDiscovery();
        }
    }


    /**********************************************************************************************
     * Other methods
     *********************************************************************************************/

    /**
     * Hide the system status bar from screen
     */
    public void setFullScreen() {
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    /**
     * Set the screen objects and typeface
     */
    public void setupScreenObjects() {

        //Get UI components.
        connectedToLayout = (LinearLayout) findViewById(R.id.connectedToLayout);
        connectedToTextView = (TextView) findViewById(R.id.connectedToTextView);
        tvSelectedTextView = (TextView) findViewById(R.id.tvSelectedTextView);
        disconnectButton = (Button) findViewById(R.id.disconnectButton);
        dividerBlackLine = findViewById(R.id.dividerBlackLine);
        dividerLine = findViewById(R.id.dividerLine);
        deviceListView = (ListView) findViewById(R.id.deviceListView);
        selectedTextView = (TextView) findViewById(R.id.selectedTextView);
        backgroundLayout = (RelativeLayout) findViewById(R.id.backgroundLayout);
        selectedToLayout = (LinearLayout) findViewById(R.id.selectedToLayout);
        connectedToTextView.setTypeface(Util.customFont(this));
        tvSelectedTextView.setTypeface(Util.customFont(this));
        disconnectButton.setTypeface(Util.customFont(this));
        selectedTextView.setTypeface(Util.customFont(this));


        deviceListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapter, View v, int position,
                                    long arg3) {
                //One service is selected.
                selectedService(App.getInstance().getConnectivityManager().getServiceAdapter().getItem(position));
            }
        });

        //Set listener for disconnect button.
        disconnectButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //disconnect the connected service.
                selectedService(null);
            }
        });

        //Set listener for the background layout.
        //Will close the activity when the area out of dialog is clicked.
        backgroundLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });

    }



    /**
     * Update UI views.
     */
    public void updateView() {

        //When multiscreen App is null or it is not connected, only show TV list.
        if (App.getInstance().getConnectivityManager().getMultiscreenApp() == null ||
                !App.getInstance().getConnectivityManager().getMultiscreenApp().isConnected()) {
            setVisibilityTo(View.GONE);
            selectedTextView.setText(getResources().getString(R.string.select_tv));
            selectedToLayout.setBackgroundColor(getResources().getColor(R.color.gray));
        } else {
            setVisibilityTo(View.VISIBLE);
            selectedTextView.setText(getResources().getString(R.string.switch_to));
            selectedToLayout.setBackgroundColor(getResources().getColor(R.color.cell_gray));
            if (App.getInstance().getConnectivityManager().getService() != null)
                tvSelectedTextView.setText(App.getInstance().getConnectivityManager().getService().getName());
        }

        if (App.getInstance().getConnectivityManager().getMultiscreenApp() != null) {
            if (App.getInstance().getConnectivityManager().getServiceAdapter().getCount() == 0)
                selectedToLayout.setVisibility(View.GONE);
            else selectedToLayout.setVisibility(View.VISIBLE);
        } else selectedToLayout.setVisibility(View.VISIBLE);
    }

    /**
     * Set the visibility.
     * @param visibility the visibility value.
     */
    private void setVisibilityTo(int visibility) {

        //Update the visibility of connect to panel.
        connectedToLayout.setVisibility(visibility);

        //Update dividers.
        dividerBlackLine.setVisibility(visibility);
        dividerLine.setVisibility(visibility);
    }


    @Override
    public void onBackPressed() {
        setResult(RESULT_CANCELED);
        super.onBackPressed();
        overridePendingTransition(0, 0);
    }

    /**
     * Action when a user select a service from list. Set the service in the MultiScreen helper
     * and send a local broadcast notification
     *
     * @param service
     */
    public void selectedService(Service service) {

        //Update the selected service.
        App.getInstance().getConnectivityManager().setService(service);

        if (service == null) {
            //Disconnect current TV. We will start a new discovery.
            App.getInstance().getConnectivityManager().restartDiscovery();
        }

        //Set the return value in onActivityResult
        setResult(RESULT_OK);

        //Close this activity.
        finish();
    }


    @Override
    public void onServiceChanged() {
        //The service is changed. Update UI accordingly.
        updateView();
    }
}
