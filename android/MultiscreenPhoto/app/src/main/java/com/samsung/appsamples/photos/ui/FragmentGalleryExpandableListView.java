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

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.ExpandableListView;

import com.samsung.appsamples.photos.App;
import com.samsung.appsamples.photos.Constants;
import com.samsung.appsamples.photos.R;
import com.samsung.appsamples.photos.adapter.GalleryExpandableListViewAdapter;
import com.samsung.appsamples.photos.model.Gallery;
import com.samsung.appsamples.photos.util.Util;
import com.samsung.multiscreen.util.RunUtil;

/**
 * The Gallery fragment used in gallery activity.
 */
public class FragmentGalleryExpandableListView extends Fragment {
    /** The ExpandableListView object which is used to display photo thumbnails. */
    private ExpandableListView expListView;

    /** The adapter of ExpandableListView. */
    private GalleryExpandableListViewAdapter adapter;

    public FragmentGalleryExpandableListView() {
    }

    public void onResume() {
        super.onResume();

        if (expListView != null) {
            expListView.invalidate();
        }

        if (adapter != null) {
            adapter.notifyDataSetChanged();
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_gallery_expandablelistview, container, false);
        expListView = (ExpandableListView) rootView.findViewById(R.id.lvExp);
        return rootView;
    }


    /**
     * Refresh the list view with the screen width.
     */
    public void refresh() {
        Log.d(Constants.APP_TAG, "FragmentGallery#refresh is called.");
        if (adapter != null) {
            adapter.updateWidth();
            adapter.notifyDataSetChanged();
        }
    }

    /**
     * Create a new adapter if it does not exist or notify and update UI.
     */
    public void updateAdapter() {
        if (adapter == null) {

            //Create and initialize adapter.
            adapter = new GalleryExpandableListViewAdapter(getActivity());
            RunUtil.runOnUI(new Runnable() {
                @Override
                public void run() {
                    expListView.setAdapter(adapter);
                    expandGroups();

                    ViewTreeObserver vto = expListView.getViewTreeObserver();

                    vto.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
                        @Override
                        public void onGlobalLayout() {
                            if(android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.JELLY_BEAN_MR2) {
                                expListView.setIndicatorBounds(expListView.getRight()- Util.getDipsFromPixel(getActivity(), 60),
                                        expListView.getWidth() - Util.getDipsFromPixel(getActivity(), 20));
                            } else {
                                expListView.setIndicatorBoundsRelative(expListView.getRight() - Util.getDipsFromPixel(getActivity(), 60),
                                        expListView.getWidth() - Util.getDipsFromPixel(getActivity(), 20));
                            }
                        }
                    });
                }
            });
        }

        //Notify to update UI.
        RunUtil.runOnUI(new Runnable() {
            @Override
            public void run() {
                adapter.notifyDataSetChanged();
                expListView.invalidate();
            }
        });

    }

    /**
     * Try to expand photo buckets if it is visible.
     */
    private void expandGroups() {
        int count = 0;
        for (Gallery.Bucket bucket : App.getInstance().getGallery()) {
            if (bucket.isVisible()) expListView.expandGroup(count);
            count++;
        }
    }
}
