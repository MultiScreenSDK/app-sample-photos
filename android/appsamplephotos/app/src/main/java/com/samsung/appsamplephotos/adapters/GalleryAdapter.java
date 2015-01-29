package com.samsung.appsamplephotos.adapters;

import android.content.Context;
import android.graphics.Point;
import android.graphics.drawable.Drawable;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.StaggeredGridLayoutManager;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.models.Gallery;

import org.lucasr.twowayview.widget.DividerItemDecoration;
import org.lucasr.twowayview.widget.TwoWayView;

import java.util.ArrayList;

import se.emilsjolander.stickylistheaders.StickyListHeadersAdapter;

/**
 * Created by Koombea on 1/14/15.
 */
public class GalleryAdapter extends BaseAdapter implements StickyListHeadersAdapter {

    private LayoutInflater inflater;
    private Context context;
    private ArrayList<Gallery> galleries;

    public GalleryAdapter(Context context, ArrayList<Gallery> galleries){
        inflater        = LayoutInflater.from(context);
        this.context    = context;
        this.galleries  = galleries;
    }

    @Override
    public int getCount() {
        return galleries.size();
    }

    @Override
    public Object getItem(int position) {
        return galleries.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getHeaderView(int position, View convertView, ViewGroup viewGroup) {
        HeaderViewHolder holder;
        if (convertView == null) {
            holder = new HeaderViewHolder();
            convertView = inflater.inflate(R.layout.header_gallery_layout, viewGroup, false);
            holder.headerTitle = (TextView) convertView.findViewById(R.id.headerTitle);
            convertView.setTag(holder);
        } else {
            holder = (HeaderViewHolder) convertView.getTag();
        }
        Gallery gallery = galleries.get(position);
        holder.headerTitle.setText(gallery.getName().toString());
        return convertView;
    }

    @Override
    public long getHeaderId(int i) {
        return i;
    }

    static class ViewHolder {
        public RecyclerView galleryGridView;
        public StaggeredGridLayoutManager mLayoutManager;
    }

    class HeaderViewHolder {
        TextView headerTitle;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View row = convertView;
        ViewHolder holder;
        if (row == null) {
            row                   = inflater.inflate(R.layout.cell_gallery_layout, parent,false);
            holder                = new ViewHolder();
            holder.galleryGridView  = (TwoWayView) row.findViewById(R.id.my_recycler_view);
            holder.galleryGridView.setHasFixedSize(true);
            row.setTag(holder);
        } else {
            holder = (ViewHolder)convertView.getTag();
        }

        Gallery gallery = this.galleries.get(position);

        /*holder.mLayoutManager = new StaggeredGridLayoutManager(3,StaggeredGridLayoutManager.VERTICAL);
        holder.galleryGridView.setLayoutManager(holder.mLayoutManager);*/

        PhotoAdapter photoAdapter = new PhotoAdapter(this.context,(TwoWayView)holder.galleryGridView,gallery.photos);
        holder.galleryGridView.setAdapter(photoAdapter);

        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        int width = size.x;

        ViewGroup.LayoutParams params = holder.galleryGridView.getLayoutParams();
        params.height = photoAdapter.getItemCount() > 5 ? (((photoAdapter.getItemCount() / 5) + 1) * (width / 2)) : (width / 2);
        holder.galleryGridView.setLayoutParams(params);


        return row;
    }

}
