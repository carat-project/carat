package edu.berkeley.cs.amplab.carat.android.activities;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.support.v4.app.Fragment;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;

import java.util.List;
import java.util.Vector;

import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.fragments.tutorial.BugsTutorialFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.tutorial.HogsTutorialFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.tutorial.MainTutorialFragment;
import edu.berkeley.cs.amplab.carat.android.ui.adapters.TutorialPagerAdapter;

public class TutorialActivity extends ActionBarActivity implements View.OnClickListener, ViewPager.OnPageChangeListener {

    private PagerAdapter adapterViewPager;
    private ViewPager vPager;
    private Button acceptButton;
    private ImageView dot0, dot1, dot2;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_tutorial);
        initViewRefs();
        initialisePaging();
    }

    @Override
    public void onBackPressed() {
        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.addCategory(Intent.CATEGORY_HOME);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
        finish();
        System.exit(0);
    }

    private void initViewRefs() {
        dot0 = (ImageView) findViewById(R.id.page_indicator_0);
        dot1 = (ImageView) findViewById(R.id.page_indicator_1);
        dot2 = (ImageView) findViewById(R.id.page_indicator_2);

        acceptButton = (Button) findViewById(R.id.tutorial_accept_button);
        acceptButton.setOnClickListener(this);
        acceptButton.setClickable(false);
    }

    private void initialisePaging() {
        vPager = (ViewPager) findViewById(R.id.tutorial_view_pager);
        List<Fragment> fragments = new Vector<Fragment>();
        fragments.add(Fragment.instantiate(this, MainTutorialFragment.class.getName()));
        fragments.add(Fragment.instantiate(this, BugsTutorialFragment.class.getName()));
        fragments.add(Fragment.instantiate(this, HogsTutorialFragment.class.getName()));
        this.adapterViewPager = new TutorialPagerAdapter(super.getSupportFragmentManager(), fragments);
        vPager.setAdapter(adapterViewPager);
        vPager.setOnPageChangeListener(this);
        vPager.setCurrentItem(0);

    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.tutorial_accept_button) {
            /*Intent returnIntent = new Intent();
            setResult(RESULT_OK, returnIntent);
            SharedPreferences p = PreferenceManager.getDefaultSharedPreferences(this);
            p.edit().putBoolean(getString(R.string.save_accept_eula), true).commit();
            finish(); */
            Intent i = new Intent(this, DashboardActivity.class);
            startActivity(i);
        }
    }

    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
    }

    @Override
    public void onPageSelected(int position) {
        if (position == 0) {
            dot0.setImageResource(R.drawable.dot_selected);
            dot1.setImageResource(R.drawable.dot);
            dot2.setImageResource(R.drawable.dot);
        }
        else if (position == 1) {
            dot0.setImageResource(R.drawable.dot);
            dot1.setImageResource(R.drawable.dot_selected);
            dot2.setImageResource(R.drawable.dot);
        }
        else if (position == 2) {
            dot0.setImageResource(R.drawable.dot);
            dot1.setImageResource(R.drawable.dot);
            dot2.setImageResource(R.drawable.dot_selected);
            acceptButton.setBackgroundResource(R.drawable.button_rounded_orange);
            acceptButton.setClickable(true);
        }
    }

    @Override
    public void onPageScrollStateChanged(int state) {
    }
}
