package edu.berkeley.cs.amplab.carat.android.activities;

import android.annotation.SuppressLint;
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

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.fragments.DashboardFragment;

public class DashboardActivity extends ActionBarActivity {

    private String batteryLife;
    private int jScore;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getStatsFromServer();
        setJScore();
        setBatteryLife();
        setContentView(R.layout.activity_dashboard);
        DashboardFragment dashboardFragment = new DashboardFragment();
        getSupportFragmentManager().beginTransaction()
                .add(R.id.fragment_holder, dashboardFragment).commit();
    }

    @Override
    protected void onResume() {
        super.onResume();

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_carat, menu);
        return super.onCreateOptionsMenu(menu);

    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        switch(id) {
            case R.id.action_wifi_only:
                break;
            case R.id.action_hide_apps:
                break;
            case R.id.action_feedback:
                break;
            case R.id.action_about:
                break;
            case android.R.id.home:
                FragmentManager fm = getSupportFragmentManager();
                if (fm.getBackStackEntryCount() > 0) {
                    if (fm.getBackStackEntryCount() == 1) {
                        getSupportActionBar().setDisplayHomeAsUpEnabled(false);
                    }
                    fm.popBackStack();
                }
                return true;

        }

        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
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

    public void replaceFragment(Fragment fragment, String tag) {
        // use a fragment tag, so that later on we can find the currently displayed fragment
        final String FRAGMENT_TAG = tag;
        // replace the fragment, using a fragment transaction
        FragmentManager fragmentManager = getSupportFragmentManager();
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

}

