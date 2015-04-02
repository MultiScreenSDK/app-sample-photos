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

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.samsung.appsamples.photos.R;
import com.samsung.appsamples.photos.util.Util;

import java.util.ArrayList;


public class ActivityCompatibleList extends FragmentActivity {
    private ListView modelListView;
    private TextView compatibleTextView;
    private RelativeLayout backgroundLayout;
    private ArrayList<String>  modelsArray = new ArrayList();
    private ModelAdapter adapterModel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_compatible_list);

        //Load Ui views.
        compatibleTextView = (TextView) findViewById(R.id.compatibleTextView);
        modelListView = (ListView) findViewById(R.id.modelListView);
        backgroundLayout = (RelativeLayout) findViewById(R.id.backgroundLayout);
        backgroundLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
        compatibleTextView.setTypeface(Util.customFont(this));
        String[] models = getResources().getStringArray(R.array.models_10_inches);
                for (String model : models) {
                    modelsArray.add(model);
        }

        //Create the adapter.
        adapterModel = new ModelAdapter(modelsArray);

        //Set the adapter.
        modelListView.setAdapter(adapterModel);
    }

    public class ModelAdapter extends BaseAdapter {
        private ArrayList<String>  models;
        private LayoutInflater inflater = null;

        public ModelAdapter(ArrayList<String> models) {
            inflater = (LayoutInflater) ActivityCompatibleList.this.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
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
                row                   = inflater.inflate(R.layout.item_compatible_tv, parent,false);
                holder                = new ViewHolder();
                holder.inchTextView = (TextView) row.findViewById(R.id.Model);
                row.setTag(holder);
            }
            holder = (ViewHolder) row.getTag();
            String inch = models.get(position);
            holder.inchTextView.setText(inch);
            holder.inchTextView.setTypeface(Util.customFont(ActivityCompatibleList.this));
            return row;
        }
    }
}
