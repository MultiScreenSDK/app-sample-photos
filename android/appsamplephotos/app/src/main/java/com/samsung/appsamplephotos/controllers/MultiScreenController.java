package com.samsung.appsamplephotos.controllers;

import java.util.List;

import com.samsung.appsamplephotos.utils.Constants;
import com.samsung.appsamplephotos.R;
import com.samsung.multiscreen.*;
import com.samsung.multiscreen.Error;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import static com.samsung.multiscreen.Channel.*;


public class MultiScreenController {

    private static MultiScreenController instance;

    private Application application;
    private Service service;
    private Search search;
    private Context context;

    private OnDisconnectListener onDisconnectListener;
    private OnConnectListener onConnectListener;
    private OnErrorListener onErrorListener;

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
        return service ;
    }

    public void setCastStatus(castStatusTypes castStatus) {
        this.castStatus = castStatus;
    }

    public castStatusTypes getCastStatus() {
        return castStatus;
    }

    public void findServices(final Context context, final Callback callback) {
        this.context = context;
        search = Service.search(context);
        search.setOnServiceFoundListener(
                new Search.OnServiceFoundListener() {

                    @Override
                    public void onFound(Service service) {
                        setCastStatus(castStatusTypes.SERVICESFOUND);
                        Log.e(Constants.APP_TAG, "Add Service: " + service.toString());
                        notifyServiceChanged(service);
                        if (callback != null) callback.onSuccess();
                    }
                }
        );

        search.setOnServiceLostListener(
                new Search.OnServiceLostListener() {

                    @Override
                    public void onLost(Service service) {
                        Log.e(Constants.APP_TAG, "Remove Service: " + service.toString());
                        notifyServiceChanged(service);
                        if (callback != null)
                            callback.onError(new java.lang.Error(context.getResources().getString(R.string.service_lost)));
                    }
                }
        );
    }

    public void notifyServiceChanged(Service service) {
        Intent intent = new Intent(Constants.SERVICE_EVENT);
        intent.putExtra(Constants.SERVICE, service != null ? service.toString() : "null");
        LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
    }

    public void startSearch() {
        search.start();
    }

    public void stopSearch() {
        if ((search != null) && search.isSearching()) {
            search.stop();
        }
    }

    public void connectApplication(Activity activity,final Callback callback) {
        if (service != null) {
            Uri uri = Uri.parse(activity.getResources().getString(R.string.url_id));
            application = service.createApplication(Uri.parse(Constants.APP_ID), activity.getResources().getString(R.string.channel_id));
            application.setConnectionTimeout(5000);
            setApplicationListeners();
            application.connect(new Result<Client>() {

                @Override
                public void onSuccess(Client client) {
                    castStatus = castStatusTypes.CONNECTEDTOSERVICE;
                    Log.e(Constants.APP_TAG, "Application connect onSuccess() " + client.toString());
                    if (callback != null) callback.onSuccess();
                }

                @Override
                public void onError(Error error) {
                    service = null;
                    Log.e(Constants.APP_TAG, "Application connect onError() " + error.toString());
                    if (callback != null) callback.onError(error.toString());
                }
            });
        }
    }

    public void publishToApplication(byte[] imageByte) {
        if (application != null) {
            application.publish("showPhoto","",imageByte);
        }
    }

    public void disconnectApplication(final Callback callback){
        application.disconnect(false,new Result<Client>() {

               @Override
               public void onSuccess(Client client) {
                   Log.e(Constants.APP_TAG, "Application disconnect onSuccess() " + client.toString());
                   service = null;
                   castStatus = getServices().size() > 0 ? castStatusTypes.SERVICESFOUND : castStatusTypes.NOSERVICES;
                   if (callback != null) callback.onSuccess();
               }

               @Override
               public void onError(Error error) {
                   if (callback != null) callback.onError(new java.lang.Error(Constants.APP_TAG + ": " + error));
               }
           }
        );
    }

    private void setApplicationListeners() {
        setListeners();
        application.setOnDisconnectListener(onDisconnectListener);
        application.setOnConnectListener(onConnectListener);
        application.setOnErrorListener(onErrorListener);
    }

    private void setListeners() {
        onDisconnectListener = new OnDisconnectListener() {
            @Override
            public void onDisconnect(Client client) {
                Log.e(Constants.APP_TAG, "Application disconnect listener onSuccess() " + client.toString());
                service = null;
                castStatus = getServices().size() > 0 ? castStatusTypes.SERVICESFOUND : castStatusTypes.NOSERVICES;
                notifyServiceChanged(null);
            }
        };

        onConnectListener = new OnConnectListener() {

            @Override
            public void onConnect(Client client) {
                Log.e(Constants.APP_TAG, "Application.onConnect() client: " + client.toString());
                castStatus = castStatusTypes.CONNECTEDTOSERVICE;
                notifyServiceChanged(null);
            }
        };

        onErrorListener = new OnErrorListener() {
            @Override
            public void onError(Error error) {
                Log.e(Constants.APP_TAG, "Application.onConnect() error: " + error.toString());
            }
        };
    }

}
