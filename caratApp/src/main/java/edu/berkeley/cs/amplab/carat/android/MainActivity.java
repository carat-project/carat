package edu.berkeley.cs.amplab.carat.android;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.flurry.android.FlurryAgent;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

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
    private float cpu;
    private int jScore;
    private long[] lastPoint = null;

    private TextView actionBarTitle;
    private ImageView backArrow;
    private ProgressBar progressCircle;
    private DashboardFragment dashboardFragment;

    private Tracker tracker;

    public int mHogs = Constants.VALUE_NOT_AVAILABLE,
            mBugs = Constants.VALUE_NOT_AVAILABLE,
            mActions = Constants.VALUE_NOT_AVAILABLE;

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
        setProgressCircle(false);
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
                giveFeedback();
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

    public void setValues() {
        setJScore();
        setBatteryLife(CaratApplication.myDeviceData.getBatteryLife());
        setBugAmount();
        setHogAmount();
        setActionsAmount();
        setCpuValue();
        Log.d("debug", "*** Values set");
    }

    public void setUpActionBar(int resId, boolean canGoBack) {
        getSupportActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
        getSupportActionBar().setCustomView(R.layout.actionbar);
        actionBarTitle = (TextView) getSupportActionBar().getCustomView().findViewById(R.id.action_bar_title);
        backArrow = (ImageView) getSupportActionBar().getCustomView().findViewById(R.id.back_arrow);
        backArrow.setOnClickListener(this);
        actionBarTitle.setText(resId);
        if (canGoBack) {
            backArrow.setVisibility(View.VISIBLE);
        } else {
            backArrow.setVisibility(View.GONE);
        }
    }

    public void setProgressCircle(boolean visibility) {
        progressCircle = (ProgressBar) getSupportActionBar().getCustomView().findViewById(R.id.action_bar_progress_circle);
        progressCircle.getIndeterminateDrawable().setColorFilter(0xF2FFFFFF,
                android.graphics.PorterDuff.Mode.SRC_ATOP);
        if (visibility) {
            progressCircle.setVisibility(View.VISIBLE);
        } else {
            progressCircle.setVisibility(View.GONE);
        }
    }

    public void refreshSummaryFragment() {
        if (getSupportFragmentManager() != null) {
            if (getSupportFragmentManager().getBackStackEntryCount() == 0) {
                dashboardFragment.scheduleRefresh();
            }
        }
    }

    private void setCpuValue() {
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

    private void setJScore() {
        jScore = CaratApplication.getJscore();
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

    public void setBugAmount() {
        if (CaratApplication.getStorage().getBugReport() != null) {
            bugAmount = String.valueOf(CaratApplication.getStorage().getBugReport().length);
        } else {
            bugAmount = "0";
        }

    }

    public String getHogAmount() {
        return hogAmount;
    }

    public void setHogAmount() {
        if (CaratApplication.getStorage().getHogReport() != null) {
            hogAmount = String.valueOf(CaratApplication.getStorage().getHogReport().length);
        } else {
            hogAmount = "0";
        }
    }

    public String getActionsAmount() {
        return actionsAmount;
    }

    public void setActionsAmount() {
        int sum = 0;
        if (CaratApplication.getStorage().getBugReport() != null) {
            sum = CaratApplication.getStorage().getBugReport().length;
        }
        if (CaratApplication.getStorage().getHogReport() != null) {
            sum += CaratApplication.getStorage().getHogReport().length;
        }
        actionsAmount = String.valueOf(sum);
    }

    public void replaceFragment(Fragment fragment, String tag) {
        final String FRAGMENT_TAG = tag;
        setProgressCircle(false);
        boolean fragmentPopped = getSupportFragmentManager().popBackStackImmediate(FRAGMENT_TAG, 0);

        if (!fragmentPopped) {
            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();

            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR2 || !isDestroyed()) {
                transaction.replace(R.id.fragment_holder, fragment, FRAGMENT_TAG)
                        .addToBackStack(FRAGMENT_TAG).commitAllowingStateLoss();
            }
        }

    }

    public void setHideSmallPreference() {
        PreferenceListDialog preferenceListDialog = new PreferenceListDialog(this, getString(R.string.hog_hide_threshold));
        preferenceListDialog.showDialog();
    }

    @SuppressLint("NewApi")
    private void getStatsFromServer() {
        PrefetchData prefetchData = new PrefetchData(this);
        // run this asyncTask in a new thread [from the thread pool] (run in parallel to other asyncTasks)
        // (do not wait for them to finish, it takes a long time)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
            prefetchData.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
        else
            prefetchData.execute();
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
        intent.putExtra(Intent.EXTRA_TEXT, caratText);
        startActivity(Intent.createChooser(intent, "Send email"));
    }

    public void giveFeedback() {
        Intent intent = new Intent(Intent.ACTION_SENDTO, Uri.fromParts("mailto", "carat@cs.helsinki.fi", null));
        startActivity(Intent.createChooser(intent, "Send email"));
    }

    public String getLastUpdated() {
        String lastUpdated;
        long lastUpdateTime = CaratApplication.myDeviceData.getLastReportsTimeMillis();
        long min = CaratApplication.myDeviceData.getFreshnessMinutes();
        long hour = CaratApplication.myDeviceData.getFreshnessHours();

        if (lastUpdateTime <= 0)
            lastUpdated = getString(R.string.neverupdated);
        else if (min == 0)
            lastUpdated = getString(R.string.updatedjustnow);
        else
            lastUpdated = getString(R.string.updated)
                    + " " + hour + "h " + min + "m " + getString(R.string.ago);

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
        return mHogs != Constants.VALUE_NOT_AVAILABLE && mBugs != Constants.VALUE_NOT_AVAILABLE;
    }

    private boolean isStatsDataStoredInPref() {
        int hogs = CaratApplication.mPrefs.getInt(Constants.STATS_HOGS_COUNT_PREFERENCE_KEY, Constants.VALUE_NOT_AVAILABLE);
        int bugs = CaratApplication.mPrefs.getInt(Constants.STATS_BUGS_COUNT_PREFERENCE_KEY, Constants.VALUE_NOT_AVAILABLE);
        if (hogs != Constants.VALUE_NOT_AVAILABLE && bugs != Constants.VALUE_NOT_AVAILABLE) {
            mHogs = hogs;
            mBugs = bugs;
            mActions = hogs + bugs;
            return true;
        } else {
            return false;
        }
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

    @Override
    public void onBackPressed() {
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


