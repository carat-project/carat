package edu.berkeley.cs.amplab.carat.android;

import android.annotation.SuppressLint;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.app.AlertDialog;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.flurry.android.FlurryAgent;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Properties;
import java.util.concurrent.TimeUnit;

import edu.berkeley.cs.amplab.carat.android.fragments.GlobalFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.HogStatsFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.TabbedFragment;
import edu.berkeley.cs.amplab.carat.android.protocol.AsyncStats;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;
import edu.berkeley.cs.amplab.carat.android.utils.PrefetchData;
import edu.berkeley.cs.amplab.carat.android.activities.TutorialActivity;
import edu.berkeley.cs.amplab.carat.android.dialogs.PreferenceListDialog;
import edu.berkeley.cs.amplab.carat.android.fragments.AboutFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.DashboardFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.EnableInternetDialogFragment;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.android.utils.Tracker;

public class MainActivity extends ActionBarActivity implements View.OnClickListener {

    private static final String FLURRY_KEYFILE = "flurry.properties";

    private String batteryLife;
    private String bugAmount, hogAmount, actionsAmount;
    private int staticActionsAmount;
    private float cpu;
    private int jScore;
    private long[] lastPoint = null;
    private String lastUpdatingValue;
    private String lastSampleValue;

    private boolean shouldAddTabs = true;

    private TextView actionBarTitle;
    private RelativeLayout backArrow;
    private ProgressBar progressCircle;
    private DashboardFragment dashboardFragment;

    private HashMap<String, Integer> androidDevices, iosDevices;

    private Tracker tracker;

    public int appWellbehaved = Constants.VALUE_NOT_AVAILABLE,
            appHogs = Constants.VALUE_NOT_AVAILABLE,
            appBugs = Constants.VALUE_NOT_AVAILABLE;

    public int mWellbehaved = Constants.VALUE_NOT_AVAILABLE,
            mHogs = Constants.VALUE_NOT_AVAILABLE,
            mBugs = Constants.VALUE_NOT_AVAILABLE,
            mActions = Constants.VALUE_NOT_AVAILABLE;

    public int iosWellbehaved = Constants.VALUE_NOT_AVAILABLE,
            iosHogs = Constants.VALUE_NOT_AVAILABLE,
            iosBugs = Constants.VALUE_NOT_AVAILABLE;

    public int userHasBug = Constants.VALUE_NOT_AVAILABLE,
            userHasNoBugs = Constants.VALUE_NOT_AVAILABLE;

    public static abstract class DialogCallback<T>{
        public abstract void run(T value);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        getWindow().requestFeature(Window.FEATURE_INDETERMINATE_PROGRESS);
        getWindow().requestFeature(Window.FEATURE_PROGRESS);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            getWindow().setStatusBarColor(getResources().getColor(R.color.statusbar_color));
        }

        SharedPreferences p = PreferenceManager.getDefaultSharedPreferences(this);
        PreferenceManager.setDefaultValues(this, R.xml.preferences, false);
        if (!p.getBoolean(getResources().getString(R.string.save_accept_eula), false)) {
            Intent i = new Intent(this, TutorialActivity.class);
            this.startActivityForResult(i, Constants.REQUESTCODE_ACCEPT_EULA);
        }
        getStatsFromServer();
        super.onCreate(savedInstanceState);

        CaratApplication.setMain(this);
        tracker = Tracker.getInstance(this);
        tracker.trackUser("caratstarted", getTitle());

        // TODO SHOW DIALOG, NOT FRAGMENT
        if (!CaratApplication.isInternetAvailable()) {
            EnableInternetDialogFragment dialog = new EnableInternetDialogFragment();
            dialog.show(getSupportFragmentManager(), "dialog");
        }

        setContentView(R.layout.activity_dashboard);
        dashboardFragment = new DashboardFragment();
        getSupportFragmentManager().beginTransaction()
                .add(R.id.fragment_holder, dashboardFragment).commit();
        getSupportFragmentManager().addOnBackStackChangedListener(new FragmentManager.OnBackStackChangedListener() {
            @Override
            public void onBackStackChanged() {
                onFragmentPop();
            }
        });

        // TODO: Add this as an accessible flag

