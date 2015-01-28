package com.samsung.appsamplephotos.adapters;

import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Point;
import android.support.v7.widget.RecyclerView;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Gallery;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.activities.ScreenSlideActivity;
import com.samsung.appsamplephotos.models.Photo;
import com.samsung.appsamplephotos.utils.Constants;
import com.squareup.picasso.Picasso;

import org.lucasr.twowayview.widget.StaggeredGridLayoutManager;
import org.lucasr.twowayview.widget.TwoWayView;

import java.io.File;
import java.util.ArrayList;

/**
 * Created by Koombea on 1/14/15.
 */
public class PhotoAdapter extends RecyclerView.Adapter<PhotoAdapter.ViewHolder>{

    private Context context;
    private ArrayList<Photo> photos;
    RecyclerView mRecyclerView;
    private int height;
    private int n = 7;

    public PhotoAdapter(Context context, TwoWayView recyclerView, ArrayList<Photo> photos){
        this.context    = context;
        this.photos  = photos;
        this.mRecyclerView = recyclerView;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        public ImageView photoImageView;
        public View viewHolder;
        public ViewHolder(View v) {
            super(v);
            viewHolder = v;
            photoImageView = (ImageView) v.findViewById(R.id.photoImageView);
        }
    }

    @Override
    public PhotoAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.cell_photo_layout, parent, false);
        // set the view's size, margins, paddings and layout parameters
        ViewHolder vh = new ViewHolder(v);
        return vh;
    }

    @Override
    public void onBindViewHolder(final ViewHolder viewHolder, final int position) {
        final View itemView = viewHolder.itemView;
        //holder.title.setText(mItems.get(position).toString());

        final StaggeredGridLayoutManager.LayoutParams lp = (StaggeredGridLayoutManager.LayoutParams) itemView.getLayoutParams();

        final Photo photo = this.photos.get(position);

        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        int width = size.x;
        int height = size.y;

        /*boolean isVertical = true;
        final View itemView = viewHolder.itemView;

        final int itemId = position;

        boolean isFirstColumn = false;

            final int dimenId;
            if (itemId % 3 == 0) {
                dimenId = R.dimen.staggered_child_medium;
                isFirstColumn = true;
            } else if (itemId % 5 == 0) {
                dimenId = R.dimen.staggered_child_large;
            } else if (itemId % 7 == 0) {
                dimenId = R.dimen.staggered_child_xlarge;
            } else {
                dimenId = R.dimen.staggered_child_small;
            }

            final int span;
            if (itemId == 2) {
                span = 2;
            } else {
                span = 1;
            }

            final int size = this.context.getResources().getDimensionPixelSize(dimenId);



            ViewGroup.LayoutParams lp = viewHolder.photoImageView.getLayoutParams();

            if (!isVertical) {
                //lp .setFullSpan(false);
                lp.width = size;
                //itemView.setLayoutParams(lp);
            } else {
                //itlp.setFullSpan(true);
                lp.width = size;
                lp.height = size;
                if (isFirstColumn) this.height = this.height + size;
                //itemView.setLayoutParams(itlp);
            }*/
        //viewHolder.viewHolder.setLayoutParams(itlp);
        //viewHolder.photoImageView.setLayoutParams(lp);

        if ((position / 5) % 2 == 0) {
            if ((position % 5) == 0) {
                lp.height = width / 2;
                lp.width = width / 2;
                lp.span = 2;
            } else {
                lp.height = width / 4;
                lp.width = width / 4;
                lp.span = 1;
            }

        } else {

            if (position == n) {
                lp.height = width / 2;
                lp.width = width / 2;
                lp.span = 2;
                n += 10;
            } else {
                lp.height = width / 4;
                lp.width = width / 4;
                lp.span = 1;
            }

        }

        LinearLayout.LayoutParams lpt = new LinearLayout.LayoutParams(lp.height,lp.width);

        viewHolder.photoImageView.setLayoutParams(new LinearLayout.LayoutParams(lpt));

        itemView.setLayoutParams(lp);


            Picasso.with(context).load(new File(photo.getUri().toString()))
                .resize(lp.height,lp.width)
                .centerCrop()
                .into(viewHolder.photoImageView);



        viewHolder.viewHolder.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(context, ScreenSlideActivity.class);
                intent.putExtra(Constants.PHOTO_ID,photo.getPosition());
                context.startActivity(intent);
            }
        });
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public int getItemCount() {
        return this.photos.size();
    }

}
