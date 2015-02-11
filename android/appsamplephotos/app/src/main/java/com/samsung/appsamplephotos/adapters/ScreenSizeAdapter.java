package com.samsung.appsamplephotos.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.samsung.appsamplephotos.R;

import java.util.ArrayList;

/**
 * Created by Koombea on 1/14/15.
 */
public class ScreenSizeAdapter extends BaseAdapter {

    private ArrayList<String>  screenSize;
    private LayoutInflater inflater = null;

    public ScreenSizeAdapter(ArrayList<String> screenSize) {
        //inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
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
    public View getView(int position, View convertView, ViewGroup parent) {
        View row = convertView;
        if (row == null) {
            row                   = inflater.inflate(R.layout.cell_inch_layout, parent,false);
            ViewHolder holder                = new ViewHolder();
            holder.inchTextView = (TextView) row.findViewById(R.id.inchTextView);
            row.setTag(holder);
        }
        ViewHolder holder = (ViewHolder) row.getTag();
        String inch = screenSize.get(position);
        holder.inchTextView.setText(inch);
        return row;
    }

}
