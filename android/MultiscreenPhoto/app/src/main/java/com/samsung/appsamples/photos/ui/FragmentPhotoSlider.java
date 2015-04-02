/*******************************************************************************
 * Copyright (c) 2015 Samsung Electronics
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *******************************************************************************/

package com.samsung.appsamples.photos.ui;

import android.graphics.Bitmap;
import android.graphics.Point;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.samsung.appsamples.photos.App;
import com.samsung.appsamples.photos.Constants;
import com.samsung.appsamples.photos.R;
import com.samsung.appsamples.photos.util.DiskCacheManager;
import com.samsung.appsamples.photos.util.Util;
import com.samsung.multiscreen.util.RunUtil;

import java.io.File;

/**
 * Created by bliu on 3/3/2015.
 */
public class FragmentPhotoSlider extends Fragment {
    String imagePath;
    ImageView previewImageView;

    private ProgressBar loadingProgressBar;
    private boolean imageLoadSuccessful = true;

    public static FragmentPhotoSlider newInstance(String imagePath) {
        FragmentPhotoSlider imageFrag = new FragmentPhotoSlider();

        // Supply val input as an argument.
        Bundle args = new Bundle();

        //Pass the image path to Fragment.
        args.putString("path", imagePath);
        imageFrag.setArguments(args);
        return imageFrag;
    }

    public FragmentPhotoSlider() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        imagePath = getArguments() != null ? getArguments().getString("path") : null;

    }

    @Override
    public void setMenuVisibility(final boolean visible) {
        super.setMenuVisibility(visible);
        if (visible) {
            //Fragment is displayed now.
            if (!imageLoadSuccessful) {
                //Show error message if the photo could not decoded properly on some Android build.
                Toast.makeText(getActivity(),
                        getString(R.string.image_load_failed), Toast.LENGTH_LONG).show();
            }
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        //Set to full screen.
        getActivity().getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        // Inflate the layout for this fragment
        View row = inflater.inflate(R.layout.fragment_photo_slider, container, false);

        //Load views.
        previewImageView = (ImageView) row.findViewById(R.id.previewImageView);
        previewImageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                if (((ActivityPhotoSlider) getActivity()).getSupportActionBar().isShowing()) {
                    ((ActivityPhotoSlider) getActivity()).hideActionBar();
                } else {
                    ((ActivityPhotoSlider) getActivity()).showActionBar();
                }
            }
        });

        loadingProgressBar = (ProgressBar) row.findViewById(R.id.loading);
        loadingProgressBar.setIndeterminate(false);
        loadingProgressBar.setVisibility(View.VISIBLE);

        //Make sure the image path is not null.
        if (imagePath != null) loadImageToUI();
        return row;
    }

    /**
     * Load bitmap into image view.
     */
    void loadImageToUI() {

        RunUtil.runInBackground(new Runnable() {
            @Override
            public void run() {
                //Get the image key in disk cache.
                final String key = Util.getSliderImageKey(imagePath);

                Bitmap bitmap = null;

                //Try to load bitmap from dis cache first.
                try {
                    bitmap = App.getInstance().getDiskCacheManager().getBitmapFromDiskCache(key);
                } catch (OutOfMemoryError error) {
                }

                //display bitmap if it is not null.
                if (bitmap != null) {
                    loadImageView(bitmap);
                } else {
                    //If does not exist, resize the full image and save the resized image to disk cache.
                    Point size = Util.getDisplaySize();
                    File file = new File(imagePath);
                    if (!file.exists()) return;
                    //Log.d(Constants.APP_TAG, "FragmentPhotoSlider, file size = " + file.length());

                    Bitmap bmp = null;
                    try {
                        bmp = Util.decodeSampledBitmapFromFile(file.getAbsolutePath(), size.x, size.y, true);
                    } catch (OutOfMemoryError error) {
                        System.gc();
                    }

                    //Give another chance to read smaller file.
                    //We will use smaller size this time.
                    if (bmp == null) {
                        try {
                            bmp = Util.decodeSampledBitmapFromFile(imagePath, size.x / 2, size.y / 2, true);
                        } catch (OutOfMemoryError error) {
                            System.gc();
                        }
                    }

                    if (bmp != null) {

                        //Rotate the bitmap.
                        Bitmap bitmapRotated = Util.rotateBitmap(Util.getExifOrientation(imagePath), bmp);

                        //Load bitmap into image view.
                        loadImageView(bitmapRotated);

                        //Save the bitmap into disk cache.
                        DiskCacheManager.addCompressedBitmapToCache(key, 70, bitmapRotated);
                    } else {
                        //Some photo format may not be supported on some phones.
                        //We will show a message to users.
                        Log.e(Constants.APP_TAG, "Could not read photo: " + imagePath);
                        imageLoadSuccessful = false;
                    }
                }

            }
        });
    }

    /**
     * Load the bitmap into ImageView object.
     *
     * @param bitmap the bitmap to be loaded.
     */
    private void loadImageView(final Bitmap bitmap) {
        RunUtil.runOnUI(new Runnable() {
            @Override
            public void run() {
                previewImageView.setImageBitmap(bitmap);
                loadingProgressBar.setVisibility(View.GONE);
            }
        });
    }
}
