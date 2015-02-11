package com.samsung.appsamplephotos.adapters;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.os.AsyncTask;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.nostra13.universalimageloader.cache.disc.impl.UnlimitedDiscCache;
import com.nostra13.universalimageloader.cache.memory.impl.WeakMemoryCache;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.nostra13.universalimageloader.core.assist.QueueProcessingType;
import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.activities.ScreenSlideActivity;
import com.samsung.appsamplephotos.controllers.PhotoController;
import com.samsung.appsamplephotos.models.Gallery;
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
public class PhotoAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private final Context context;
    private ArrayList<Photo> photos;
    private Gallery currentGallery;
    TwoWayView mRecyclerView;
    ImageLoader picture = ImageLoader.getInstance();
    DisplayImageOptions options;

    public PhotoAdapter(Context context, TwoWayView recyclerView, Gallery gallery){
        this.context    = context;
        this.photos  = gallery.getPhotos();
        this.currentGallery = gallery;
        this.mRecyclerView = recyclerView;
        File cacheDir;
        if (android.os.Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED))
            cacheDir=new File(android.os.Environment.getExternalStorageDirectory(),"neongall");
        else
            cacheDir=context.getCacheDir();
        if(!cacheDir.exists())
            cacheDir.mkdirs();

        ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(context)
                .memoryCache(new WeakMemoryCache())
                .denyCacheImageMultipleSizesInMemory()
                .discCache(new UnlimitedDiscCache(cacheDir))
                .threadPriority(Thread.NORM_PRIORITY - 2)
                .build();
        //this.picture.init(ImageLoaderConfiguration.createDefault(context));
        this.picture.init(config);
        optionImages();
    }

    private void optionImages(){
        DisplayImageOptions.Builder builder = new DisplayImageOptions.Builder();
        builder.cacheOnDisc(false);
        builder.cacheInMemory(true);
        builder.considerExifParams(true);
        builder.imageScaleType(ImageScaleType.IN_SAMPLE_INT);
        builder.bitmapConfig(Bitmap.Config.RGB_565);
        builder.resetViewBeforeLoading(true);
        this.options = builder.build();
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
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.cell_photo_layout, parent, false);
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(final RecyclerView.ViewHolder viewHolder, final int position) {
            Grid((ViewHolder)viewHolder,position);
    }

    public void Grid(ViewHolder viewHolder, int position){
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

        /*boolean isVertical = (mRecyclerView.getOrientation() == TwoWayLayoutManager.Orientation.VERTICAL);
        final View itemView = viewHolder.itemView;

        final int itemId = position;

            final int dimenId;
            if (itemId % 3 == 0) {
                dimenId = R.dimen.staggered_child_medium;
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
        final StaggeredGridLayoutManager.LayoutParams lp =
                (StaggeredGridLayoutManager.LayoutParams) itemView.getLayoutParams();

        if (!isVertical) {
            lp.span = span;
            lp.width = size;
            itemView.setLayoutParams(lp);
        } else {
            lp.span = span;
            lp.height = size;
            itemView.setLayoutParams(lp);
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

            if (position == (   (position / 5) * 5) + 2) {
                lp.height = width / 2;
                lp.width = width / 2;
                lp.span = 2;
            } else {
                lp.height = width / 4;
                lp.width = width / 4;
                lp.span = 1;
            }

        }

        LinearLayout.LayoutParams lpt = new LinearLayout.LayoutParams(lp.height,lp.width);

        viewHolder.photoImageView.setLayoutParams(new LinearLayout.LayoutParams(lpt));

        itemView.setLayoutParams(lp);

        viewHolder.photoImageView.setImageBitmap(null);

        /*Picasso.with(holder.restaurantImage.getContext()).load(restaurant.restaurantCoverImage.url).fit().centerInside().into(holder.restaurantImage);
        holder.restaurantImage.setTag(restaurant);*/

        Log.e(Constants.APP_TAG,"Cargando imagen Lucho: " + position);

        picture.displayImage("file:/" + photo.getUri().toString(), viewHolder.photoImageView, this.options);


        /*Picasso.with(viewHolder.photoImageView.getContext()).load(new File(photo.getUri().toString()))
                .resize(lp.height,lp.width)
                .centerCrop()
                .into(viewHolder.photoImageView);*/

        viewHolder.viewHolder.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                PhotoController.getInstance().setCurrentGallery(currentGallery);
                Intent intent = new Intent(context, ScreenSlideActivity.class);
                intent.putExtra(Constants.PHOTO_ID,photo.getPosition());
                intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
                context.startActivity(intent);
            }
        });
    }

    @Override
    public int getItemCount() {
        return this.photos.size();
    }

}
