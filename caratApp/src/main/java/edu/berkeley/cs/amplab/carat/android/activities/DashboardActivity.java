package edu.berkeley.cs.amplab.carat.android.activities;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.WindowManager;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.fragments.AboutFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.BugsFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.DashboardFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.EnableInternetDialogFragment;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;

public class DashboardActivity extends ActionBarActivity {

    private String batteryLife;
    private String bugAmount, hogAmount, actionsAmount;
    private int jScore;

    private FragmentManager fragmentManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().setStatusBarColor(getResources().getColor(R.color.statusbar_color));
        }
        ;
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dashboard);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setHomeButtonEnabled(true);
    }

    @Override
    protected void onResume() {
        new Thread() {
            public void run() {
                ((CaratApplication) getApplication()).refreshUi();
                // This should only run if we are on that tab, so onResume of SummaryFragment should be enough.
                //refreshSummaryFragment();
            }
        }.start();
        super.onResume();
        setValues();
        fragmentManager = getSupportFragmentManager();
        DashboardFragment dashboardFragment = new DashboardFragment();
        fragmentManager.beginTransaction()
                .add(R.id.fragment_holder, dashboardFragment).commit();

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_carat, menu);
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
                break;
            case R.id.action_hide_apps:
                break;
            case R.id.action_feedback:
                break;
            case R.id.action_about:
                AboutFragment aboutFragment = new AboutFragment();
                replaceFragment(aboutFragment, Constants.FRAGMENT_ABOUT_TAG);
                break;
            case android.R.id.home:
                if (fragmentManager.getBackStackEntryCount() > 0) {
                    fragmentManager.popBackStack();
                } else {
                    getSupportActionBar().setDisplayHomeAsUpEnabled(false);
                }
                return true;
            default:
                break;

        }

        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onPause() {
        super.onPause();
        SamplingLibrary.resetRunningProcessInfo();
        if (fragmentManager != null) {
            fragmentManager.popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE);
            fragmentManager = null;
        }

    }

    private void setValues() {
        setJScore();
        setBatteryLife();
        setBugAmount();
        setHogAmount();
        setActionsAmount();
    }

    public void setUpActionBar(int resId, boolean canGoBack) {
        getSupportActionBar().setIcon(R.drawable.back_arrow);
        getSupportActionBar().setDisplayHomeAsUpEnabled(canGoBack);
        getSupportActionBar().setDisplayShowHomeEnabled(canGoBack);
        getSupportActionBar().setTitle(resId);
    }

    private void setJScore() {
        jScore = CaratApplication.getJscore();
    }

    private void setBatteryLife() {
        batteryLife = CaratApplication.myDeviceData.getBatteryLife();
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

    // TODO GET ACTIONS
    public void setActionsAmount() {
        actionsAmount = "4";
    }

    public void replaceFragment(Fragment fragment, String tag) {
        // use a fragment tag, so that later on we can find the currently displayed fragment
        final String FRAGMENT_TAG = tag;
        // replace the fragment, using a fragment transaction
        FragmentTransaction transaction = fragmentManager.beginTransaction();

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR2 || !isDestroyed()) {
            transaction.replace(R.id.fragment_holder, fragment, FRAGMENT_TAG)
                    .addToBackStack(FRAGMENT_TAG).commitAllowingStateLoss();
        }
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

    }

    public void shareOnTwitter() {

    }

    public void shareViaEmail() {

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

    @Override
    public void onBackPressed() {
        if (fragmentManager.getBackStackEntryCount() == 0) {
            Intent intent = new Intent(Intent.ACTION_MAIN);
            intent.addCategory(Intent.CATEGORY_HOME);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(intent);
            finish();
        } else {
            fragmentManager.popBackStack();
        }
    }


}


