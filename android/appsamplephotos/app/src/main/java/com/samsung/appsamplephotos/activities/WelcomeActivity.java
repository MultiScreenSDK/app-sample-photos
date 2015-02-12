package com.samsung.appsamplephotos.activities;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Typeface;
import android.support.v4.app.FragmentActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.utils.Constants;

import static com.samsung.appsamplephotos.utils.Utils.customFont;

public class WelcomeActivity extends FragmentActivity {

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
        setupView();
    }

    public void setupView() {
        prefs = getSharedPreferences(Constants.APP_PREFERENCES, Context.MODE_PRIVATE);
        titleTextView = (TextView) findViewById(R.id.titleTextView);
        paragraphTextVieW = (TextView) findViewById(R.id.paragraphTextVieW);
        noteTextVieW = (TextView) findViewById(R.id.noteTextVieW);
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
        titleTextView.setTypeface(customFont(this));
        paragraphTextVieW.setTypeface(customFont(this));
        noteTextVieW.setTypeface(customFont(this));
        startButton.setTypeface(customFont(this));
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
        overridePendingTransition(0,0);
    }
}
