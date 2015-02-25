package com.samsung.appsamplephotos.fragment;


import android.os.Bundle;

import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.activity.BaseActivity;
import com.samsung.appsamplephotos.util.Constants;
import com.squareup.picasso.Picasso;

/**
 * A simple {@link Fragment} subclass.
 */
public class ScreenSlidePageFragment extends Fragment {

    String photoIdSelected;

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

        previewImageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                if (((BaseActivity) getActivity()).getSupportActionBar().isShowing()) {
                    ((BaseActivity) getActivity()).hideActionBar();
                } else {
                    ((BaseActivity) getActivity()).showActionBar();
                }
            }
        });

        Bundle bundle = getArguments();
        photoIdSelected = bundle.getString(Constants.PHOTO_ID);

        if (photoIdSelected != null) {
            Picasso.with(getActivity()).load("file://" + photoIdSelected)
                    .fit()
                    .centerInside()
                    .into(previewImageView);
        }
        return row;
    }

}
