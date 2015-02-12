package com.samsung.appsamplephotos.fragments;


import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Bundle;
import android.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.activities.BaseActivity;
import com.samsung.appsamplephotos.activities.MainActivity;
import com.samsung.appsamplephotos.adapters.ServiceAdapter;
import com.samsung.appsamplephotos.controllers.Callback;
import com.samsung.appsamplephotos.controllers.MultiScreenController;
import com.samsung.appsamplephotos.utils.Constants;
import com.samsung.multiscreen.Service;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import static com.samsung.appsamplephotos.utils.Utils.customFont;

/**
 * A simple {@link Fragment} subclass.
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
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.fragment_service);
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
        getServices();
        LocalBroadcastManager.getInstance(this).registerReceiver(mMessageReceiver,
                new IntentFilter(Constants.SERVICE_EVENT));
        setupView();
        reloadAdapter();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        return false;
    }

    public void getServices() {
        dataSource.clear();
        List<Service> services = MultiScreenController.getInstance().getServices();
        if (services != null) {
            Iterator<Service> it = services.iterator();
            while(it.hasNext()) {
                Service service = it.next();
                addServicesToData(service);
            }
            if (MultiScreenController.getInstance().getCastStatus().equals(MultiScreenController.castStatusTypes.CONNECTEDTOSERVICE)) {
                if (dataSource.isEmpty()) selectedToLayout.setVisibility(View.GONE);
                else selectedToLayout.setVisibility(View.VISIBLE);
            } else selectedToLayout.setVisibility(View.VISIBLE);
        }
    }

    public void addServicesToData(Service service) {
        if (MultiScreenController.getInstance().getService() != null) {
            if (!MultiScreenController.getInstance().getService().equals(service))
                dataSource.add(service);
        } else {
            dataSource.add(service);
        }
    }

    public void setupView() {
        if (!MultiScreenController.getInstance().getCastStatus().equals(MultiScreenController.castStatusTypes.CONNECTEDTOSERVICE)) {
            setVisibilityTo(View.GONE);
            selectedTextView.setText(getResources().getString(R.string.select_tv));
        } else {
            setVisibilityTo(View.VISIBLE);
            selectedTextView.setText(getResources().getString(R.string.switch_to));
            tvSelectedTextView.setText(MultiScreenController.getInstance().getService().getName());
        }
        disconnectButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                MultiScreenController.getInstance().disconnectApplication(new Callback() {
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

    private void onDisconnectService() {
        Intent intent = new Intent(Constants.SERVICE_SELECTED);
        intent.putExtra(Constants.SERVICE, Constants.NO_SERVICE);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
        onBackPressed();
    }

    @Override
    protected void onPause() {
        // Unregister since the activity is not visible
        LocalBroadcastManager.getInstance(this).unregisterReceiver(mMessageReceiver);
        super.onPause();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        overridePendingTransition(0,0);
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
        if (MultiScreenController.getInstance().getCastStatus().equals(MultiScreenController.castStatusTypes.CONNECTEDTOSERVICE))
            MultiScreenController.getInstance().disconnectApplication(null);
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
            getServices();
            reloadAdapter();
        }
    };

}
