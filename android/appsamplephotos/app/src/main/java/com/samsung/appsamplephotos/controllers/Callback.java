package com.samsung.appsamplephotos.controllers;

/**
 * Custom Callback
 */
public abstract class Callback {

	abstract public void onSuccess();
	abstract public void onError(Object error);
}
