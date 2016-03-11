package edu.berkeley.cs.amplab.carat.android.activities;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.preference.PreferenceManager;
import android.support.v4.app.Fragment;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import java.util.List;
import java.util.Vector;

import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.fragments.tutorial.BugsTutorialFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.tutorial.EulaTutorialFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.tutorial.HogsTutorialFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.tutorial.MainTutorialFragment;
import edu.berkeley.cs.amplab.carat.android.views.adapters.TutorialPagerAdapter;

public class TutorialActivity extends ActionBarActivity implements View.OnClickListener, ViewPager.OnPageChangeListener {

    private PagerAdapter adapterViewPager;
    private ViewPager vPager;
    private Button acceptButton;
    private TextView eulaLink;
    private WebView eulaView;
    private RelativeLayout mainLayout;
    private ImageView dot0, dot1, dot2, dot3;
    private boolean eulaViewVisivibility;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().setStatusBarColor(getResources().getColor(R.color.statusbar_color));
        }

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_tutorial);
        eulaViewVisivibility = false;
        initViewRefs();
        initialisePaging();
    }

    @Override
    public void onBackPressed() {
        if (eulaViewVisivibility) {
            eulaViewVisivibility = false;
            mainLayout.setVisibility(View.VISIBLE);
            eulaView.setVisibility(View.GONE);
            return;
        }
        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.addCategory(Intent.CATEGORY_HOME);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
        finish();
        System.exit(0);
    }

    private void initViewRefs() {

        mainLayout = (RelativeLayout) findViewById(R.id.main_layout);

        dot0 = (ImageView) findViewById(R.id.page_indicator_0);
        dot1 = (ImageView) findViewById(R.id.page_indicator_1);
        dot2 = (ImageView) findViewById(R.id.page_indicator_2);
        dot3 = (ImageView) findViewById(R.id.page_indicator_3);

        eulaLink = (TextView) findViewById(R.id.eula_link);
        eulaLink.setOnClickListener(this);

        eulaView = (WebView) findViewById(R.id.eula_view);

        acceptButton = (Button) findViewById(R.id.tutorial_accept_button);
        acceptButton.setOnClickListener(this);
        //acceptButton.setClickable(false);
    }

    private void initialisePaging() {
        vPager = (ViewPager) findViewById(R.id.tutorial_view_pager);
        List<Fragment> fragments = new Vector<Fragment>();
        fragments.add(Fragment.instantiate(this, MainTutorialFragment.class.getName()));
        fragments.add(Fragment.instantiate(this, BugsTutorialFragment.class.getName()));
        fragments.add(Fragment.instantiate(this, HogsTutorialFragment.class.getName()));
        fragments.add(Fragment.instantiate(this, EulaTutorialFragment.class.getName()));
        this.adapterViewPager = new TutorialPagerAdapter(super.getSupportFragmentManager(), fragments);
        vPager.setAdapter(adapterViewPager);
        vPager.setOnPageChangeListener(this);
        vPager.setCurrentItem(0);

    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.tutorial_accept_button){
            if (this.vPager.getCurrentItem() < 3){
                this.vPager.setCurrentItem(this.vPager.getCurrentItem()+1, true);
            }else {
                Intent returnIntent = new Intent();
                setResult(RESULT_OK, returnIntent);
                SharedPreferences p = PreferenceManager.getDefaultSharedPreferences(this);
                p.edit().putBoolean(getString(R.string.save_accept_eula), true).commit();
                finish();
            }
        }
        if (v.getId() == R.id.eula_link  || v.getId() == R.id.eula_message_link) {
            eulaViewVisivibility = true;
            eulaView.getSettings().setJavaScriptEnabled(true);
            eulaView.loadUrl("file:///android_asset/consent.html");
            mainLayout.setVisibility(View.GONE);
            eulaView.setVisibility(View.VISIBLE);
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
            dot3.setImageResource(R.drawable.dot);
        } else if (position == 1) {
            dot0.setImageResource(R.drawable.dot);
            dot1.setImageResource(R.drawable.dot_selected);
            dot2.setImageResource(R.drawable.dot);
            dot3.setImageResource(R.drawable.dot);
        } else if (position == 2) {
            dot0.setImageResource(R.drawable.dot);
            dot1.setImageResource(R.drawable.dot);
            dot2.setImageResource(R.drawable.dot_selected);
            dot3.setImageResource(R.drawable.dot);
        } else if (position == 3) {
            dot0.setImageResource(R.drawable.dot);
            dot1.setImageResource(R.drawable.dot);
            dot2.setImageResource(R.drawable.dot);
            dot3.setImageResource(R.drawable.dot_selected);
            acceptButton.setBackgroundResource(R.drawable.button_rounded_orange);
        }
    }

    @Override
    public void onPageScrollStateChanged(int state) {
    }
}
