package com.samsung.appsamplephotos.activity;

import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.SpannableStringBuilder;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ImageSpan;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.util.TypefaceSpan;

import static android.widget.TextView.*;
import static com.samsung.appsamplephotos.util.Utils.customFont;

public class MoreActivity extends FragmentActivity {

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
        setContentView(R.layout.activity_more);
        SpannableString s = new SpannableString(getResources().getString(R.string.action_more));
        s.setSpan(new TypefaceSpan(this,"Roboto-Light.ttf"), 0, s.length(),
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        getActionBar().setTitle(s);
        getActionBar().setHomeButtonEnabled(true);
        getActionBar().setIcon(getResources().getDrawable(R.drawable.ic_back));
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
        checkModelNumberBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getApplicationContext(), CompatibleListActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION);
                startActivity(intent);
            }
        });
        setFontTypes();
    }

    private void setFontTypes() {
        aboutTitleTextView.setTypeface(customFont(this));
        aboutDescriptionTextView.setTypeface(customFont(this));
        howConnectTitleTextView.setTypeface(customFont(this));
        compatibleTextView.setTypeface(customFont(this));
        mobileTextView.setTypeface(customFont(this));
        deviceDiscoversTextView.setTypeface(customFont(this));
        tapSelectTextView.setTypeface(customFont(this));
        turnsToTextView.setTypeface(customFont(this));
        tapDisconnectTextView.setTypeface(customFont(this));
        moreInfoTextView.setTypeface(customFont(this));
        contactTextView.setTypeface(customFont(this));
        sendEmailTextView.setTypeface(customFont(this));
        answerQuestionTextView.setTypeface(customFont(this));
        checkModelNumberBtn.setTypeface(customFont(this));

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

        final String content = getResources().getString(R.string.send_email);
        final String mail = getResources().getString(R.string.contact_email);

        SpannableStringBuilder ssbContact = new SpannableStringBuilder(getResources().getString(R.string.send_email));

        ClickableSpan urlSpan=new ClickableSpan(){
            @Override
            public void onClick(    View widget){
                Intent send = new Intent(Intent.ACTION_SENDTO);
                String uriText = "mailto:" + Uri.encode(mail);
                Uri uri = Uri.parse(uriText);
                send.setData(uri);
                startActivity(Intent.createChooser(send, "Send mail..."));
            }
            @Override
            public void updateDrawState(    TextPaint ds){
                ds.setUnderlineText(false);
                ds.setColor(Color.rgb(0, 172, 234));
            }
        };

        int emailPositionStart = content.indexOf(mail);
        ssbContact.setSpan( urlSpan, emailPositionStart, emailPositionStart+mail.length(), Spannable.SPAN_INCLUSIVE_INCLUSIVE );
        sendEmailTextView.setText( ssbContact, BufferType.SPANNABLE );
        sendEmailTextView.setMovementMethod(LinkMovementMethod.getInstance());
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        if (id == android.R.id.home) onBackPressed();
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        overridePendingTransition(0,0);
    }

}