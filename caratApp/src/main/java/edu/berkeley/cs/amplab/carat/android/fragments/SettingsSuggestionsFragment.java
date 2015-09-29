package edu.berkeley.cs.amplab.carat.android.fragments;

import java.io.Serializable;

import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.lists.SettingsSuggestionAdapter;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;
import edu.berkeley.cs.amplab.carat.android.ui.LocalizedWebView;

public class SettingsSuggestionsFragment extends ExtendedTitleFragment implements Serializable{
    
    private static final long serialVersionUID = 1L; 
    // private static final String TAG = "SettingsSuggestions";
    private View rootView;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        rootView = inflater.inflate(R.layout.suggestions, container, false);
        
        final ListView lv = (ListView) rootView.findViewById(android.R.id.list);
        lv.setCacheColorHint(0);

		lv.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> a, View v, int position, long id) {
			    MainActivity m = ((MainActivity) getActivity());
				Object o = lv.getItemAtPosition(position);
				SimpleHogBug fullObject = (SimpleHogBug) o;
				final String actionName = fullObject.getAppName();
				// Log.v(TAG, "Showing view for " + actionName);
				
				if (actionName.equals("OsUpgrade") && m != null)
					m.showHTMLFile("upgradeos", getString(R.string.upgradeosinfo), false);
				else if (actionName.equals(getString(R.string.dimscreen)))
					GoToDisplayScreen(m);
				else if (actionName.equals(getString(R.string.disablewifi)))
					GoToWifiScreen(m);
				else if (actionName.equals(getString(R.string.disablegps)))
					GoToLocSevScreen(m);
				else if (actionName.equals(getString(R.string.disablelocation)))
					GoToLocSevScreen(m);
				else if (actionName.equals(getString(R.string.disablebluetooth)))
					GoToBluetoothScreen(m);
				else if (actionName.equals(getString(R.string.disablehapticfeedback)))
					GoToSoundScreen(m);
				else if (actionName.equals(getString(R.string.automaticbrightness)))
					GoToDisplayScreen(m);
				else if (actionName.equals(getString(R.string.disablenetwork)))
					GoToMobileNetworkScreen(m);
				else if (actionName.equals(getString(R.string.disablevibration)))
					GoToSoundScreen(m);
				else if (actionName.equals(getString(R.string.shortenscreentimeout)))
					GoToDisplayScreen(m);
				else if (actionName.equals(getString(R.string.disableautomaticsync)))
					GoToSyncScreen(m);
				else if (actionName.equals(getString(R.string.helpcarat)))
					m.showHTMLFile("collectdata", getString(R.string.collectdatainfo), false);
				else if (actionName.equals(getString(R.string.questionnaire)))
					openQuestionnaire();
			}

		});

        initUpgradeOsView(rootView);
/*
        getActivity().setTitle(getResources().getString(R.string.tab_settings));
  */      
        return rootView;
    }
    
    private void initUpgradeOsView(View root) {
        LocalizedWebView webview = (LocalizedWebView) root.findViewById(R.id.upgradeOsView);
        webview.loadUrl("file:///android_asset/upgradeos.html");
        //webview.setOnTouchListener(new FlipperBackListener(this, vf, vf.indexOfChild(findViewById(android.R.id.list))));
    }
    
    private void safeStart(MainActivity m, String action, int label) {
        if (m != null)
            m.safeStart(action, getString(label));
    }

    /* Show the bluetooth setting */
    public void GoToBluetoothScreen(MainActivity m) {
        safeStart(m, android.provider.Settings.ACTION_BLUETOOTH_SETTINGS, R.string.bluetoothsettings);
    }

    /* Show the wifi setting */
    public void GoToWifiScreen(MainActivity m) {
        safeStart(m, android.provider.Settings.ACTION_WIFI_SETTINGS, R.string.wifisettings);
    }

    /*
     * Show the display setting including screen brightness setting, sleep mode
     */
    public void GoToDisplayScreen(MainActivity m) {
        safeStart(m, android.provider.Settings.ACTION_DISPLAY_SETTINGS, R.string.screensettings);
    }

    /*
     * Show the sound setting including phone ringer mode, vibration mode, haptic feedback setting and other sound options
     */
    public void GoToSoundScreen(MainActivity m) {
        safeStart(m, android.provider.Settings.ACTION_SOUND_SETTINGS, R.string.soundsettings);
    }

    /*
     * Show the location service setting including configuring gps provider, network provider
     */
    public void GoToLocSevScreen(MainActivity m) {
        safeStart(m, android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS, R.string.locationsettings);
    }

    /* Show the synchronization setting */
    public void GoToSyncScreen(MainActivity m) {
    	safeStart(m, android.provider.Settings.ACTION_SYNC_SETTINGS, R.string.syncsettings);
    }

    /*
     * Show the mobile network setting including configuring 3G/2G, network operators
     */
    public void GoToMobileNetworkScreen(MainActivity m) {
        safeStart(m, android.provider.Settings.ACTION_DATA_ROAMING_SETTINGS, R.string.mobilenetworksettings);
    }

    /**
     * Open a Carat-related questionnaire.
     */
    public void openQuestionnaire() {
        SharedPreferences p = PreferenceManager.getDefaultSharedPreferences(getActivity());
        String caratId = Uri.encode(p.getString(CaratApplication.getRegisteredUuid(), ""));
        String os = Uri.encode(SamplingLibrary.getOsVersion());
        String model = Uri.encode(SamplingLibrary.getModel());
        String url = CaratApplication.getStorage().getQuestionnaireUrl();
        if (url != null && url.length() > 7 && url.startsWith("http")) { // http://
            url = url.replace("caratid", caratId).replace("caratos", os).replace("caratmodel", model);
            Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
            startActivity(browserIntent);
        }
    }

    @Override
    public void onResume() {
        refresh();
        super.onResume();
    }

    public void refresh() {
        CaratApplication caratAppllication = (CaratApplication) getActivity().getApplication();
        final ListView lv = (ListView) rootView.findViewById(android.R.id.list);
        lv.setAdapter(new SettingsSuggestionAdapter(caratAppllication, CaratApplication.getStorage().getSettingsReport()));
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
    	// TODO: disabled until fixing serialization (appropriate serialVersionUID)
        //  outState.putSerializable("savedInstance", this);
        super.onSaveInstanceState(outState);
    }
}
