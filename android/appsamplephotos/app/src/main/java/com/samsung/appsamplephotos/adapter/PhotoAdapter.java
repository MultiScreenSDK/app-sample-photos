package com.samsung.appsamplephotos.adapter;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.database.CursorIndexOutOfBoundsException;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.BaseExpandableListAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.nostra13.universalimageloader.cache.disc.impl.UnlimitedDiscCache;
import com.nostra13.universalimageloader.cache.memory.impl.LruMemoryCache;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.activity.BaseActivity;
import com.samsung.appsamplephotos.activity.ScreenSlideActivity;
import com.samsung.appsamplephotos.helper.PhotoHelper;
import com.samsung.appsamplephotos.util.ImageCache;
import com.samsung.appsamplephotos.util.ImageFetcher;
import com.samsung.appsamplephotos.util.Constants;
import com.samsung.appsamplephotos.util.Utils;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Koombea on 1/14/15.
 */
public class PhotoAdapter extends BaseExpandableListAdapter {

    private BaseActivity _context;
    private List<String> _listDataHeader; // header titles

    // Child data in format of header title, child title
    private HashMap<String, Cursor> _listDataChild;

    private Map<String,String> mArrayPath;
    ImageLoader picture = ImageLoader.getInstance();
    DisplayImageOptions options;

    Cursor cursor;
    int column;

    private LayoutInflater inflater;
    private ImageFetcher mImageFetcher;

    private static final String IMAGE_CACHE_DIR = "thumbs";
    private int mImageThumbSize;

    public PhotoAdapter(BaseActivity context, List<String> listDataHeader,
                        HashMap<String, Cursor> listChildData, int column){
        this.mArrayPath = new HashMap();
        this._context    = context;
        this._listDataHeader = listDataHeader;
        this._listDataChild = listChildData;
        this.column = column;

        inflater = (LayoutInflater) this._context
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);

