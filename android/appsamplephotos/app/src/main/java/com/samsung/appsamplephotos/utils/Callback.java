package com.samsung.appsamplephotos.utils;

/**
 * Custom abstract Callback class
 */
public abstract class Callback {

	abstract public void onSuccess();
	abstract public void onError(Object error);
}
