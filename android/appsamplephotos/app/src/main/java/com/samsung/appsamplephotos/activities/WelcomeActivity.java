package com.samsung.appsamplephotos.activities;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Typeface;
import android.support.v4.app.FragmentActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.utils.Constants;

public class WelcomeActivity extends FragmentActivity {

    private Button startButton;
    private TextView titleTextView;
    private TextView paragraphTextVieW;
    private SharedPreferences prefs;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_welcome);
        setupView();
    }

    public void setupView() {
        prefs = getSharedPreferences(Constants.APP_PREFERENCES, Context.MODE_PRIVATE);
        titleTextView = (TextView) findViewById(R.id.titleTextView);
        paragraphTextVieW = (TextView) findViewById(R.id.paragraphTextVieW);
        startButton = (Button) findViewById(R.id.startButton);
        startButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SharedPreferences.Editor editor = prefs.edit();
                editor.putBoolean(Constants.APP_PREFERENCE_WELCOME_GUIDE, true);
                editor.commit();
                finish();
            }
        });
        Typeface myTypefaceLight = Typeface.createFromAsset(this.getAssets(), "fonts/Roboto-Light.ttf");
        titleTextView.setTypeface(myTypefaceLight);
        paragraphTextVieW.setTypeface(myTypefaceLight);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_welcome, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onBackPressed() {
        SharedPreferences.Editor editor = prefs.edit();
        editor.putBoolean(Constants.APP_PREFERENCE_WELCOME_GUIDE, true);
        editor.commit();
        finish();
        super.onBackPressed();
    }
}