        setImageLoaderConfig();
        optionImages();
    }

    private void setImageLoaderConfig() {
        File cacheDir;
        if (android.os.Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED))
            cacheDir=new File(android.os.Environment.getExternalStorageDirectory(),Constants.APP_TAG);
        else
            cacheDir=_context.getCacheDir();
        if(!cacheDir.exists())
            cacheDir.mkdirs();

        ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(_context)
                .discCache(new UnlimitedDiscCache(cacheDir))
                .memoryCache(new LruMemoryCache(2 * 1024 * 1024))
                .memoryCacheSize(2 * 1024 * 1024)
                .discCacheSize(100 * 1024 * 1024)
                .build();

        this.picture.init(config);

        mImageThumbSize = _context.getResources().getDimensionPixelSize(R.dimen.image_thumbnail_size);

        ImageCache.ImageCacheParams cacheParams =
                new ImageCache.ImageCacheParams(_context, IMAGE_CACHE_DIR);

        cacheParams.setMemCacheSizePercent(0.25f); // Set memory cache to 25% of app memory

        // The ImageFetcher takes care of loading images into our ImageView children asynchronously
        mImageFetcher = new ImageFetcher(_context, mImageThumbSize);
        mImageFetcher.setLoadingImage(R.drawable.empty_photo);
        mImageFetcher.setImageFadeIn(true);
        if (!_context.getSupportFragmentManager().isDestroyed()) mImageFetcher.addImageCache(_context.getSupportFragmentManager(), cacheParams);
    }

    private void optionImages(){
        DisplayImageOptions.Builder builder = new DisplayImageOptions.Builder();
        builder.cacheOnDisc(true);
        builder.cacheInMemory(true);
        builder.imageScaleType(ImageScaleType.IN_SAMPLE_INT);
        builder.bitmapConfig(Bitmap.Config.RGB_565);
        builder.showImageOnLoading(R.drawable.img_placeholder);
        builder.showImageForEmptyUri(R.drawable.img_placeholder);
        builder.showImageOnFail(R.drawable.img_placeholder);
        this.options = builder.build();
    }

    @Override
    public int getGroupCount() {
        return this._listDataHeader.size();
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        Log.e("count ", (int)Math.ceil(_listDataChild.get(_listDataHeader.get(groupPosition)).getCount()/5.0) + "");
        return (int)Math.ceil(_listDataChild.get(_listDataHeader.get(groupPosition)).getCount()/5.0);
    }

    @Override
    public Object getGroup(int groupPosition) {
        return this._listDataHeader.get(groupPosition);
    }

    @Override
    public Object getChild(int groupPosition, int childPosition) {
        return this._listDataChild.get(this._listDataHeader.get(groupPosition));
    }

    @Override
    public long getGroupId(int groupPosition) {
        return groupPosition;
    }

    @Override
    public long getChildId(int groupPosition, int childPosition) {
        return childPosition;
    }

    @Override
    public boolean hasStableIds() {
        return false;
    }

    @Override
    public boolean isChildSelectable(int groupPosition, int childPosition) {
        return true;
    }

    /**
     * Return the screen size
     * @return
     */
    private Point getDisplaySize() {
        WindowManager wm = (WindowManager) _context.getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        return size;
    }

    private class ViewHolder {
        public ImageView imageView1;
        public ImageView imageView2;
        public ImageView imageView3;
        public ImageView imageView4;
        public ImageView imageView5;
        public View fadeLine;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded, View convertView, ViewGroup parent) {

        String headerTitle = (String) getGroup(groupPosition);

        if (convertView == null) {
            convertView = inflater.inflate(R.layout.header_gallery_layout, null);
        }

        TextView lblListHeader = (TextView) convertView.findViewById(R.id.bucketTitle);
        ImageView fadeLine = (ImageView) convertView.findViewById(R.id.fadeLine);

        lblListHeader.setTypeface(Utils.customFont(_context));
        lblListHeader.setText(headerTitle);

        if (isExpanded) fadeLine.setVisibility(View.GONE);
        else fadeLine.setVisibility(View.VISIBLE);

        return convertView;
    }

    public int getChildTypeCount() {
        return 2;
    }

    public int getChildType(int groupPosition, int childPosition) {
        return (childPosition % 2) == 0 ? 0 : 1;
    }

    @Override
    public View getChildView(int groupPosition, int childPosition, boolean isLastChild, View convertView, ViewGroup parent) {
        ViewHolder holder = null;
        int itemType = getChildType(groupPosition,childPosition);
        if (convertView == null) {
            holder = new ViewHolder();
            if ((itemType % 2) == 0) {
                convertView = inflater.inflate(R.layout.list_item, null);
            }
            else {
                convertView = inflater.inflate(R.layout.list_item2, null);
            }

            holder.imageView1 = (ImageView) convertView.findViewById(R.id.image1);
            holder.imageView2 = (ImageView) convertView.findViewById(R.id.image2);
            holder.imageView3 = (ImageView) convertView.findViewById(R.id.image3);
            holder.imageView4 = (ImageView) convertView .findViewById(R.id.image4);
            holder.imageView5 = (ImageView) convertView.findViewById(R.id.image5);
            holder.fadeLine   = convertView.findViewById(R.id.fadeLine);
            convertView.setTag(holder);
        }
        else {
            holder = (ViewHolder)convertView.getTag();
        }

        setCellProperties(itemType, holder, getDisplaySize().x);

        final Cursor cursor = _listDataChild.get(_listDataHeader.get(groupPosition));

        loadPathImages(cursor, holder, groupPosition, childPosition);

        if (isLastChild) holder.fadeLine.setVisibility(View.VISIBLE);
        else holder.fadeLine.setVisibility(View.GONE);

        return convertView;
    }

    private void setCellProperties(int itemType, ViewHolder holder, int width) {
        if ((itemType % 2) == 0) {
            holder.imageView1.getLayoutParams().height = width / 2;
            holder.imageView2.getLayoutParams().height = width / 4;
            holder.imageView3.getLayoutParams().height = width / 4;
            holder.imageView4.getLayoutParams().height = width / 4;
            holder.imageView5.getLayoutParams().height = width / 4;
        } else {
            holder.imageView1.getLayoutParams().height = width / 4;
            holder.imageView2.getLayoutParams().height = width / 4;
            holder.imageView3.getLayoutParams().height = width / 2;
            holder.imageView4.getLayoutParams().height = width / 4;
            holder.imageView5.getLayoutParams().height = width / 4;
        }

        setImageViewProperty(holder.imageView1);
        setImageViewProperty(holder.imageView2);
        setImageViewProperty(holder.imageView3);
        setImageViewProperty(holder.imageView4);
        setImageViewProperty(holder.imageView5);
    }

    private void setImageViewProperty(ImageView imageView) {
        imageView.setImageDrawable(null);
        imageView.setBackgroundColor(_context.getResources().getColor(R.color.background_cell_gray));
    }

    public void setOnClickListener(final String path, ImageView imageView, final int groupPosition, final int childPosition) {
        imageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickItem(path, groupPosition, childPosition);
            }
        });
    }

    public void onClickItem(String path, final int groupPosition, final int childPosition) {
        Intent intent = new Intent(_context, ScreenSlideActivity.class);
        intent.putExtra(Constants.PHOTO_ID,path);
        intent.putExtra(Constants.GROUP_POSITION,groupPosition);
        intent.putExtra(Constants.CHILD_POSITION,childPosition);
        intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
        _context.startActivity(intent);
    }

    private void loadPathImages(Cursor cursor, ViewHolder holder, int groupPosition, int childPosition) {
        if (cursor != null) {
            for (int i = 0; i <= 4; i ++) {
                String pathImage = null;

                if (cursor.moveToPosition((childPosition * 5) + i)) {
                    pathImage = cursor.getString(column);
                }

                if (i == 0) {
                    if (pathImage == null) {
                        pathImage = pathFirstImage(cursor, childPosition);
                    }
                    setImageProperties(holder.imageView1, pathImage, groupPosition, cursor);
                }
                if (i == 1) setImageProperties(holder.imageView2, pathImage, groupPosition, cursor);
                if (i == 2) setImageProperties(holder.imageView3, pathImage, groupPosition, cursor);
                if (i == 3) setImageProperties(holder.imageView4, pathImage, groupPosition, cursor);
                if (i == 4) setImageProperties(holder.imageView5, pathImage, groupPosition, cursor);
            }
        }
    }

    private void setImageProperties(ImageView imageView, String pathImage, int groupPosition, Cursor cursor) {
        loadImage(imageView, pathImage, cursor);
        if (pathImage != null) {
            setOnClickListener(pathImage, imageView, groupPosition, cursor.getPosition());
        } else {
            imageView.setOnClickListener(null);
        }
    }

    private void loadImage(ImageView imageView, String path, Cursor cursor) {
        if (path != null) {
            if (imageView.getTag() == null || !imageView.getTag().equals(path)) {
                //String fileThumbPath = getThumbnail(cursor, path);
                //if (fileThumbPath != null) {
                    try {
                        //picture.displayImage("file:/" + getThumbnail(cursor,path), imageView, options);
                        mImageFetcher.loadImage(path, imageView);
                    } catch (Exception ex) {

                    }
                } else {
                //picture.displayImage("drawable://" + R.drawable.img_placeholder, imageView, options);
                    mImageFetcher.loadImage("drawable://" + R.drawable.img_placeholder, imageView);
                    imageView.setTag("drawable://" + R.drawable.img_placeholder);
                }
            }
        /*} else {
            //picture.displayImage("drawable://" + R.drawable.img_placeholder, imageView, options);
            mImageFetcher.loadImage("drawable://" + R.drawable.img_placeholder, imageView);
            imageView.setTag("drawable://" + R.drawable.img_placeholder);
        }*/
    }

    private String pathFirstImage(Cursor cursor, int childPosition) {
        String uri = null;
        if (childPosition == 0){
            try {
                uri = cursor.getString(column);
            }catch (Exception ex ){}
        }
        if (cursor.moveToNext()){
            uri = cursor.getString(column);
        }
        return uri;
    }


    public String getThumbnail(Cursor cursor, String path) {
        String uri = null;
        if (!mArrayPath.containsKey(path)) {
            try {
                Cursor thumbnailCursor = MediaStore.Images.Thumbnails.queryMiniThumbnail(
                        _context.getContentResolver(), cursor.getLong(cursor.getColumnIndex(MediaStore.Images.ImageColumns._ID)),
                        MediaStore.Images.Thumbnails.MINI_KIND,
                        null);

                if (thumbnailCursor != null && thumbnailCursor.getCount() > 0) {
                    thumbnailCursor.moveToFirst();
                    uri = thumbnailCursor.getString(thumbnailCursor.getColumnIndex(MediaStore.Images.Thumbnails.DATA));
                    if (uri == null) uri = path;
                    mArrayPath.put(path, uri);
                    thumbnailCursor.close();
                }
            }catch (CursorIndexOutOfBoundsException ex){
                if (uri == null) uri = path;
                mArrayPath.put(path, uri);
            }
        }
        else {
            uri = mArrayPath.get(path);
        }
        if (uri == null) {
            uri = path;
            mArrayPath.put(path, uri);
        }

        return uri;
    }

    @Override
    public void onGroupExpanded(int groupPosition) {
        super.onGroupExpanded(groupPosition);
        PhotoHelper.getInstance().getGallery(groupPosition).isOpen = true;
    }

    @Override
    public void onGroupCollapsed(int groupPosition) {
        super.onGroupCollapsed(groupPosition);
        PhotoHelper.getInstance().getGallery(groupPosition).isOpen = false;
    }

}
