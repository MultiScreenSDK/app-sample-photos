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

package com.samsung.appsamples.photos;

/**
 * Application static constants
 */
public class Constants {
    /**
     * The application debug tag.
     */
    public static String APP_TAG = "SamsungMultiscreenSample-Photos";

    /**
     * Preference storage name.
     */
    public static final String APP_PREFERENCE_WELCOME_GUIDE = "welcomeGuide";
    /**
     * The app filed name in preference.
     */
    public static final  String APP_PREFERENCES = "com.samsung.multiscreen.preferences";
    /**
     *  The font folder assets.
     */
    public static final String FONT_FOLDER = "fonts/";
    /**
     * The font file name.
     */
    public static final  String FONT_ROBOTO_LIGHT = "Roboto-Light.ttf";
    public static final  String FONT_ROBOTO_LIGHT_ITALIC = "Roboto-LightItalic.ttf";


    /**
     * The header of thumbnail uri. The full uri is:
     * content://media/external/images/thumbnails/thumbnailId
     */
    public static final String THUMBNAIL_URI = "content://media/external/images/thumbnails/";

    /**
     * The photo's offset in bucket to be displayed.
     */
    public static final String PHOTO_OFFSET_IN_BUCKET = "photo_offset_in_bucket";
    /**
     * The bucket offset in Gallery.
     */
    public static final String GROUP_POSITION = "com.samsung.multiscreen.groupPosition";

    /**
     * The TV application URL.
     */
    public static final String APP_URL = "http://dgpcnfdr6d6y5.cloudfront.net/app-sample-photos/tv/index.html";
    /**
     * The TV application channel id which the app is going to connect.
     */
    public static final String CHANNEL_ID = "com.samsung.multiscreen.photos";

    /**
     * The event to notify TV application that photo data comes.
     */
    public static final String EVENT_SHOW_PHOTO = "showPhoto";
    /**
     * The event to notify TV application that we are going to start to transfer data.
     * TV application will shows a progress indicator when this event is received.
     */
    public static final String EVENT_PHOTO_TRANSFER_START = "photoTransfer";


    /**
     * The target thumbnail size. Scaled down minn thumbnail size to this size.
     */
    public static final int TARGET_THUMBNAIL_SIZE = 192;

}
