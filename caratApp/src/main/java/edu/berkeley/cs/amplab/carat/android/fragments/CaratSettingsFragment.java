package edu.berkeley.cs.amplab.carat.android.fragments;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.Preference;
import android.preference.Preference.OnPreferenceChangeListener;
import android.preference.PreferenceManager;
//important: the following import command imports the class from a library project, not from android.preference.PreferenceFragment
import android.support.v4.preference.PreferenceFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.android.utils.Tracker;


public class CaratSettingsFragment extends PreferenceFragment {
	
	private final String TAG = "CaratSettings";
	
	Tracker tracker = null;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		/*
		 * Using a PreferenceFragment and its addPreferencesFromResource() method is a convenient way to create a 
		 * preference/settings fragment. 
		 * The addPreferencesFromResource() method of the PreferenceFragment class does all of the hard work for us: 
		 * it reads the values from our defaultSharedPreferences, 
		 * inflates a ListView as our fragment's root view, 
		 * then inside the getView() method of an ArrayAdapter it creates and attaches to our ListView,
		 * it inflates each individual Preference widget we have in our specified xml file (whose resource ID we pass as an argument to this method),
		 * sets the values of those inflated view objects to the values just read from our defaultSharedPreferences,
		 * adds those inflated view objects to our rootView (ListView view object) using the mentioned adapter, 
		 * and sets the resulting view as our fragment's view.
		 * 
		 * In addition, whenever the value of a preference widget changes in our PreferenceFragment's inflated view, 
		 * the PreferenceFragment updates the value of the corresponding (tied) item in our defaultSharedPreferences
		 * (if the item doesn't exist in there, PreferenceFragment creates an item with this key and sets its value to the just read value from the view/widget)
		 * 
		 * sets them to the last value of each corresponding preference (in the
		 * XML file). basically it loads the preferences from an XML resource
		 */
		
		addPreferencesFromResource(R.xml.preferences);

		/*
		 * Both of the "Switch" Preference widget (view) and the "PreferenceFragment" classes can only be used in Android 3.0+.
		 * We use two external libraries to backport these handy classes (provide them for Android version < 3.0):
		 * 1. The "switch widget backport" library, check out the readme: https://github.com/BoD/android-switch-backport
		 * 2. The "android support preferencefragment" (check out the readme in the library's directory)
		 */
		
		// we use the tracker in the following two methods, so instantiate it here
		tracker = Tracker.getInstance((MainActivity) getActivity());

		/**
		 * It seems I need to do this one manually.
		 * -Eemil
		 */
		Preference hogthresh = findPreference(getString(R.string.hog_hide_threshold));
		hogthresh.setOnPreferenceChangeListener(new OnPreferenceChangeListener(){

			@Override
			public boolean onPreferenceChange(Preference preference,
					Object newValue) {
				//Log.d(TAG, preference.getKey() + " changed to " + newValue +" of type: " + newValue.getClass());
		        SharedPreferences p = getActivity().getSharedPreferences(Constants.PREFERENCE_FILE_NAME, Context.MODE_PRIVATE);
		        p.edit().putString(getString(R.string.hog_hide_threshold), newValue.toString()).commit();
				return true;
			}
		});
	}
	
	@Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		View cr = super.onCreateView(inflater, container, savedInstanceState);
		cr.setBackgroundColor(getResources().getColor(android.R.color.background_light));
		return cr;
	}

	@Override
	public void onResume() {
		getActivity().setTitle(getTag());
		super.onResume();
	}
	
	
	/**
	 * If you would like to do something FURTHER than changing "wifiOnly" preference value, do it in this listener.
	 * 
	 * Note 1: preferences value DO change automatically, no need for manual action.
	 * (when we use a preference widget in an xml preference file (res/xml/*.xml))
	 * 
	 * Note 2: if you fill in this listener, do not forget to set it as our preference widget's listener, like this:
	 * findPreference(CaratApplication.WIFI_ONLY_PREFERENCE_KEY).setOnPreferenceChangeListener(mOnPreferenceChangeListener);
	 * (using Preference.setOnPreferenceChangeListener(listener))
	 * (attach the listener in onCreate() method of the current fragment (which is a subclass of a specialized fragment, i.e. PreferenceFragment))
	 */
	/* private OnPreferenceChangeListener mOnPreferenceChangeListener = new OnPreferenceChangeListener() {
          @Override
          public boolean onPreferenceChange(Preference preference, Object o) {
  	        Log.d("settings-fragment", "New value is: " + o.toString());
  	        // return true to update the state of the Preference with the new value.
  	        return true;
  	    }
      }; */

	/**
     * This is a onCLICK listener method (rather than onCHANGE listener)
     * usually not needed, but leave it here just in case.
     * if you want to start an activity or open a custom dialog, this is not the correct way to go
     * See Preference.SetIntent() for example for starting an activity/intent
     * Or if your "extra" (the data you want to pass together with your intent) is merely some constants, 
     * see here for embedding your intent into your preference's xml element:
     * http://developer.android.com/guide/topics/ui/settings.html#Intents
     * If you want to display a custom dialog, see "Building a Custom Preference" in the above article.
     * There already are some ready-made dialogs (ListPreference, EditTextPreference, CheckBoxPreference), 
     * see the Preference class for a list of all other subclasses and their corresponding properties. 
     */
	/* private OnPreferenceClickListener mOnPreferenceClickListener = new OnPreferenceClickListener() {
        @Override
        public boolean onPreferenceClick(Preference preference) {
	        Log.d("settings-fragment", preference.getKey() + " was click");
	        // return true to update the state of the Preference with the new value.
	        return true;
	    }
    }; */

}