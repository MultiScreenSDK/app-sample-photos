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

            galleries.clear();
            galleries =  PhotoController.getInstance().getGalleries();

            addContainerItem(galleries,mInflater,mContainer);

        }
        return rootView;
    }

    public void addContainerItem(ArrayList<Gallery> galleries,LayoutInflater inflater,ViewGroup container){
        for (Gallery gallery : galleries) {
            View child = inflater.inflate(R.layout.bucket_collection_container, container, false);
            TextView bucketTitle = (TextView) child.findViewById(R.id.bucketTitle);
            bucketTitle.setTypeface(MultiscreenUtils.customFont(getActivity()));
            RelativeLayout headerCollectionLayout = (RelativeLayout) child.findViewById(R.id.headerCollectionLayout);
            final TwoWayView recyclerView = (TwoWayView) child.findViewById(R.id.recycler_collection_view);
            final ImageView arrowImageView = (ImageView) child.findViewById(R.id.arrowImageView);
            final PhotoAdapter photoAdapter = new PhotoAdapter(getActivity(),recyclerView, gallery.getPhotos());
            headerCollectionLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (recyclerView.getVisibility() == View.INVISIBLE) {
                        arrowImageView.setImageDrawable(getResources().getDrawable(R.drawable.ic_arrow_down));
                        WindowManager wm = (WindowManager) getActivity().getSystemService(Context.WINDOW_SERVICE);
                        Display display = wm.getDefaultDisplay();
                        Point size = new Point();
                        display.getSize(size);
                        int width = size.x;
                        ViewGroup.LayoutParams params = recyclerView.getLayoutParams();
                        params.height = photoAdapter.getItemCount() > 5 ? (((photoAdapter.getItemCount() / 5) + 1) * (width / 2)) : (width / 2);
                        recyclerView.setLayoutParams(params);
                        recyclerView.setVisibility(View.VISIBLE);
                    } else {
                        arrowImageView.setImageDrawable(getResources().getDrawable(R.drawable.ic_arrow_up));
                        ViewGroup.LayoutParams params = recyclerView.getLayoutParams();
                        params.height = 0;
                        recyclerView.setLayoutParams(params);
                        recyclerView.setVisibility(View.INVISIBLE);
                    }
                }
            });
            bucketTitle.setText(gallery.getName());
            addCollectionImage(gallery.getPhotos(), child, R.layout.cell_photo_layout, mInflater, mContainer, recyclerView, photoAdapter);
            mBucketContainer.addView(child);
        }
    }

    public void addCollectionImage( ArrayList<Photo> photos,View view,int resource,LayoutInflater inflater,ViewGroup container, TwoWayView recyclerView, PhotoAdapter photoAdapter){

        recyclerView.setAdapter(photoAdapter);

        WindowManager wm = (WindowManager) getActivity().getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        int width = size.x;

        ViewGroup.LayoutParams params = recyclerView.getLayoutParams();
        params.height = photoAdapter.getItemCount() > 5 ? (((photoAdapter.getItemCount() / 5) + 1) * (width / 2)) : (width / 2);
        recyclerView.setLayoutParams(params);
    }


}
