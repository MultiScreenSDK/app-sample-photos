package com.samsung.appsamplephotos.fragments;


import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.activities.MainActivity;
import com.samsung.appsamplephotos.adapters.ServiceAdapter;
import com.samsung.appsamplephotos.controllers.Callback;
import com.samsung.appsamplephotos.controllers.MultiScreenController;
import com.samsung.appsamplephotos.utils.Constants;
import com.samsung.multiscreen.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * A simple {@link Fragment} subclass.
 */
public class ServiceFragment extends FragmentActivity {

    private ProgressBar loadingIndicator;
    private TextView welcomeLabel;
    private ListView deviceListView;
    private List<Service> dataSource = new ArrayList<Service>();
    private ServiceAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.fragment_service);

        deviceListView = (ListView) findViewById(R.id.deviceListView);
        loadingIndicator = (ProgressBar) findViewById(R.id.loadingIndicator);
        welcomeLabel = (TextView) findViewById(R.id.welcome_label);
        dataSource.clear();
        List<Service> services = MultiScreenController.getInstance().getServices();
        if (services != null) dataSource.addAll(services);
        LocalBroadcastManager.getInstance(this).registerReceiver(mMessageReceiver,
                new IntentFilter(Constants.SERVICE_EVENT));
        reloadAdapter();
    }

    @Override
    protected void onPause() {
        // Unregister since the activity is not visible
        LocalBroadcastManager.getInstance(this).unregisterReceiver(mMessageReceiver);
        super.onPause();
    }

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

    public void selectedService(Service service) {
        MultiScreenController.getInstance().setService(service);
        notifyServiceSelected(this,service);
        onBackPressed();
    }

    public void notifyServiceSelected(Activity activity, Service service) {
        Intent intent = new Intent(Constants.SERVICE_SELECTED);
        intent.putExtra(Constants.SERVICE, service.toString());
        LocalBroadcastManager.getInstance(activity).sendBroadcast(intent);
    }

    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String service = intent.getStringExtra(Constants.SERVICE);
            Log.e(Constants.APP_TAG, "Event service: " + service);
            dataSource.clear();
            List<Service> services = MultiScreenController.getInstance().getServices();
            if (services != null) dataSource.addAll(services);
            reloadAdapter();
        }
    };

}
