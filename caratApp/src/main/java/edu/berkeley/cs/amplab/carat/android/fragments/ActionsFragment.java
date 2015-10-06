package edu.berkeley.cs.amplab.carat.android.fragments;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ExpandableListView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.Toast;

import java.io.Serializable;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.activities.DashboardActivity;
import edu.berkeley.cs.amplab.carat.android.lists.HogBugSuggestionsAdapter;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.android.storage.CaratDataStorage;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;
import edu.berkeley.cs.amplab.carat.android.subscreens.KillAppFragment;
import edu.berkeley.cs.amplab.carat.android.ui.LocalizedWebView;
import edu.berkeley.cs.amplab.carat.android.ui.adapters.ActionsExpandListAdapter;

/**
 * Created by Valto on 30.9.2015.
 */


public class ActionsFragment extends ExtendedTitleFragment implements Serializable {
    private static final long serialVersionUID = -6034269327947014085L;

    private DashboardActivity dashboardActivity;
    private LinearLayout ll;
    private ExpandableListView expandableListView;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.dashboardActivity = (DashboardActivity) activity;
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        ll = (LinearLayout) inflater.inflate(R.layout.fragment_actions, container, false);
        return ll;
        /*lv.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> a, View v, int position, long id) {
                MainActivity m = ((MainActivity) getActivity());
                Object o = lv.getItemAtPosition(position);
                SimpleHogBug fullObject = (SimpleHogBug) o;
                final String raw = fullObject.getAppName();
                if (raw.equals("OsUpgrade"))
                    m.showHTMLFile("upgradeos", getString(R.string.upgradeosinfo), false);
                else if (raw.equals(getString(R.string.helpcarat))) {
                    m.showHTMLFile("collectdata", getString(R.string.collectdatainfo), false);
                } else if (raw.equals(getString(R.string.questionnaire))) {
                    openQuestionnaire();
                } else {
                    displayKillAppFragment(fullObject, raw);
                }
            }

            private void displayKillAppFragment(SimpleHogBug fullObject, final String raw) {
                Bundle args = new Bundle();
                args.putString("raw", raw);

                Constants.Type type = fullObject.getType();
                if (type == Constants.Type.BUG) {
                    args.putBoolean("isBug", true);
                    args.putBoolean("isHog", false);
                    args.putBoolean("isOther", false);
                } else if (type == Constants.Type.HOG) {
                    args.putBoolean("isHog", true);
                    args.putBoolean("isBug", false);
                    args.putBoolean("isOther", false);
                }
                if (type == Constants.Type.OTHER) {
                    args.putString("appPriority", fullObject.getAppPriority());
                } else {
                    args.putString("appPriority", CaratApplication.translatedPriority(fullObject.getAppPriority()));
                }

                args.putString("benefit", fullObject.getBenefitText());

                Fragment fragment = new KillAppFragment();
                fragment.setArguments(args);

                ((MainActivity) getActivity()).replaceFragment(fragment, getString(R.string.kill) + " " + raw, false);

            }
        }); */

        //initUpgradeOsView(ll);

    }

    @Override
    public void onResume() {
        super.onResume();
        initViewRefs();
        refresh();
    }

    private void initViewRefs() {
        expandableListView = (ExpandableListView) ll.findViewById(R.id.actions_list_view);
    }

    public void refresh() {
        SimpleHogBug[] hogReport, bugReport;
        CaratDataStorage s = CaratApplication.getStorage();

        hogReport = s.getHogReport();
        bugReport = s.getBugReport();

        if (s.hogsIsEmpty() && s.bugsIsEmpty()) {
            //TODO SHOW empty actions view
            return;
        }

        expandableListView = (ExpandableListView) ll.findViewById(R.id.actions_list_view);
        expandableListView.setAdapter(new ActionsExpandListAdapter((CaratApplication) getActivity().getApplication(),
                hogReport, bugReport));
    }

    private void initUpgradeOsView(View root) {
        LocalizedWebView webview = (LocalizedWebView) root.findViewById(R.id.upgradeOsView);
        webview.loadUrl("file:///android_asset/upgradeos.html");
        //webview.setOnTouchListener(new FlipperBackListener(this, vf, vf.indexOfChild(findViewById(android.R.id.list))));
    }

    /* Show the bluetooth setting */
    public void GoToBluetoothScreen() {
        safeStart(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS, getString(R.string.bluetoothsettings));
    }

    /* Show the wifi setting */
    public void GoToWifiScreen() {
        safeStart(android.provider.Settings.ACTION_WIFI_SETTINGS, getString(R.string.wifisettings));
    }

    /*
     * Show the display setting including screen brightness setting, sleep mode
     */
    public void GoToDisplayScreen() {
        safeStart(android.provider.Settings.ACTION_DISPLAY_SETTINGS, getString(R.string.screensettings));
    }

    /*
     * Show the sound setting including phone ringer mode, vibration mode, haptic feedback setting and other sound options
     */
    public void GoToSoundScreen() {
        safeStart(android.provider.Settings.ACTION_SOUND_SETTINGS, getString(R.string.soundsettings));
    }

    /*
     * Show the location service setting including configuring gps provider, network provider
     */
    public void GoToLocSevScreen() {
        safeStart(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS, getString(R.string.locationsettings));
    }

    /* Show the synchronization setting */
    public void GoToSyncScreen() {
        safeStart(android.provider.Settings.ACTION_SYNC_SETTINGS, getString(R.string.syncsettings));
    }

    /*
     * Show the mobile network setting including configuring 3G/2G, network operators
     */
    public void GoToMobileNetworkScreen() {
        safeStart(android.provider.Settings.ACTION_DATA_ROAMING_SETTINGS, getString(R.string.mobilenetworksettings));
    }

    /* Show the application setting */
    public void GoToAppScreen() {
        safeStart(android.provider.Settings.ACTION_MANAGE_APPLICATIONS_SETTINGS, getString(R.string.appsettings));
    }

    private void safeStart(String intentString, String thing) {
        Intent intent = null;
        try {
            intent = new Intent(intentString);
            startActivity(intent);
        } catch (Throwable th) {
            // Log.e(TAG, "Could not start activity: " + intent, th);
            if (thing != null) {
                Toast t = Toast.makeText(getActivity(), getString(R.string.opening) + thing + getString(R.string.notsupported),
                        Toast.LENGTH_SHORT);
                t.show();
            }
        }
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
    public void onSaveInstanceState(Bundle outState) {
//        outState.putSerializable("savedInstance", this);
        super.onSaveInstanceState(outState);
    }
}

