package com.samsung.appsamplephotos.fragments;

import android.content.Context;
import android.graphics.Point;
import android.os.AsyncTask;
import android.os.Bundle;
import android.app.Fragment;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.adapters.PhotoAdapter;
import com.samsung.appsamplephotos.helpers.PhotoHelper;
import com.samsung.appsamplephotos.models.Gallery;
import com.samsung.appsamplephotos.models.Photo;

import org.lucasr.twowayview.widget.TwoWayView;

import java.util.ArrayList;

import static com.samsung.appsamplephotos.utils.Utils.*;

/**
 * A simple {@link Fragment} subclass.
 */
public class GalleryFragment extends Fragment {

    private LayoutInflater mInflater;
    private ViewGroup mContainer;
    private LinearLayout mBucketContainer;
    private View rootView;
    private ArrayList<Gallery> galleries = new ArrayList<Gallery>();

    public static GalleryFragment newInstance() {
        GalleryFragment fragment = new GalleryFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    public GalleryFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        if(rootView == null) {
            // Inflate the layout for this fragment
            mInflater = inflater;
            mContainer = container;

            rootView = inflater.inflate(R.layout.fragment_gallery, container, false);
            mBucketContainer = (LinearLayout) rootView.findViewById(R.id.bucket_view_container);

            if (galleries.isEmpty())
                galleries = PhotoHelper.getInstance().getGalleries();

            addContainerItem(galleries,mInflater,mContainer);

        }
        return rootView;
    }

    public void addContainerItem(final ArrayList<Gallery> galleries,LayoutInflater inflater,ViewGroup container){
        for (final Gallery gallery : galleries) {

            View child = inflater.inflate(R.layout.bucket_collection_container, container, false);

            TextView bucketTitle = (TextView) child.findViewById(R.id.bucketTitle);
            RelativeLayout headerCollectionLayout = (RelativeLayout) child.findViewById(R.id.headerCollectionLayout);
            final TwoWayView recyclerView = (TwoWayView) child.findViewById(R.id.recycler_collection_view);
            final ImageView arrowImageView = (ImageView) child.findViewById(R.id.arrowImageView);
            final PhotoAdapter photoAdapter = new PhotoAdapter(getActivity(),recyclerView, gallery);

            bucketTitle.setTypeface(customFont(getActivity()));

            headerCollectionLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (recyclerView.getVisibility() == View.GONE) {

                        if (gallery.getPhotos().isEmpty()) {
                            getGalleryImages(recyclerView, gallery,  photoAdapter);
                        } else {
                            if (recyclerView.getChildCount() == 0) {
                                addCollectionImage(recyclerView, photoAdapter);
                            }
                        }
                        gallery.isOpen = true;

                        arrowImageView.setImageDrawable(getResources().getDrawable(R.drawable.ic_arrow_up));
                        setViewHeight(recyclerView,photoAdapter);
                        recyclerView.setVisibility(View.VISIBLE);

                    } else {

                        gallery.isOpen = false;

                        arrowImageView.setImageDrawable(getResources().getDrawable(R.drawable.ic_arrow_down));
                        setViewHeight(recyclerView,photoAdapter);
                        recyclerView.setVisibility(View.GONE);
                    }
                }
            });


            setupBucketView(gallery, bucketTitle, recyclerView, photoAdapter, arrowImageView);

            mBucketContainer.addView(child);
        }
    }

    private void setupBucketView(Gallery gallery, TextView bucketTitle, TwoWayView recyclerView, PhotoAdapter photoAdapter, ImageView arrowImageView) {
        bucketTitle.setText(gallery.getName());
        if (!gallery.isOpen) {
            recyclerView.setVisibility(View.GONE);
            arrowImageView.setImageDrawable(getResources().getDrawable(R.drawable.ic_arrow_down));
        } else {
            if (gallery.getPhotos().isEmpty() || gallery.getPhotos().size() < gallery.count) {
                gallery.positionLoaded = gallery.getPhotos().size();
                getGalleryImages(recyclerView, gallery, photoAdapter);
            } else {
                addCollectionImage(recyclerView, photoAdapter);
            }
            recyclerView.setVisibility(View.VISIBLE);
            arrowImageView.setImageDrawable(getResources().getDrawable(R.drawable.ic_arrow_up));
        }
    }

    private static class TaskParams {
        TwoWayView recyclerView;
        Gallery gallery;
        PhotoAdapter photoAdapter;

        TaskParams(TwoWayView recyclerView,Gallery gallery, PhotoAdapter photoAdapter) {
            this.recyclerView = recyclerView;
            this.gallery = gallery;
            this.photoAdapter = photoAdapter;
        }
    }

    private void getGalleryImages(TwoWayView recyclerView,Gallery gallery, PhotoAdapter photoAdapter) {
        if (getActivity() != null) {
            TaskParams taskParams = new TaskParams(recyclerView, gallery, photoAdapter);
            new LoadGalleryTask().execute(taskParams);
        }
    }

    private class LoadGalleryTask extends AsyncTask<TaskParams, Void, Void> {

        TwoWayView recyclerView;
        Gallery gallery;
        PhotoAdapter photoAdapter;
        Context context;

        @Override
        protected Void doInBackground(TaskParams... params) {
            recyclerView = params[0].recyclerView;
            gallery = params[0].gallery;
            photoAdapter = params[0].photoAdapter;
            context = getActivity();

            loadGallery(gallery, recyclerView, photoAdapter, context);
            return null;
        }

    }

    public void loadGallery (Gallery gallery,TwoWayView recyclerView, PhotoAdapter photoAdapter,  Context context ) {
        ArrayList<Photo> photoArrayList = PhotoHelper.getInstance().getImageInfos(context, gallery, 10, gallery.positionLoaded);

        gallery.getPhotos().addAll(photoArrayList);
        gallery.positionLoaded += 10;
        gallery.photoLoaded += photoArrayList.size();

        addCollectionImage(recyclerView, photoAdapter);
        if (gallery.count > gallery.positionLoaded && getActivity() != null) {
            loadGallery(gallery, recyclerView, photoAdapter, context);
        }
    }

    public void addCollectionImage(final TwoWayView recyclerView,final PhotoAdapter photoAdapter){
        if (getActivity() != null) {
            getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    if (recyclerView.getAdapter() == null)
                        recyclerView.setAdapter(photoAdapter);
                    else
                        photoAdapter.notifyDataSetChanged();
                    setViewHeight(recyclerView, photoAdapter);
                }
            });
        }
    }

    private void setViewHeight(TwoWayView recyclerView, PhotoAdapter photoAdapter) {
        ViewGroup.LayoutParams params = recyclerView.getLayoutParams();
        params.height = calculateHeight(photoAdapter);
        recyclerView.setLayoutParams(params);
    }

    private int calculateHeight(PhotoAdapter photoAdapter) {
        WindowManager wm = (WindowManager) getActivity().getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        int width = size.x;
        int numberColumns = photoAdapter.getItemCount() / 5;
        int sum = photoAdapter.getItemCount() % 5 == 0 ? 0 : 1;
        return (numberColumns + sum) * (width/2);
    }

}
