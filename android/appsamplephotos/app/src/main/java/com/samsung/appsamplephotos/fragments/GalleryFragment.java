package com.samsung.appsamplephotos.fragments;


import android.content.Context;
import android.graphics.Point;
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
import com.samsung.appsamplephotos.controllers.PhotoController;
import com.samsung.appsamplephotos.models.Gallery;
import com.samsung.appsamplephotos.models.Photo;
import com.samsung.appsamplephotos.utils.MultiscreenUtils;

import org.lucasr.twowayview.widget.TwoWayView;

import java.util.ArrayList;
import java.util.List;

/**
 * A simple {@link Fragment} subclass.
 */
public class GalleryFragment extends Fragment {

    private LayoutInflater mInflater;
    private ViewGroup mContainer;
    private LinearLayout mBucketContainer;
    private View rootView;
    private ArrayList<Gallery> galleries = new ArrayList<Gallery>();
    ArrayList<Photo> dataSource = new ArrayList<Photo>();

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

            galleries.clear();
            galleries =  PhotoController.getInstance().getGalleries();

            addContainerItem(galleries,mInflater,mContainer);

        }
        return rootView;
    }

    public void addContainerItem(final ArrayList<Gallery> galleries,LayoutInflater inflater,ViewGroup container){
        for (final Gallery gallery : galleries) {
            View child = inflater.inflate(R.layout.bucket_collection_container, container, false);
            TextView bucketTitle = (TextView) child.findViewById(R.id.bucketTitle);
            bucketTitle.setTypeface(MultiscreenUtils.customFont(getActivity()));
            RelativeLayout headerCollectionLayout = (RelativeLayout) child.findViewById(R.id.headerCollectionLayout);
            final TwoWayView recyclerView = (TwoWayView) child.findViewById(R.id.recycler_collection_view);
            final ImageView arrowImageView = (ImageView) child.findViewById(R.id.arrowImageView);
            final PhotoAdapter photoAdapter = new PhotoAdapter(getActivity(),recyclerView, gallery);

            headerCollectionLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (recyclerView.getVisibility() == View.GONE) {
                        dataSource.clear();
                        if (gallery.photos.isEmpty()) gallery.photos.addAll(PhotoController.getInstance().getImageInfos(getActivity(),gallery.getId()));
                        dataSource.addAll(gallery.getPhotos());
                        arrowImageView.setImageDrawable(getResources().getDrawable(R.drawable.ic_arrow_up));
                        setViewHeight(recyclerView,photoAdapter);
                        recyclerView.setVisibility(View.VISIBLE);
                    } else {
                        arrowImageView.setImageDrawable(getResources().getDrawable(R.drawable.ic_arrow_down));
                        setViewHeight(recyclerView,photoAdapter);
                        recyclerView.setVisibility(View.GONE);
                    }
                }
            });

            bucketTitle.setText(gallery.getName());
            if (!gallery.getName().equals("Camera")) {
                recyclerView.setVisibility(View.GONE);
                arrowImageView.setImageDrawable(getResources().getDrawable(R.drawable.ic_arrow_down));
            } else {
                gallery.photos.clear();
                gallery.photos.addAll(PhotoController.getInstance().getImageInfos(getActivity(),gallery.getId()));
                dataSource.addAll(gallery.getPhotos());
                recyclerView.setVisibility(View.VISIBLE);
                arrowImageView.setImageDrawable(getResources().getDrawable(R.drawable.ic_arrow_up));
            }
            addCollectionImage(recyclerView, photoAdapter);
            mBucketContainer.addView(child);
        }
    }

    public void addCollectionImage(TwoWayView recyclerView, PhotoAdapter photoAdapter){
        recyclerView.setAdapter(photoAdapter);
        setViewHeight(recyclerView,photoAdapter);
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
