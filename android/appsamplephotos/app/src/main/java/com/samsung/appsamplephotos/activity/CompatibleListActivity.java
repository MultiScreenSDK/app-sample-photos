package com.samsung.appsamplephotos.activity;

import android.content.Context;
import android.support.v4.app.FragmentActivity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.samsung.appsamplephotos.R;

import java.util.ArrayList;

import static com.samsung.appsamplephotos.util.Utils.*;

public class CompatibleListActivity extends FragmentActivity {

    private Button screenSizeBtn;
    private ListView inchesListView;
    private ListView modelListView;
    private TextView compatibleTextView;
    private RelativeLayout backgroundLayout;
    private ArrayList<String> inchesArray = new ArrayList();
    private ArrayList<String>  modelsArray = new ArrayList();
    private ModelAdapter adapterModel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_compatible_list);
        setupView();
    }

    public void setupView() {
        compatibleTextView = (TextView) findViewById(R.id.compatibleTextView);
        screenSizeBtn = (Button) findViewById(R.id.screenSizeBtn);
        inchesListView = (ListView) findViewById(R.id.inchesListView);
        modelListView = (ListView) findViewById(R.id.modelListView);
        backgroundLayout = (RelativeLayout) findViewById(R.id.backgroundLayout);
        backgroundLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
        screenSizeBtn.setTypeface(italicFont(this));
        compatibleTextView.setTypeface(customFont(this));

        // Get the inch list
        String [] screenSize = getResources().getStringArray(R.array.screen_sizes);
        for (String inch : screenSize) {
            inchesArray.add(inch);
        }

        ScreenSizeAdapter adapter = new ScreenSizeAdapter(inchesArray);
        inchesListView.setAdapter(adapter);

        screenSizeBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                screenSizeBtn.setText(getResources().getString(R.string.select_screen_size));
                modelListView.setVisibility(View.GONE);
                if (inchesListView.getVisibility() == View.VISIBLE) {
                    screenSizeBtn.setCompoundDrawablesWithIntrinsicBounds(null,null,getResources().getDrawable(R.drawable.ic_arrow_down),null);
                    inchesListView.setVisibility(View.GONE);
                } else {
                    screenSizeBtn.setCompoundDrawablesWithIntrinsicBounds(null,null,getResources().getDrawable(R.drawable.ic_arrow_up),null);
                    inchesListView.setVisibility(View.VISIBLE);
                }
            }
        });


        adapterModel = new ModelAdapter(modelsArray);
        modelListView.setAdapter(adapterModel);
    }

    private class ScreenSizeAdapter extends BaseAdapter {

        private ArrayList<String>  screenSize;

        private LayoutInflater inflater = null;


        public ScreenSizeAdapter(ArrayList<String> screenSize) {
            inflater = (LayoutInflater) CompatibleListActivity.this.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            this.screenSize = screenSize;
        }

        @Override
        public int getCount() {
            return this.screenSize.size();
        }

        @Override
        public Object getItem(int position) {
            return this.screenSize.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        private class ViewHolder {
            public TextView inchTextView;
        }

        @Override
        public View getView(final int position, View convertView, ViewGroup parent) {
            View row = convertView;
            ViewHolder holder;
            if (row == null) {
                row                   = inflater.inflate(R.layout.cell_inch_layout, parent,false);
                holder                = new ViewHolder();
                holder.inchTextView = (TextView) row.findViewById(R.id.inchTextView);
                row.setTag(holder);
            }
            holder = (ViewHolder) row.getTag();
            String inch = screenSize.get(position);
            holder.inchTextView.setText(inch);
            holder.inchTextView.setTypeface(customFont(CompatibleListActivity.this));
            holder.inchTextView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    inchesListView.setVisibility(View.GONE);
                    screenSizeBtn.setText(screenSize.get(position));
                    screenSizeBtn.setCompoundDrawablesWithIntrinsicBounds(null,null,getResources().getDrawable(R.drawable.ic_arrow_down),null);

                    String [] inches = getSizeValue(position);
                    modelsArray.clear();
                    for (String inch : inches) {
                        modelsArray.add(inch);
                    }
                    adapterModel.notifyDataSetChanged();
                    modelListView.setVisibility(View.VISIBLE);
                }
            });
            return row;
        }

    }

    private String[] getSizeValue(int position) {
        switch (position) {
            case 0:
                return getResources().getStringArray(R.array.models_10_inches);
            case 1:
                return getResources().getStringArray(R.array.models_20_inches);
            case 2:
                return getResources().getStringArray(R.array.models_30_inches);
            case 3:
                return getResources().getStringArray(R.array.models_30_inches);
            default:
                return getResources().getStringArray(R.array.screen_sizes);
        }
    }

    public class ModelAdapter extends BaseAdapter {

        private ArrayList<String>  models;
        private LayoutInflater inflater = null;

        public ModelAdapter(ArrayList<String> models) {
            inflater = (LayoutInflater) CompatibleListActivity.this.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            this.models = models;
        }

        @Override
        public int getCount() {
            return this.models.size();
        }

        @Override
        public Object getItem(int position) {
            return this.models.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        private class ViewHolder {
            public TextView inchTextView;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            View row = convertView;
            ViewHolder holder;
            if (row == null) {
                row                   = inflater.inflate(R.layout.cell_inch_layout, parent,false);
                holder                = new ViewHolder();
                holder.inchTextView = (TextView) row.findViewById(R.id.inchTextView);
                row.setTag(holder);
            }
            holder = (ViewHolder) row.getTag();
            String inch = models.get(position);
            holder.inchTextView.setText(inch);
            holder.inchTextView.setTypeface(customFont(CompatibleListActivity.this));
            return row;
        }

    }

}
