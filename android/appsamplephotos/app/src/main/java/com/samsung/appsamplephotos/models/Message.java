package com.samsung.appsamplephotos.models;

import java.util.Date;

/**
 * Created by Nestor on 9/25/14.
 */
public class Message {

    public String message;
    public Date createdAt;
    public String action;

    public Message(String message) {
        this.message = message;
        this.createdAt = new Date();
    }

    public void setAction(String action) {
        this.action = action;
    }

}