        staticActionsAmount = CaratApplication.getStaticActions().size();
        lastUpdatingValue = getString(R.string.dashboard_text_loading);
    }

    @Override
    protected void onStart() {
        super.onStart();

        String secretKey = null;
        Properties properties = new Properties();
        try {
            InputStream raw = MainActivity.this.getAssets().open(FLURRY_KEYFILE);
            if (raw != null) {
                properties.load(raw);
                if (properties.containsKey("secretkey"))
                    secretKey = properties.getProperty("secretkey", "secretkey");
                // Log.d(TAG, "Set Flurry secret key.");
            } else {
                // Log.e(TAG, "Could not open Flurry key file!");
            }
        } catch (IOException e) {
            // Log.e(TAG, "Could not open Flurry key file: " + e.toString());
        }
        if (secretKey != null) {
            FlurryAgent.onStartSession(getApplicationContext(), secretKey);
        }

    }

    @Override
    protected void onStop() {
        super.onStop();
        FlurryAgent.onEndSession(getApplicationContext());
    }

    @Override
    protected void onResume() {
        if ((!isStatsDataAvailable()) && CaratApplication.isInternetAvailable()) {
            getStatsFromServer();
        }

        new Thread() {
            public void run() {
                ((CaratApplication) getApplication()).refreshUi();
            }
        }.start();

        super.onResume();
        setValues();

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_carat, menu);
        final SharedPreferences p = PreferenceManager.getDefaultSharedPreferences(this);
        final boolean useWifiOnly = p.getBoolean(getString(R.string.wifi_only_key), false);
        menu.findItem(R.id.action_wifi_only).setChecked(useWifiOnly);
        //setProgressCircle(false);
        return super.onCreateOptionsMenu(menu);

    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        switch (id) {
            case R.id.action_wifi_only:
                if (item.isChecked()) {
                    SharedPreferences p = PreferenceManager.getDefaultSharedPreferences(this);
                    p.edit().putBoolean(getString(R.string.wifi_only_key), false).commit();
                    item.setChecked(false);
                } else {
                    SharedPreferences p = PreferenceManager.getDefaultSharedPreferences(this);
                    p.edit().putBoolean(getString(R.string.wifi_only_key), true).commit();
                    item.setChecked(true);
                }
                break;
            case R.id.action_hide_apps:
                setHideSmallPreference();
                break;
            case R.id.action_feedback:
                final String[] choices = new String[]{
                        "Rate us on Play Store",
                        "Problem with app, please specify",
                        "No J-Score after 7 days of use",
                        "Other, please specify"
                };
                showOptionDialog("Give feedback", new DialogCallback<Integer>() {
                    @Override
                    public void run(Integer choice) {
                        if(choice == 0) showStorePage();
                        else giveFeedback(choices, choice);
                    }
                }, choices);
                break;
            case R.id.action_about:
                AboutFragment aboutFragment = new AboutFragment();
                replaceFragment(aboutFragment, Constants.FRAGMENT_ABOUT_TAG);
                break;
            case android.R.id.home:
                if (getSupportFragmentManager().getBackStackEntryCount() > 0) {
                    getSupportFragmentManager().popBackStack();
                } else {
                    getSupportActionBar().setDisplayHomeAsUpEnabled(false);
                }
                return true;
            default:
                break;

        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onPause() {
        super.onPause();
        SamplingLibrary.resetRunningProcessInfo();
    }

    private void showStorePage() {
        final String appPackageName = getPackageName();
        try {
            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + appPackageName)));
         }  catch (Exception e) {
            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=" + appPackageName)));
        }
    }

    public void setValues() {
        setJScore(CaratApplication.getJscore());
        setBatteryLife(CaratApplication.myDeviceData.getBatteryLife());
        SimpleHogBug[] b = CaratApplication.getStorage().getBugReport();
        SimpleHogBug[] h = CaratApplication.getStorage().getHogReport();
        int actionsAmount = 0;
        if (b != null) {
            int bugsAmount = CaratApplication.filterByVisibility(b).size();
            setBugAmount(String.valueOf(bugsAmount));
            actionsAmount += CaratApplication.filterByRunning(b).size();
        } else {
            setBugAmount("0");
        }
        if (h != null) {
            int hogsAmount = CaratApplication.filterByVisibility(h).size();
            setHogAmount(String.valueOf(hogsAmount));
            actionsAmount += CaratApplication.filterByRunning(h).size();
        } else {
            setHogAmount("0");
        }

        setActionsAmount(actionsAmount);

        setCpuValue();
        Log.d("debug", "*** Values set");
    }

    public void enableTabbedNavigation(final TabbedFragment fragment){
        ActionBar actionBar = getSupportActionBar();
        if(actionBar == null) return;
        actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_TABS);
        ActionBar.TabListener tabListener = new ActionBar.TabListener() {
            @Override
            public void onTabSelected(ActionBar.Tab tab, FragmentTransaction ft) {
                ViewPager pager = fragment.getViewPager();

                if(pager == null) return;
                pager.setCurrentItem(tab.getPosition());
            }

            @Override
            public void onTabUnselected(ActionBar.Tab tab, FragmentTransaction ft) {

            }

            @Override
            public void onTabReselected(ActionBar.Tab tab, FragmentTransaction ft) {

            }
        };

        if(shouldAddTabs){
            actionBar.addTab(actionBar.newTab().setText("My device").setTabListener(tabListener));
            actionBar.addTab(actionBar.newTab().setText("Global").setTabListener(tabListener));
            shouldAddTabs = false;
        }

    }

    public void setUpActionBar(int resId, boolean canGoBack) {
        this.setUpActionBar(getString(resId), canGoBack);
    }

    public void setUpActionBar(String title, boolean canGoBack){
        getSupportActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
        getSupportActionBar().setCustomView(R.layout.actionbar);
        actionBarTitle = (TextView) getSupportActionBar().getCustomView().findViewById(R.id.action_bar_title);
        backArrow = (RelativeLayout) getSupportActionBar().getCustomView().findViewById(R.id.back_arrow);
        backArrow.setOnClickListener(this);
        actionBarTitle.setText(title);
        if (canGoBack) {
            backArrow.setVisibility(View.VISIBLE);
        } else {
            backArrow.setVisibility(View.GONE);
        }
    }

    public void setProgressCircle(boolean visibility) {
        backArrow = (RelativeLayout) getSupportActionBar().getCustomView().findViewById(R.id.back_arrow);
        progressCircle = (ProgressBar) getSupportActionBar().getCustomView().findViewById(R.id.action_bar_progress_circle);
        progressCircle.getIndeterminateDrawable().setColorFilter(0xF2FFFFFF,
                android.graphics.PorterDuff.Mode.SRC_ATOP);
        if((backArrow.getVisibility() != View.VISIBLE) && visibility){
            progressCircle.setVisibility(View.VISIBLE);
        } else {
            progressCircle.setVisibility(View.GONE);
        }
    }

    public void refreshCurrentFragment() {
        if (getSupportFragmentManager() != null) {
            Fragment fragment = getSupportFragmentManager().findFragmentById(R.id.fragment_holder);
            if(fragment instanceof GlobalFragment){
                ((GlobalFragment) fragment).refresh();
            }
            else if (fragment instanceof  DashboardFragment
                    || getSupportFragmentManager().getBackStackEntryCount() == 0) {
                dashboardFragment.refresh();
            }
        }
    }

    public void refreshHogStatsFragment() {
        if (getSupportFragmentManager() != null) {
            Fragment fragment = getSupportFragmentManager().findFragmentById(R.id.fragment_holder);
            if(fragment instanceof HogStatsFragment){
                ((HogStatsFragment) fragment).refresh();
            }
        }
    }

    public void refreshDashboardProgress() {
        if (getSupportFragmentManager() != null) {
            Fragment fragment = getSupportFragmentManager().findFragmentById(R.id.fragment_holder);
            if (fragment instanceof DashboardFragment) {
                ((DashboardFragment) fragment).refreshProgress();
            }
        }
    }

    public void onFragmentPop(){
        Fragment top = getSupportFragmentManager().findFragmentById(R.id.fragment_holder);
        if(top instanceof DashboardFragment){
            ((DashboardFragment) top).refreshProgress();
        }
    }

    public void setCpuValue() {
        long[] currentPoint = SamplingLibrary.readUsagePoint();
        float cpu = 0;
        if (lastPoint == null) {
            lastPoint = currentPoint;
        } else {
            cpu = (float) SamplingLibrary.getUsage(lastPoint, currentPoint);
        }
        this.cpu = cpu;

    }

    public float getCpuValue() {
        return cpu;
    }

    public void setJScore(int jScore) {
        this.jScore = jScore;
    }

    public void setBatteryLife(String batteryLife) {
        this.batteryLife = batteryLife;
    }

    public String getBatteryLife() {
        return batteryLife;
    }

    public int getJScore() {
        return jScore;
    }

    public String getBugAmount() {
        return bugAmount;
    }

    public void setBugAmount(String bugAmount) {
        this.bugAmount = bugAmount;

    }

    public String getHogAmount() {
        return hogAmount;
    }

    public void setHogAmount(String hogAmount) {
        this.hogAmount = hogAmount;
    }

    public String getActionsAmount() {
        return actionsAmount;
    }

    public void setStaticActionsAmount(int amount){
        staticActionsAmount = amount;
    }

    public int getStaticActionsAmount(){
        return staticActionsAmount;
    }

    public void setActionsAmount(int actionsAmount) {
        this.actionsAmount = String.valueOf(actionsAmount);
    }

    public void replaceFragment(Fragment fragment, String tag){
        final String FRAGMENT_TAG = tag;
        setProgressCircle(false);
        boolean fragmentPopped = getSupportFragmentManager().popBackStackImmediate(FRAGMENT_TAG, 0);

        if (!fragmentPopped) {
            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
            transaction.setCustomAnimations(R.anim.slide_in_right, R.anim.slide_out_left, R.anim.slide_in_left, R.anim.slide_out_right);

            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR2 || !isDestroyed()) {
                transaction.replace(R.id.fragment_holder, fragment, FRAGMENT_TAG)
                        .addToBackStack(FRAGMENT_TAG).commitAllowingStateLoss();
            }
        }
    }

    public void setTitleUpdating(String what) {
        lastUpdatingValue = what;
        dashboardFragment.setUpdatingValue(what);
    }

    public void setSampleProgress(String what){
        lastSampleValue = what;
        dashboardFragment.setSampleProgress(what);
    }

    public String getSampleValue(){
        return lastSampleValue;
    }

    public String getUpdatingValue(){
        return lastUpdatingValue;
    }

    public void setTitleUpdatingFailed(String what) {
        setTitle(getString(R.string.didntget) + " " + what);
    }

    public void setHideSmallPreference() {
        PreferenceListDialog preferenceListDialog = new PreferenceListDialog(this, getString(R.string.hog_hide_threshold));
        preferenceListDialog.showDialog();
    }

    @SuppressLint("NewApi")
    private void getStatsFromServer() {
        PrefetchData prefetchData = new PrefetchData(this);
        AsyncStats hogStats = new AsyncStats(this);
        // run this asyncTask in a new thread [from the thread pool] (run in parallel to other asyncTasks)
        // (do not wait for them to finish, it takes a long time)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB){
            prefetchData.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
            hogStats.executeOnExecutor(AsyncStats.THREAD_POOL_EXECUTOR);
        } else {
            hogStats.execute();
            prefetchData.execute();
        }
    }

    public void shareOnFacebook() {
        String caratText = getString(R.string.sharetext1) + " " + getJScore() + getString(R.string.sharetext2);
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.setType("text/plain");
        intent.putExtra(Intent.EXTRA_TEXT, caratText);
        startActivity(Intent.createChooser(intent, "facebook"));
    }

    public void shareOnTwitter() {
        String caratText = getString(R.string.sharetext1) + " " + getJScore() + getString(R.string.sharetext2);
        String tweetUrl = "https://twitter.com/intent/tweet?text="
                + caratText;
        Uri uri = Uri.parse(tweetUrl);
        startActivity(new Intent(Intent.ACTION_VIEW, uri));
    }

    public void shareViaEmail() {
        String caratText = getString(R.string.sharetext1) + " " + getJScore() + getString(R.string.sharetext2);
        Intent intent = new Intent(Intent.ACTION_SENDTO, Uri.fromParts("mailto", "", null));
        intent.putExtra(Intent.EXTRA_SUBJECT, getString(R.string.sharetitle));
        intent.putExtra(Intent.EXTRA_TEXT, caratText);
        startActivity(Intent.createChooser(intent, "Send email"));
    }

    // General purpose multi-choice dialog with a callback
    public void showOptionDialog(String title, final DialogCallback<Integer> callback, final String... options){
        if(title == null || title.length() == 0){
            throw new IllegalArgumentException("Dialog title cannot be null!");
        }
        if(options == null || options.length == 0){
            throw new IllegalArgumentException("You need to specify at least one option!");
        }

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(title);
        builder.setItems(options, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if(callback != null){
                    callback.run(which);
                }
            }
        });
        builder.show();
    }

    public void giveFeedback(String[] options, int which) {
        float memoryUsedConverted;
        float memoryActiveConverted = 0;

        int[] totalAndUsed = SamplingLibrary.readMeminfo();
        memoryUsedConverted = 1 - ((float) totalAndUsed[0] / totalAndUsed[1]);
        if (totalAndUsed.length > 2) {
            memoryActiveConverted = (float) totalAndUsed[2] / (totalAndUsed[3] + totalAndUsed[2]);
        }

        String versionName = BuildConfig.VERSION_NAME;
        String title = "[Carat][Android] Feedback from " + Build.MODEL + ", v"+versionName;

        String caratVersion = "Carat " + versionName;
        String feedback = "Feedback: " + options[which];
        String caratId = "Carat ID: " + CaratApplication.myDeviceData.getCaratId();
        String jScore = "JScore: " + getJScore();
        String osVersion = "OS Version: " + SamplingLibrary.getOsVersion();
        String deviceModel = "Device Model: " + Build.MODEL;
        String memoryUsed = "Memory Used: " + (memoryUsedConverted * 100) + "%";
        String memoryActive = "Memory Active: " + (memoryActiveConverted * 100) + "%";
        String pleaseSpecify = "";
        if(which == 1 || which == 3) {
            pleaseSpecify = "\n\nPlease write your feedback here";
        }

        Intent intent = new Intent(Intent.ACTION_SENDTO, Uri.fromParts("mailto", "carat@cs.helsinki.fi", null));
        intent.putExtra(Intent.EXTRA_SUBJECT, title);
        intent.putExtra(Intent.EXTRA_TEXT, caratVersion + "\n" + feedback + "\n" + caratId + "\n" + jScore +
                "\n" + osVersion + "\n" + deviceModel + "\n" + memoryUsed + "\n" + memoryActive + pleaseSpecify);

        startActivity(Intent.createChooser(intent, "Send email"));
    }

    public String getLastUpdated() {
        String lastUpdated;
        long freshness = CaratApplication.getStorage().getFreshness();
        long elapsed = System.currentTimeMillis() - freshness;
        long hour = TimeUnit.MILLISECONDS.toHours(elapsed);
        long min =  TimeUnit.MILLISECONDS.toMinutes(elapsed);
        long days = TimeUnit.MILLISECONDS.toDays(elapsed);

        if (CaratApplication.getStorage().getFreshness() <=0){
            lastUpdated = getString(R.string.neverupdated);
        }
        else if (min == 0 && hour == 0){
            lastUpdated = getString(R.string.updatedjustnow);
        }
        else if (days > 0){
            lastUpdated = getString(R.string.updated) + " " + days + "d " + hour + "h " + getString(R.string.ago);
        }
        else {
            lastUpdated = getString(R.string.updated) + " " + hour + "h " + min + "m " + getString(R.string.ago);
        }

        return lastUpdated;
    }

    public boolean isStatsDataAvailable() {
        if (isStatsDataLoaded()) {
            return true;
        } else {
            return isStatsDataStoredInPref();
        }
    }

    private boolean isStatsDataLoaded() {
        return mHogs != Constants.VALUE_NOT_AVAILABLE && mBugs != Constants.VALUE_NOT_AVAILABLE
                && appBugs != Constants.VALUE_NOT_AVAILABLE && iosHogs != Constants.VALUE_NOT_AVAILABLE
                && userHasBug != Constants.VALUE_NOT_AVAILABLE;
    }

    private boolean isStatsDataStoredInPref() {
        int appWellbehaved = CaratApplication.mPrefs.getInt(Constants.STATS_APP_WELLBEHAVED_COUNT_PREFERENCE_KEY, Constants.VALUE_NOT_AVAILABLE);
        int appHogs = CaratApplication.mPrefs.getInt(Constants.STATS_APP_HOGS_COUNT_PREFERENCE_KEY, Constants.VALUE_NOT_AVAILABLE);
        int appBugs = CaratApplication.mPrefs.getInt(Constants.STATS_APP_BUGS_COUNT_PREFERENCE_KEY, Constants.VALUE_NOT_AVAILABLE);

        int wellbehaved = CaratApplication.mPrefs.getInt(Constants.STATS_WELLBEHAVED_COUNT_PREFERENCE_KEY, Constants.VALUE_NOT_AVAILABLE);
        int hogs = CaratApplication.mPrefs.getInt(Constants.STATS_HOGS_COUNT_PREFERENCE_KEY, Constants.VALUE_NOT_AVAILABLE);
        int bugs = CaratApplication.mPrefs.getInt(Constants.STATS_BUGS_COUNT_PREFERENCE_KEY, Constants.VALUE_NOT_AVAILABLE);

        int iosWellbehaved = CaratApplication.mPrefs.getInt(Constants.STATS_IOS_WELLBEHAVED_COUNT_PREFERENCE_KEY, Constants.VALUE_NOT_AVAILABLE);
        int iosHogs = CaratApplication.mPrefs.getInt(Constants.STATS_IOS_HOGS_COUNT_PREFERENCE_KEY, Constants.VALUE_NOT_AVAILABLE);
        int iosBugs = CaratApplication.mPrefs.getInt(Constants.STATS_IOS_BUGS_COUNT_PREFERENCE_KEY, Constants.VALUE_NOT_AVAILABLE);

        int userBugs = CaratApplication.mPrefs.getInt(Constants.STATS_USER_BUGS_COUNT_PREFERENCE_KEY, Constants.VALUE_NOT_AVAILABLE);
        int userNoBugs = CaratApplication.mPrefs.getInt(Constants.STATS_USER_NO_BUGS_COUNT_PREFERENCE_KEY, Constants.VALUE_NOT_AVAILABLE);

        if (wellbehaved != Constants.VALUE_NOT_AVAILABLE && hogs != Constants.VALUE_NOT_AVAILABLE &&
                bugs != Constants.VALUE_NOT_AVAILABLE && appWellbehaved != Constants.VALUE_NOT_AVAILABLE
                && iosWellbehaved != Constants.VALUE_NOT_AVAILABLE && userBugs != Constants.VALUE_NOT_AVAILABLE) {
            this.appWellbehaved = appWellbehaved;
            this.appBugs = appBugs;
            this.appHogs = appHogs;
            mWellbehaved = wellbehaved;
            mHogs = hogs;
            mBugs = bugs;
            mActions = hogs + bugs;
            this.iosWellbehaved = iosWellbehaved;
            this.iosBugs = iosBugs;
            this.iosHogs = iosHogs;
            this.userHasBug = userBugs;
            this.userHasNoBugs = userNoBugs;
            return true;
        } else {
            return false;
        }
    }

    /* public HashMap<String, Integer> getIosDevices() {
        return iosDevices;
    }

    public void setIosDevices(HashMap<String, Integer> iosDevices) {
        this.iosDevices = iosDevices;
    } */

    public HashMap<String, Integer> getAndroidDevices() {
        return androidDevices;
    }

    public void setAndroidDevices(HashMap<String, Integer> androidDevices) {
        this.androidDevices = androidDevices;
    }

    public void GoToWifiScreen() {
        safeStart(android.provider.Settings.ACTION_WIFI_SETTINGS, getString(R.string.wifisettings));
    }

    public void safeStart(String intentString, String thing) {
        Intent intent = null;
        try {
            intent = new Intent(intentString);
            startActivity(intent);
        } catch (Throwable th) {
            if (thing != null) {
                Toast t = Toast.makeText(this, getString(R.string.opening) + thing + getString(R.string.notsupported),
                        Toast.LENGTH_SHORT);
                t.show();
            }
        }
    }

    public void hideKeyboard(View v){
        InputMethodManager imm = (InputMethodManager) this.getSystemService(INPUT_METHOD_SERVICE);
        if (v == null) v = this.getCurrentFocus();
        if (v == null) v = new View(this);
        imm.hideSoftInputFromWindow(v.getApplicationWindowToken(), 0);
    }

    @Override
    public void onBackPressed() {
        hideKeyboard(null);
        if (getSupportFragmentManager().getBackStackEntryCount() == 0) {
            Intent intent = new Intent(Intent.ACTION_MAIN);
            intent.addCategory(Intent.CATEGORY_HOME);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(intent);
            finish();
        } else {
            getSupportFragmentManager().popBackStack();
        }
    }


    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.back_arrow) {
            hideKeyboard(null);
            if (getSupportFragmentManager().getBackStackEntryCount() == 0) {
                Intent intent = new Intent(Intent.ACTION_MAIN);
                intent.addCategory(Intent.CATEGORY_HOME);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                startActivity(intent);
                finish();
            } else {
                getSupportFragmentManager().popBackStack();
            }
        }
    }
}


