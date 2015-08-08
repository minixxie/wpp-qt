package wpp.android;

import android.app.Activity;
import android.view.Window;

import android.util.Log;


public class Wpp
{
	public static void setSoftInputMode(Activity activity, int mode)
	{
		Log.e("Wpp:setSoftInputMode", "setSoftInputMode...");
		final Window window = activity.getWindow();
		final int softInputMode = mode;
		activity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				Log.e("Wpp:setSoftInputMode", "setSoftInputMode...mode="+softInputMode);
				window.setSoftInputMode(softInputMode);
				Log.e("Wpp:setSoftInputMode", "setSoftInputMode...");
			}
		});


	}
}
