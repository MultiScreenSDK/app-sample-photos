package com.samsung.appsamplephotos.controllers;

import java.util.List;

import com.samsung.appsamplephotos.utils.Constants;
import com.samsung.appsamplephotos.R;
import com.samsung.multiscreen.*;
import com.samsung.multiscreen.Error;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import static com.samsung.multiscreen.Channel.*;

/**
 * Helps to implement MultiScreen API methods (SDK v2.0.12)
 */
public class MultiScreenController {

    private static MultiScreenController instance;

    // Represent the MultiScreen application on the TV
    private Application application;

    // Used to setup the service or client connection established
    private Service service;

    // You can invoke API methods for Search for services, cans start or stop search
    // for services or even set listener to know if a service is found or has been lost.
    private Search search;

    // Used to keep the activity context when search for service start
    private Context context;

    // Listeners to detect events over the application changes
    private OnDisconnectListener onDisconnectListener;
    private OnConnectListener onConnectListener;
    private OnErrorListener onErrorListener;

    // Keep the current status of the connection to the TV
    private castStatusTypes castStatus;

    // Possible connection to the TV' status
    public enum castStatusTypes {
        NOSERVICES,
        SERVICESFOUND,
        CONNECTEDTOSERVICE
    };

    /**
     * Return the current instance of this class, if there are not instance
     * then instantiate a new one.
     *
     * @return
     */
    public static MultiScreenController getInstance() {
        if (instance == null) {
            instance = new MultiScreenController();
        }
        return instance;
    }

    private MultiScreenController() {

    }

    /**
     * Getter to current service.
     *
     * @return Service
     */
    public Service getService() {
        return service ;
    }

    /**
     * Setter to set service.
     *
     * @param service
     */
    public void setService(Service service) {
        this.service = service;
    }

    /**
     * Getter for list of services.
     *
     * @return
     */
    public List<Service> getServices() {
        return search.getServices();
    }

    /**
    * Return the current connection to TV status according custom cast types
    * (see enum castStatusTypes)
    *
    * @return
    */
    public castStatusTypes getCastStatus() {
        return castStatus;
    }

    /**
     * Setter to modify the current cast status
     *
     * @param castStatus
     */
    public void setCastStatus(castStatusTypes castStatus) {
        this.castStatus = castStatus;
    }

    /**
     * Initialize service event detection, if a service is found the calls OnServiceFoundListener
     * in case detect a service lost calls OnServiceLostListener.
     *
     * You can replace Callback param to your custom callback class.
     *
     * @param context
     * @param callback
     */
    public void findServices(final Context context, final Callback callback) {
        this.context = context;

        // Get an instance of Search
        search = Service.search(context);

        //Add a listener for the service found event
        search.setOnServiceFoundListener(
                new Search.OnServiceFoundListener() {

                    @Override
                    public void onFound(Service service) {

                        // Change the cast status to service found only in case there are not
                        // connection to the TV or service available.
                        if (getCastStatus() != castStatusTypes.CONNECTEDTOSERVICE)
                            setCastStatus(castStatusTypes.SERVICESFOUND);

                        // Print out in the log the found service
                        Log.d(Constants.APP_TAG, "Found Service: " + service.toString());

                        // Send service found broadcast notification
                        notifyServiceChanged(service);

                        // Calls on Success to the callback
                        if (callback != null) callback.onSuccess();
                    }
                }
        );

        // Add a listener for the service lost event
        search.setOnServiceLostListener(
                new Search.OnServiceLostListener() {

                    @Override
                    public void onLost(Service service) {

                        // Print out the log the lost service
                        Log.e(Constants.APP_TAG, "Lost Service: " + service.toString());

                        // Send service lost broadcast notification
                        notifyServiceChanged(service);

                        // Calls on Error to the callback, custom error message as a String param
                        if (callback != null)
                            callback.onError(new java.lang.Error(context.getResources().getString(R.string.service_lost)));
                    }
                }
        );
    }

    /**
     * Start discovery process for service in the local network
     */
    public void startSearch() {
        search.start();
    }

    /**
     * Stop the discovery process after some amount of time, preferably once the user
     * has selected a service to work with.
     */
    public void stopSearch() {
        if ((search != null) && search.isSearching()) {
            search.stop();
        }
    }

    /**
     * Sends a local broadcast to notify to the registered receiver a service
     * event, either a service was found or was lost.
     *
     * @param service
     */
    public void notifyServiceChanged(Service service) {
        Intent intent = new Intent(Constants.SERVICE_EVENT);
        intent.putExtra(Constants.SERVICE, service != null ? service.toString() : Constants.NO_SERVICE);
        LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
    }

    /**
     * Makes connection to the TV and start the application on the TV
     * if the current service is available.
     *
     * @param context
     * @param callback
     */
    public void connectApplication(Context context,final Callback callback) {
        if (service != null) {

            //Uri url = Uri.parse(context.getResources().getString(R.string.app_url));
            Uri url = Uri.parse(Constants.APP_URL);

            //String channel = context.getResources().getString(R.string.channel_id));
            String channel = Constants.CHANNEL_ID;

            // Get an instance of Application.
            application = service.createApplication(url, channel);
            application.setConnectionTimeout(5000);
            setApplicationListeners();
            application.connect(new Result<Client>() {

                @Override
                public void onSuccess(Client client) {
                    //
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

    /**
     * Set the default listeners to the application
     */
    private void setApplicationListeners() {
        setListeners();
        application.setOnDisconnectListener(onDisconnectListener);
        application.setOnConnectListener(onConnectListener);
        application.setOnErrorListener(onErrorListener);
    }

    /**
     * Initialize listener to detect changes on the connectivity
     */
    private void setListeners() {

        // Listen for the connect event
        onConnectListener = new OnConnectListener() {

            @Override
            public void onConnect(Client client) {
                Log.e(Constants.APP_TAG, "Application.onConnect() client: " + client.toString());
                castStatus = castStatusTypes.CONNECTEDTOSERVICE;
                notifyServiceChanged(null);
            }
        };

        //
        onDisconnectListener = new OnDisconnectListener() {
            @Override
            public void onDisconnect(Client client) {
                if (client != null) {
                    Log.e(Constants.APP_TAG, "Application disconnect listener onSuccess() " + client.toString());
                    service = null;
                    castStatus = getServices().size() > 0 ? castStatusTypes.SERVICESFOUND : castStatusTypes.NOSERVICES;
                    notifyServiceChanged(null);
                }
            }
        };

        // Listener to handle connection errors
        onErrorListener = new OnErrorListener() {
            @Override
            public void onError(Error error) {
                Log.e(Constants.APP_TAG, "Application.onConnect() error: " + error.toString());
            }
        };
    }

    /**
     * Disconnect from the application. The application will continue to run on the TV, even
     * if this was the last connected client.
     *
     * @param callback
     */
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

    /**
     * Send a message to the TV app.
     *
     * Note: for this sample, send the bytes representation of the picture.
     *
     * @param imageByte
     */
    public void publishToApplication(byte[] imageByte) {
        if (application != null) {
            application.publish(Constants.EVENT_SHOW_PHOTO,"",imageByte);
        }
    }

}
