package com.samsung.appsamplephotos.utils;

import android.net.Uri;
import android.os.Build;

/**
 * Created by Nestor on 9/25/14.
 */
public class MultiscreenUtils {

    //Constants
    public static long APPLICATION_LAUNCH_TIMEOUT = 30000;

    //Util Methods
    public static String getDeviceName() {
        return capitalize(Build.MODEL);
    }

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


    public static Uri getWebAppUri() {
        Uri uri = null;
        try {
            uri = Uri.parse(Constants.APP_ID);
        } catch (Exception e) {
        }
        return uri;
    }
}
