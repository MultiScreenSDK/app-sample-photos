package com.samsung.appsamplephotos.fragments;


import android.os.Bundle;

import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.controllers.PhotoController;
import com.samsung.appsamplephotos.models.Photo;
import com.samsung.appsamplephotos.utils.Constants;
import com.squareup.picasso.Picasso;

import java.io.File;
import java.util.zip.Inflater;

/**
 * A simple {@link Fragment} subclass.
 */
public class ScreenSlidePageFragment extends Fragment {

    int photoIdSelected;

    public ScreenSlidePageFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        getActivity().getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        // Inflate the layout for this fragment
        View row = inflater.inflate(R.layout.fragment_screen_slide_page, container, false);
        ImageView previewImageView = (ImageView) row.findViewById(R.id.previewImageView);

        Bundle bundle = getArguments();
        photoIdSelected = bundle.getInt(Constants.PHOTO_ID);

        Photo photo = PhotoController.getInstance().getPhotoByPosition(photoIdSelected);
        Picasso.with(getActivity()).load(new File(photo.getUri().toString()))
                .fit()
                .centerInside()
                .into(previewImageView);
        return row;
    }


}
