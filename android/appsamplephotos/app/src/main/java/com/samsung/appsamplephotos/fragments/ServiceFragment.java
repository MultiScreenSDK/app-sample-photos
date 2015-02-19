package com.samsung.appsamplephotos.fragments;


import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.adapters.ServiceAdapter;
import com.samsung.appsamplephotos.utils.Callback;
import com.samsung.appsamplephotos.helpers.MultiScreenHelper;
import com.samsung.appsamplephotos.utils.Constants;
import com.samsung.multiscreen.Service;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import static com.samsung.appsamplephotos.utils.Utils.customFont;

/**
 * Display the list of services available, and check if there is a connection
 * established to a device.
 */
public class ServiceFragment extends FragmentActivity {

    private TextView selectedTextView;
    private TextView connectedToTextView;
    private ListView deviceListView;
    private List<Service> dataSource = new ArrayList<Service>();
    private ServiceAdapter adapter;
    private LinearLayout connectedToLayout;
    private LinearLayout containerLayout;
    private LinearLayout selectedToLayout;
    private TextView tvSelectedTextView;
    private RelativeLayout backgroundLayout;
    private Button disconnectButton;
    private View dividerBlackLine;
    private View dividerLine;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setFullScreen();
        setContentView(R.layout.fragment_service);

        setupScreenObjects();

        // Get the service list
        getServices();

        // Register service event broadcast
        LocalBroadcastManager.getInstance(this).registerReceiver(mMessageReceiver,
                new IntentFilter(Constants.SERVICE_EVENT));

        setupView();

        // Set Adapter
        reloadAdapter();
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
     * Set the screen objects and typeface
     */
    public void setupScreenObjects() {
        connectedToLayout = (LinearLayout) findViewById(R.id.connectedToLayout);
        connectedToTextView = (TextView) findViewById(R.id.connectedToTextView);
        tvSelectedTextView = (TextView) findViewById(R.id.tvSelectedTextView);
        disconnectButton = (Button) findViewById(R.id.disconnectButton);
        dividerBlackLine = findViewById(R.id.dividerBlackLine);
        dividerLine = findViewById(R.id.dividerLine);
        deviceListView = (ListView) findViewById(R.id.deviceListView);
        selectedTextView = (TextView) findViewById(R.id.selectedTextView);
        backgroundLayout = (RelativeLayout) findViewById(R.id.backgroundLayout);
        containerLayout = (LinearLayout) findViewById(R.id.connectedToLayout);
        selectedToLayout = (LinearLayout) findViewById(R.id.selectedToLayout);
        connectedToTextView.setTypeface(customFont(this));
        tvSelectedTextView.setTypeface(customFont(this));
        disconnectButton.setTypeface(customFont(this));
        selectedTextView.setTypeface(customFont(this));
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        return false;
    }

    /**
     * Get the service list from MultiScreen helper
     */
    public void getServices() {
        dataSource.clear();
        List<Service> services = MultiScreenHelper.getInstance().getServices();
        if (services != null) {
            Iterator<Service> it = services.iterator();
            while(it.hasNext()) {
                Service service = it.next();
                addServicesToData(service);
            }
            if (MultiScreenHelper.getInstance().getCastStatus().equals(MultiScreenHelper.castStatusTypes.CONNECTEDTOSERVICE)) {
                if (dataSource.isEmpty()) selectedToLayout.setVisibility(View.GONE);
                else selectedToLayout.setVisibility(View.VISIBLE);
            } else selectedToLayout.setVisibility(View.VISIBLE);
        }
    }

    /**
     * Add a service to the data source
     * @param service
     */
    public void addServicesToData(Service service) {
        if (MultiScreenHelper.getInstance().getService() != null) {
            if (!MultiScreenHelper.getInstance().getService().equals(service))
                dataSource.add(service);
        } else {
            dataSource.add(service);
        }
    }

    /**
     * Set listeners
     */
    public void setupView() {
        if (!MultiScreenHelper.getInstance().getCastStatus().equals(MultiScreenHelper.castStatusTypes.CONNECTEDTOSERVICE)) {
            setVisibilityTo(View.GONE);
            selectedTextView.setText(getResources().getString(R.string.select_tv));
            selectedToLayout.setBackgroundColor(getResources().getColor(R.color.gray));
        } else {
            setVisibilityTo(View.VISIBLE);
            selectedTextView.setText(getResources().getString(R.string.switch_to));
            selectedToLayout.setBackgroundColor(getResources().getColor(R.color.cell_gray));
            tvSelectedTextView.setText(MultiScreenHelper.getInstance().getService().getName());
        }
        disconnectButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                MultiScreenHelper.getInstance().disconnectApplication(new Callback() {
                    @Override
                    public void onSuccess() {
                        onDisconnectService();
                    }

                    @Override
                    public void onError(Object error) {

                    }
                });
            }
        });
        backgroundLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
        containerLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });
        selectedToLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });
    }

    private void setVisibilityTo(int visibility) {
        connectedToLayout.setVisibility(visibility);
        dividerBlackLine.setVisibility(visibility);
        dividerLine.setVisibility(visibility);
    }

    /**
     * Action when disconnected from service
     */
    private void onDisconnectService() {
        Intent intent = new Intent(Constants.SERVICE_SELECTED);
        intent.putExtra(Constants.SERVICE, Constants.NO_SERVICE);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
        onBackPressed();
    }

    @Override
    protected void onPause() {
        // Unregister when the activity is not visible
        LocalBroadcastManager.getInstance(this).unregisterReceiver(mMessageReceiver);
        super.onPause();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        overridePendingTransition(0,0);
    }

    /**
     * Set adapter if is null, instead do a notify data changed to update the service list
     */
    public void reloadAdapter() {
        runOnUiThread(new Runnable() {
            public void run() {
            if (adapter == null) {
                adapter = new ServiceAdapter(ServiceFragment.this, dataSource);
                deviceListView.setAdapter(adapter);
            } else {
                adapter.notifyDataSetChanged();
            }
            }
        });
    }

    /**
     * Action when a user select a service from list. Set the service in the MultiScreen helper
     * and send a local broadcast notification
     * @param service
     */
    public void selectedService(Service service) {
        if (MultiScreenHelper.getInstance().getCastStatus().equals(MultiScreenHelper.castStatusTypes.CONNECTEDTOSERVICE))
            MultiScreenHelper.getInstance().disconnectApplication(null);
        MultiScreenHelper.getInstance().setService(service);
        notifyServiceSelected(this,service);
        onBackPressed();
    }

    /**
     * Send local broadcast
     * @param activity
     * @param service
     */
    public void notifyServiceSelected(Activity activity, Service service) {
        Intent intent = new Intent(Constants.SERVICE_SELECTED);
        intent.putExtra(Constants.SERVICE, service.toString());
        LocalBroadcastManager.getInstance(activity).sendBroadcast(intent);
    }

    /**
     * On receive notification when a service status changed
     */
    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String service = intent.getStringExtra(Constants.SERVICE);
            Log.e(Constants.APP_TAG, "Event service: " + service);
            getServices();
            reloadAdapter();
        }
    };

}
