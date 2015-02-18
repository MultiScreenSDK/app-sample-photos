package com.samsung.appsamplephotos.adapters;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.support.v7.widget.RecyclerView;
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
import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.activities.ScreenSlideActivity;
import com.samsung.appsamplephotos.helpers.PhotoHelper;
import com.samsung.appsamplephotos.models.Gallery;
import com.samsung.appsamplephotos.models.Photo;
import com.samsung.appsamplephotos.utils.Constants;

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
        setImageLoaderConfig();
        optionImages();
    }

    private void setImageLoaderConfig() {
        File cacheDir;
        if (android.os.Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED))
            cacheDir=new File(android.os.Environment.getExternalStorageDirectory(),Constants.APP_TAG);
        else
            cacheDir=context.getCacheDir();
        if(!cacheDir.exists())
            cacheDir.mkdirs();

        ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(context)
                .memoryCache(new WeakMemoryCache())
                .denyCacheImageMultipleSizesInMemory()
                .discCache(new UnlimitedDiscCache(cacheDir))
                .memoryCacheSize(1048576 * 20)
                .threadPriority(Thread.NORM_PRIORITY - 2)
                .build();
        this.picture.init(config);
    }

    private void optionImages(){
        DisplayImageOptions.Builder builder = new DisplayImageOptions.Builder();
        builder.cacheOnDisc(true);
        builder.cacheInMemory(false);
        builder.considerExifParams(true);
        builder.imageScaleType(ImageScaleType.IN_SAMPLE_INT);
        builder.bitmapConfig(Bitmap.Config.RGB_565);
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

        final StaggeredGridLayoutManager.LayoutParams lp = (StaggeredGridLayoutManager.LayoutParams) itemView.getLayoutParams();

        final Photo photo = this.photos.get(position);

        int width = getDisplaySize().x;

        setRowBounds(position, lp, width);

        LinearLayout.LayoutParams lpt = new LinearLayout.LayoutParams(lp.height,lp.width);

        viewHolder.photoImageView.setLayoutParams(new LinearLayout.LayoutParams(lpt));

        itemView.setLayoutParams(lp);

        if (viewHolder.photoImageView.getDrawable() == null) {
            picture.displayImage("file:/" + photo.getUri().toString(), viewHolder.photoImageView, this.options);
        }

        viewHolder.viewHolder.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                PhotoHelper.getInstance().setCurrentGallery(currentGallery);
                Intent intent = new Intent(context, ScreenSlideActivity.class);
                intent.putExtra(Constants.PHOTO_ID,photo.getPosition());
                intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
                context.startActivity(intent);
            }
        });
    }

    /**
     * Return the screen size
     * @return
     */
    private Point getDisplaySize() {
        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        return size;
    }

    public void setRowBounds(int position, StaggeredGridLayoutManager.LayoutParams lp, int width) {
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
    }

    @Override
    public int getItemCount() {
        return this.photos.size();
    }

}
