package com.samsung.appsamplephotos.utils;

import android.content.Context;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Build;

/**
 * Common utils class
 */
public class Utils {

    //Constants
    public static long APPLICATION_LAUNCH_TIMEOUT = 30000;

    //Util Methods
    public static String getDeviceName() {
        return capitalize(Build.MODEL);
    }

    // Capitalize a String
    public static String capitalize(String s) {
        if (s == null || s.length() == 0) {
            return "";
        }
        char first = s.charAt(0);
        if (Character.isUpperCase(first)) {
            return s;
        } else {
            return Character.toUpperCase(first) + s.substring(1);
        }
    }

    public static Typeface customFont(Context context) {
        return setFont(context, Constants.FONT_FOLDER + Constants.FONT_ROBOTO_LIGHT);
    }

    public static Typeface italicFont(Context context) {
        return setFont(context, Constants.FONT_FOLDER + Constants.FONT_ROBOTO_LIGHT_ITALIC);
    }

    private static Typeface setFont(Context context, String font) {
        return Typeface.createFromAsset(context.getAssets(), font);
    }
}
