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

import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ForegroundColorSpan;
import android.text.style.ImageSpan;
import android.text.style.URLSpan;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import com.samsung.appsamples.photos.R;
import com.samsung.appsamples.photos.util.TypefaceSpan;
import com.samsung.appsamples.photos.util.Util;

import static android.view.View.OnClickListener;

public class ActivityMore extends ActionBarActivity {

    private Button checkModelNumberBtn;
    private TextView aboutTitleTextView;
    private TextView aboutDescriptionTextView;
    private TextView howConnectTitleTextView;
    private TextView compatibleTextView;
    private TextView mobileTextView;
    private TextView deviceDiscoversTextView;
    private TextView tapSelectTextView;
    private TextView turnsToTextView;
    private TextView tapDisconnectTextView;
    private TextView moreInfoTextView;
    private TextView contactTextView;
    private TextView sendEmailTextView;
    private TextView answerQuestionTextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        //Set up the title font and content.
        SpannableString s = new SpannableString(getResources().getString(R.string.action_more));
        s.setSpan(new TypefaceSpan(this,"Roboto-Light.ttf"), 0, s.length(),
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        getSupportActionBar().setTitle(s);

        //Enable the default back button
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        //Set the back button
        //getActionBar().setIcon(getResources().getDrawable(R.drawable.ic_back));
        setContentView(R.layout.activity_more);

        //Load UI views.
        aboutTitleTextView  = (TextView) findViewById(R.id.aboutTitleTextView);
        aboutDescriptionTextView  = (TextView) findViewById(R.id.aboutDescriptionTextView);
        howConnectTitleTextView  = (TextView) findViewById(R.id.howConnectTitleTextView);
        compatibleTextView  = (TextView) findViewById(R.id.compatibleTextView);
        mobileTextView  = (TextView) findViewById(R.id.mobileTextView);
        deviceDiscoversTextView  = (TextView) findViewById(R.id.deviceDiscoversTextView);
        tapSelectTextView  = (TextView) findViewById(R.id.tapSelectTextView);
        turnsToTextView  = (TextView) findViewById(R.id.turnsToTextView);
        tapDisconnectTextView  = (TextView) findViewById(R.id.tapDisconnectTextView);
        moreInfoTextView  = (TextView) findViewById(R.id.moreInfoTextView);
        contactTextView  = (TextView) findViewById(R.id.contactTextView);
        sendEmailTextView  = (TextView) findViewById(R.id.sendEmailTextView);
        answerQuestionTextView  = (TextView) findViewById(R.id.answerQuestionTextView);
        checkModelNumberBtn  = (Button) findViewById(R.id.checkModelNumberBtn);
        checkModelNumberBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getApplicationContext(), ActivityCompatibleList.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
                startActivity(intent);
            }
        });

        //Set up the fonts
        setFontTypes();
    }

    private void setFontTypes() {
        Typeface tf = Util.customFont(this);
        aboutTitleTextView.setTypeface(tf);
        aboutDescriptionTextView.setTypeface(tf);
        howConnectTitleTextView.setTypeface(tf);
        compatibleTextView.setTypeface(tf);
        mobileTextView.setTypeface(tf);
        deviceDiscoversTextView.setTypeface(tf);
        tapSelectTextView.setTypeface(tf);
        turnsToTextView.setTypeface(tf);
        tapDisconnectTextView.setTypeface(tf);
        moreInfoTextView.setTypeface(tf);
        contactTextView.setTypeface(tf);
        sendEmailTextView.setTypeface(tf);
        answerQuestionTextView.setTypeface(tf);
        checkModelNumberBtn.setTypeface(tf);

        ImageSpan is_cast_off = new ImageSpan(this, R.drawable.ic_cast_off);
        ImageSpan is_cast_on = new ImageSpan(this, R.drawable.ic_cast_on);

        Spannable when_mobile_discovers_text = new SpannableString(getResources().getString(R.string.when_mobile_discovers));
        when_mobile_discovers_text.setSpan(is_cast_off, 43, 44, 0);
        deviceDiscoversTextView.setText(when_mobile_discovers_text);

        Spannable tap_to_select_text = new SpannableString(getResources().getString(R.string.tap_to_select));
        tap_to_select_text.setSpan(is_cast_off, 8, 9, 0);
        tapSelectTextView.setText(tap_to_select_text);

        Spannable when_turn_to_text = new SpannableString(getResources().getString(R.string.when_turn_to));
        when_turn_to_text.setSpan(is_cast_off, 9, 10, 0);
        when_turn_to_text.setSpan(is_cast_on, 21, 22, 0);
        turnsToTextView.setText(when_turn_to_text);

        Spannable tap_to_disconnect_text = new SpannableString(getResources().getString(R.string.tap_to_disconnect));
        tap_to_disconnect_text.setSpan(is_cast_on, 5, 6, 0);
        tapDisconnectTextView.setText(tap_to_disconnect_text);

        //Setup content of "send email to".
        setupSendEmailTextView();
    }

    /**
     * Set up the sendEmailTextView.
     */
    private void setupSendEmailTextView() {
        //Load the send email text.
        String sendToStr = getString(R.string.send_email);

        //Calculate the start position of email address.
        int emailStart = sendToStr.indexOf("to") + 3;

        //Calculate the end position of email address.
        int emailEnd = sendToStr.lastIndexOf(".");

        //Read the email address.
        String email = sendToStr.substring(emailStart, emailEnd);

        //Create the spannable.
        Spannable ssbContact = new SpannableString(sendToStr);

        //set the foreground color of email address.
        ssbContact.setSpan(new ForegroundColorSpan(getResources().getColor(R.color.email_color)),
                emailStart, emailEnd, 0);

        //Set URLSpan but without underline.
        ssbContact.setSpan(new URLSpanNoUnderline("mailto:" + email),
                emailStart, emailEnd, 0);

        //Set the spannable to text view.
        sendEmailTextView.setText( ssbContact);
        sendEmailTextView.setMovementMethod(LinkMovementMethod.getInstance());
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        //When back key in actionbar is pressed, close this activity.
        if (id == android.R.id.home) onBackPressed();
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        overridePendingTransition(0,0);
    }

    private class URLSpanNoUnderline extends URLSpan {
        public URLSpanNoUnderline(String url) {
            super(url);
        }
        @Override public void updateDrawState(TextPaint ds) {

            //Disable the underline.
            ds.setUnderlineText(false);
        }
    }
}
