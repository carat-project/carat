package edu.berkeley.cs.amplab.carat.android.utils;

import java.util.HashMap;

import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.preference.PreferenceManager;
import android.util.Log;
import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.protocol.ClickTracking;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;

public class Tracker {

	private static Tracker instance = null;
	private String uuid = null;
	private MainActivity main = null;
	
	public static Tracker getInstance(MainActivity c) {
		if (instance == null) {
			instance = new Tracker(c);
		}
		return instance;
	}
	
	private Tracker(MainActivity c){
		this.main = c;
		SharedPreferences p = PreferenceManager.getDefaultSharedPreferences(c);
		this.uuid = p.getString(CaratApplication.getRegisteredUuid(), "UNKNOWN");
	}

	/*
	 * IMPORTANT: The fields "type" and "textBenefit" of the fullObject (the
	 * second parameter) must be initiated before INVOKING this method,
	 * otherwise you get NullPointerException
	 */
	public void trackUser(String label, SimpleHogBug fullObject) {
		PackageInfo pak = SamplingLibrary.getPackageInfo(main,
				fullObject.getAppName());
		HashMap<String, String> options = new HashMap<String, String>();
		String title = main.getTitle().toString();
		options.put("type", fullObject.getType().toString());
		if (pak != null) {
			options.put("app", pak.packageName);
			options.put("version", pak.versionName);
			options.put("versionCode", pak.versionCode + "");
			options.put("label", label);
		}
		options.put("benefit",
				fullObject.getBenefitText().replace('\u00B1', '+'));
		track("samplesview", title, options);
	}

	public void trackUser(String whatIsGettingDone, CharSequence title) {
	    if (Constants.DEBUG)
	        Log.d("Tracker.trackUser", whatIsGettingDone);
		HashMap<String, String> options = new HashMap<String, String>();
		track(whatIsGettingDone, title.toString(), options);
	}
	
	public void trackSharing(CharSequence title) {
		HashMap<String, String> options = new HashMap<String, String>();
		options.put("sharetext", main.getString(R.string.myjscoreis) + " " + CaratApplication.getJscore());
		track("caratshared", title.toString(), options);
	}
	
	public void trackFeedback(String os, String model, CharSequence title) {
		HashMap<String, String> options = new HashMap<String, String>();
		options.put("os", os);
		options.put("model", model);
		SimpleHogBug[] b = CaratApplication.getStorage().getBugReport();
		int len = 0;
		if (b != null)
			len = b.length;
		options.put("bugs", len + "");
		b = CaratApplication.getStorage().getHogReport();
		len = 0;
		if (b != null)
			len = b.length;
		options.put("hogs", len + "");
		options.put("sharetext", main.getString(R.string.myjscoreis) + " " + CaratApplication.getJscore());
		track("feedbackbutton", title.toString(), options);
	}
	
	/**
	 * Helper that calls ClickTracking with the required arguments, and also sets `title` as the `status`.
	 * @param action The action being tracked
	 * @param title The title of the app at this time
	 * @param options Other options
	 */
	private void track(String action, String title, HashMap<String, String> options){
		options.put("status", title);
		ClickTracking.track(uuid, action, options, main);
	}
}
