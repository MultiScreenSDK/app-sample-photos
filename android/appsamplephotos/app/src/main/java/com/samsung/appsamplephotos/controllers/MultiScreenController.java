package com.samsung.appsamplephotos.controllers;

import java.lang.Error;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.samsung.appsamplephotos.models.Message;
import com.samsung.appsamplephotos.utils.Constants;
/*import com.samsung.multiscreen.application.Application;
import com.samsung.multiscreen.application.Application.Status;
import com.samsung.multiscreen.application.ApplicationAsyncResult;
import com.samsung.multiscreen.application.ApplicationError;
import com.samsung.multiscreen.channel.Channel;
import com.samsung.multiscreen.channel.ChannelAsyncResult;
import com.samsung.multiscreen.channel.ChannelClient;
import com.samsung.multiscreen.channel.ChannelError;
import com.samsung.multiscreen.channel.IChannelListener;
import com.samsung.multiscreen.device.Device;
import com.samsung.multiscreen.device.DeviceAsyncResult;
import com.samsung.multiscreen.device.DeviceError;*/
import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.utils.MultiscreenUtils;
import com.samsung.multiscreen.*;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import org.apache.http.entity.ByteArrayEntity;


public class MultiScreenController {

    private static MultiScreenController instance;

    private Application application;
    private Service service;
    private Search search;

    private castStatusTypes castStatus;

    public enum castStatusTypes {
        NOSERVICES,
        SERVICESFOUND,
        CONNECTEDTOSERVICE
    };

    public static MultiScreenController getInstance() {
        if (instance == null) {
            instance = new MultiScreenController();
        }
        return instance;
    }

    private MultiScreenController() {

    }

    public void setService(Service service) {
        this.service = service;
    }

    public List<Service> getServices() {
        return search.getServices();
    }

    public Service getService() {
        return this.service ;
    }

    public void setCastStatus(castStatusTypes castStatus) {
        this.castStatus = castStatus;
    }

    public castStatusTypes getCastStatus() {
        return castStatus;
    }

    public void findServices(final Activity activity, final Callback callback) {
        search = Service.search(activity);
        search.setOnServiceFoundListener(
                new Search.OnServiceFoundListener() {

                    @Override
                    public void onFound(Service service) {
                        setCastStatus(castStatusTypes.SERVICESFOUND);
                        Log.e(Constants.APP_TAG, "Add Service: " + service.toString());
                        notifyServiceChanged(activity, service);
                        if (callback != null) callback.onSuccess();
                    }
                }
        );

        search.setOnServiceLostListener(
                new Search.OnServiceLostListener() {

                    @Override
                    public void onLost(Service service) {
                        Log.e(Constants.APP_TAG, "Remove Service: " + service.toString());
                        notifyServiceChanged(activity, service);
                        if (callback != null)
                            callback.onError(new Error(activity.getResources().getString(R.string.service_lost)));
                    }
                }
        );
    }

    public void notifyServiceChanged(Activity activity, Service service) {
        Intent intent = new Intent(Constants.SERVICE_EVENT);
        intent.putExtra(Constants.SERVICE, service.toString());
        LocalBroadcastManager.getInstance(activity).sendBroadcast(intent);
    }

    public void startSearch() {
        this.search.start();
    }

    public void stopSearch() {
        this.search.stop();
    }

    public void connectApplication(Activity activity,final Callback callback) {
        if (service != null) {
            Uri uri = Uri.parse(activity.getResources().getString(R.string.url_id));
            application = service.createApplication(Uri.parse(Constants.APP_ID), activity.getResources().getString(R.string.channel_id));
            application.setStartOnConnect(false);
            application.connect(new Result<Channel>() {

                @Override
                public void onSuccess(Channel channel) {
                    castStatus = castStatusTypes.CONNECTEDTOSERVICE;
                    Log.d(Constants.APP_TAG, "Application connect onSuccess() " + channel.toString());
                    // Do something now that we have successfully connected to
                    // the application (like launch the app).
                    if (callback != null) callback.onSuccess();

                }

                @Override
                public void onError(com.samsung.multiscreen.Error error) {
                    Log.d(Constants.APP_TAG, "Application connect onError() " + error.toString());
                    if (callback != null) callback.onError(error.toString());
                }
            });
        }
    }

    public void launchApplication(final Callback callback) {
        if (service != null) {
            application.start(new Result<Boolean>() {

                @Override
                public void onSuccess(Boolean aBoolean) {
                    if (callback != null) callback.onSuccess();
                }

                @Override
                public void onError(com.samsung.multiscreen.Error error) {
                    Log.d(Constants.APP_TAG, "Application connect onError() " + error.toString());
                    if (callback != null) callback.onError(error.toString());
                }
            });
        }
    }

    public void publishToApplication(byte[] imageByte) {
        if (application != null) {
            Log.e(Constants.APP_TAG,"publishToApplication");
            application.publish("showPhoto","",imageByte);
        }
    }

    public void disconnectApplication(final Callback callback){
        application.disconnect(new Result<Channel>() {

               @Override
               public void onSuccess(Channel channel) {
                   Log.d(Constants.APP_TAG, "Application disconnect onSuccess() " + channel.toString());
                   castStatus = getServices().size() > 0 ? castStatusTypes.SERVICESFOUND : castStatusTypes.NOSERVICES;
                   if (callback != null) callback.onSuccess();
               }

               @Override
               public void onError(com.samsung.multiscreen.Error error) {
                   if (callback != null) callback.onError(new Error(Constants.APP_TAG + ": " + error));
               }
           }
        );
    }

}
