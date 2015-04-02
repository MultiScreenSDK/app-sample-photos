package com.samsung.appsamples.photos.ui;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import com.samsung.appsamples.photos.Constants;
import com.samsung.appsamples.photos.R;
import com.samsung.appsamples.photos.util.Util;

public class ActivityWelcome extends FragmentActivity {

    private Button startButton;
    private TextView titleTextView;
    private TextView paragraphTextVieW;
    private TextView noteTextVieW;
    private SharedPreferences prefs;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_welcome);

        //Set views.
        setupView();
    }

    /**
     * Set up UI views.
     */
    public void setupView() {
        prefs = getSharedPreferences(Constants.APP_PREFERENCES, Context.MODE_PRIVATE);
        titleTextView = (TextView) findViewById(R.id.titleTextView);
        paragraphTextVieW = (TextView) findViewById(R.id.paragraphTextVieW);
        noteTextVieW = (TextView) findViewById(R.id.noteTextVieW);
        startButton = (Button) findViewById(R.id.startButton);
        startButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                saveState();
                finish();
            }
        });
        titleTextView.setTypeface(Util.customFont(this));
        paragraphTextVieW.setTypeface(Util.customFont(this));
        noteTextVieW.setTypeface(Util.customFont(this));
        startButton.setTypeface(Util.customFont(this));
    }


    @Override
    public void onBackPressed() {
        saveState();
        super.onBackPressed();
    }

    /**
     * Save the viewed state so that it won't show again.
     */
    private void saveState() {
        SharedPreferences.Editor editor = prefs.edit();
        editor.putBoolean(Constants.APP_PREFERENCE_WELCOME_GUIDE, true);
        editor.commit();
    }
}
