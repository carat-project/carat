package edu.berkeley.cs.amplab.carat.android.fragments;


import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import org.w3c.dom.Text;

import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.activities.DashboardActivity;
import edu.berkeley.cs.amplab.carat.android.ui.CircleDisplay;

/**
 * Created by Valto on 30.9.2015.
 */
public class DashboardFragment extends Fragment implements View.OnClickListener {

    private DashboardActivity dashboardActivity;
    private RelativeLayout ll;
    private RelativeLayout shareBar;
    private ImageView bugButton;
    private ImageView hogButton;
    private ImageView globeButton;
    private ImageView actionsButton;
    private Button myDeviceButton;
    private ImageView shareButton;
    private ImageView facebookButton;
    private ImageView twitterButton;
    private ImageView emailButton;
    private ImageView closeButton;
    private TextView bugAmountText;
    private TextView hogAmountText;
    private TextView actionsAmountText;
    private TextView batteryText;
    private TextView updatedText;
    private CircleDisplay cd;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.dashboardActivity = (DashboardActivity) activity;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        ll = (RelativeLayout) inflater.inflate(R.layout.fragment_dashboard, container, false);
        return ll;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        dashboardActivity.setUpActionBar(R.string.title_activity_dashboard, getFragmentManager().getBackStackEntryCount() > 0);

    }

    @Override
    public void onResume() {
        super.onResume();
        initViewRefs();
        initListeners();
        generateJScoreCircle();
        shareButton.setVisibility(View.VISIBLE);
        shareBar.setVisibility(View.GONE);
        setValues();
    }

    private void initViewRefs() {
        shareBar = (RelativeLayout) ll.findViewById(R.id.share_bar);
        shareBar.setVisibility(View.GONE);
        bugButton = (ImageView) ll.findViewById(R.id.bugs_button);
        hogButton = (ImageView) ll.findViewById(R.id.hogs_button);
        globeButton = (ImageView) ll.findViewById(R.id.globe_button);
        actionsButton = (ImageView) ll.findViewById(R.id.actions_button);
        myDeviceButton = (Button) ll.findViewById(R.id.my_device_button);
        shareButton = (ImageView) ll.findViewById(R.id.share_button);
        batteryText = (TextView) ll.findViewById(R.id.battery_value);
        bugAmountText = (TextView) ll.findViewById(R.id.bugs_amount);
        hogAmountText = (TextView) ll.findViewById(R.id.hogs_amount);
        actionsAmountText = (TextView) ll.findViewById(R.id.actions_amount);
        updatedText = (TextView) ll.findViewById(R.id.updated_text);
        facebookButton = (ImageView) ll.findViewById(R.id.facebook_icon);
        twitterButton = (ImageView) ll.findViewById(R.id.twitter_icon);
        emailButton = (ImageView) ll.findViewById(R.id.email_icon);
        closeButton = (ImageView) ll.findViewById(R.id.hide_button);

    }

    private void initListeners() {
        bugButton.setOnClickListener(this);
        hogButton.setOnClickListener(this);
        globeButton.setOnClickListener(this);
        actionsButton.setOnClickListener(this);
        myDeviceButton.setOnClickListener(this);
        shareButton.setOnClickListener(this);
        facebookButton.setOnClickListener(this);
        twitterButton.setOnClickListener(this);
        emailButton.setOnClickListener(this);
        closeButton.setOnClickListener(this);
    }

    private void generateJScoreCircle() {
        cd = (CircleDisplay) ll.findViewById(R.id.jscore_progress_circle);
        cd.setValueWidthPercent(10f);
        cd.setTextSize(40f);
        cd.setColor(Color.argb(255, 247, 167, 27));
        cd.setDrawText(true);
        cd.setDrawInnerCircle(true);
        cd.setFormatDigits(0);
        cd.setTouchEnabled(true);
        cd.setUnit("");
        cd.setStepSize(1f);
    }

    private void setValues() {
        if (dashboardActivity.getJScore() == -1 || dashboardActivity.getJScore() == 0) {
            cd.setCustomText(new String[]{"N/A"});
        } else {
            cd.showValue((float) dashboardActivity.getJScore(), 99f, false);
        }
        batteryText.setText(dashboardActivity.getBatteryLife());
        bugAmountText.setText(dashboardActivity.getBugAmount());
        hogAmountText.setText(dashboardActivity.getHogAmount());
        actionsAmountText.setText(dashboardActivity.getActionsAmount());
        updatedText.setText(dashboardActivity.getLastUpdated());
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.bugs_button:
                BugsFragment bugsFragment = new BugsFragment();
                dashboardActivity.replaceFragment(bugsFragment, Constants.FRAGMENT_BUGS_TAG);
                break;
            case R.id.hogs_button:
                HogsFragment hogsFragment = new HogsFragment();
                dashboardActivity.replaceFragment(hogsFragment, Constants.FRAGMENT_HOGS_TAG);
                break;
            case R.id.globe_button:
                GlobalFragment globalFragment = new GlobalFragment();
                dashboardActivity.replaceFragment(globalFragment, Constants.FRAGMENT_GLOBAL_TAG);
                break;
            case R.id.actions_button:
                ActionsFragment actionsFragment = new ActionsFragment();
                dashboardActivity.replaceFragment(actionsFragment, Constants.FRAGMENT_ACTIONS_TAG);
                break;
            case R.id.my_device_button:
                MyDeviceFragment myDeviceFragment = new MyDeviceFragment();
                dashboardActivity.replaceFragment(myDeviceFragment, Constants.FRAGMENT_MY_DEVICE_TAG);
                break;
            case R.id.share_button:
                shareButton.setVisibility(View.GONE);
                shareBar.setVisibility(View.VISIBLE);
                break;
            case R.id.hide_button:
                shareButton.setVisibility(View.VISIBLE);
                shareBar.setVisibility(View.GONE);
                break;
            case R.id.facebook_icon:
                dashboardActivity.shareOnFacebook();
                break;
            case R.id.twitter_icon:
                dashboardActivity.shareOnTwitter();
                break;
            case R.id.email_icon:
                dashboardActivity.shareViaEmail();
                break;
            default:
                break;
        }
    }
}
