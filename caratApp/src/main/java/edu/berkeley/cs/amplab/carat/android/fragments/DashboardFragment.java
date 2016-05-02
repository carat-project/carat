package edu.berkeley.cs.amplab.carat.android.fragments;


import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.dialogs.BaseDialog;
import edu.berkeley.cs.amplab.carat.android.protocol.CommunicationManager;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;
import edu.berkeley.cs.amplab.carat.android.views.CircleDisplay;

/**
 * Created by Valto on 30.9.2015.
 */
public class DashboardFragment extends Fragment implements View.OnClickListener {

    private CaratApplication application;
    private MainActivity mainActivity;
    private RelativeLayout ll;
    private RelativeLayout shareBar;
    private LinearLayout bugButton;
    private LinearLayout hogButton;
    private LinearLayout globeButton;
    private LinearLayout actionsButton;
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
    private Thread reportsThread;

    private boolean schedulerRunning;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.mainActivity = (MainActivity) activity;
        this.application = (CaratApplication) mainActivity.getApplication();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        schedulerRunning = false;
        ll = (RelativeLayout) inflater.inflate(R.layout.fragment_dashboard, container, false);
        return ll;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
    }

    @Override
    public void onResume() {
        super.onResume();
        CaratApplication.refreshStaticActionCount();
        mainActivity.setUpActionBar(R.string.title_activity_dashboard, false);
        initViewRefs();
        initListeners();
        generateJScoreCircle();
        setValues();
        shareButton.setVisibility(View.VISIBLE);
        shareBar.setVisibility(View.GONE);
        // Keep refreshing view
        if(!schedulerRunning){
            scheduleRefresh();
        } else {
            refresh();
        }
    }

    private void initViewRefs() {
        cd = (CircleDisplay) ll.findViewById(R.id.jscore_progress_circle);
        shareBar = (RelativeLayout) ll.findViewById(R.id.share_bar);
        shareBar.setVisibility(View.GONE);
        bugButton = (LinearLayout) ll.findViewById(R.id.bugs_layout);
        hogButton = (LinearLayout) ll.findViewById(R.id.hogs_layout);
        globeButton = (LinearLayout) ll.findViewById(R.id.globe_layout);
        actionsButton = (LinearLayout) ll.findViewById(R.id.actions_layout);
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
        cd.setOnClickListener(this);
    }

    private void generateJScoreCircle() {
        cd.setValueWidthPercent(10f);
        cd.setTextSize(40f);
        cd.setColor(Color.argb(255, 247, 167, 27));
        cd.setDrawText(true);
        cd.setDrawInnerCircle(true);
        cd.setFormatDigits(0);
        cd.setTouchEnabled(false);
        cd.setUnit("");
        cd.setStepSize(1f);
    }

    public void setValues() {
        if (mainActivity.getJScore() == -1 || mainActivity.getJScore() == 0) {
            cd.setCustomText(new String[]{"N/A"});
        } else {
            cd.setCustomText(null);
            cd.showValue((float) mainActivity.getJScore(), 99f, false);
        }
        batteryText.setText(CaratApplication.myDeviceData.getBatteryLife());
        bugAmountText.setText(mainActivity.getBugAmount());
        hogAmountText.setText(mainActivity.getHogAmount());
        actionsAmountText.setText(mainActivity.getActionsAmount());
    }

    // Allows status string to be changed when updating
    public void setUpdatingValue(String what) {
        if (isAdded()) {
            updatedText.setText(getString(R.string.updating) + " " + what);
        }
    }

    public void setSampleProgress(String what) {
        if(isAdded()){
            updatedText.setText(what);
        }
    }

    // Refresh status string and progress indicator
    public void refreshProgress() {
        // Make sure we don't overwrite an updating status
        if(application.isSendingSamples()) {
            mainActivity.setProgressCircle(true);
            setUpdatingValue(mainActivity.getSampleValue());
        } else if(application.isUpdatingReports()) {
            mainActivity.setProgressCircle(true);
            setUpdatingValue(mainActivity.getUpdatingValue());
        } else {
            mainActivity.setProgressCircle(false);
            updatedText.setText(mainActivity.getLastUpdated());
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.jscore_progress_circle:
                BaseDialog dialog = new BaseDialog(getContext(),
                        getString(R.string.jscore_dialog_title),
                        getString(R.string.jscore_explanation),
                        "jscoreinfo");
                dialog.showDialog();
                break;
            case R.id.bugs_layout:
                BugsFragment bugsFragment = new BugsFragment();
                mainActivity.replaceFragment(bugsFragment, Constants.FRAGMENT_BUGS_TAG);
                break;
            case R.id.hogs_layout:
                HogsFragment hogsFragment = new HogsFragment();
                mainActivity.replaceFragment(hogsFragment, Constants.FRAGMENT_HOGS_TAG);
                break;
            case R.id.globe_layout:
                GlobalFragment globalFragment = new GlobalFragment();
                mainActivity.replaceFragment(globalFragment, Constants.FRAGMENT_GLOBAL_TAG);
                break;
            case R.id.actions_layout:
                ActionsFragment actionsFragment = new ActionsFragment();
                mainActivity.replaceFragment(actionsFragment, Constants.FRAGMENT_ACTIONS_TAG);
                break;
            case R.id.my_device_button:

                DeviceFragment myDeviceFragment = new DeviceFragment();
                mainActivity.replaceFragment(myDeviceFragment, Constants.FRAGMENT_MY_DEVICE_TAG);
                break;
            case R.id.share_button:
                shareButton.setVisibility(View.GONE);
                shareBar.setVisibility(View.VISIBLE);
                break;
            case R.id.hide_button:
                shareBar.setVisibility(View.GONE);
                shareButton.setVisibility(View.VISIBLE);
                break;
            case R.id.facebook_icon:
                mainActivity.shareOnFacebook();
                break;
            case R.id.twitter_icon:
                mainActivity.shareOnTwitter();
                break;
            case R.id.email_icon:
                mainActivity.shareViaEmail();
                break;
            default:
                break;
        }
    }

    // Schedules a dashboard refresh timer
    public void scheduleRefresh() {
        // Allow only one timer at a time
        if(schedulerRunning) {
            refresh();
            return;
        }

        checkReportsAndRefresh(); // Fire immediately

        // Set offset so the initial minute won't take so long
        final long interval = Constants.DASHBOARD_REFRESH_INTERVAL;
        long freshness = CaratApplication.getStorage().getFreshness();
        long elapsed = System.currentTimeMillis() - freshness;
        long offset = (elapsed % interval)-1;
        if(offset < 0) offset = 0;

        // Use handler so it gets destroyed with the fragment
        final Handler timer = new Handler();
        timer.postDelayed(new Runnable(){
            @Override
            public void run(){
                checkReportsAndRefresh();
                timer.postDelayed(this, interval);
            }
        }, interval-offset);
        schedulerRunning = true;
    }

    // Refreshes most of the view
    public void refresh() {
        mainActivity.runOnUiThread(new Runnable() {
            public void run() {
                // Prioritize status text
                refreshProgress();
                View v = getView();
                if (v != null) {
                    String batteryLife = CaratApplication.myDeviceData.getBatteryLife();
                    mainActivity.setBatteryLife(batteryLife);
                    batteryText.setText(batteryLife);
                }

                int actionsAmount = 0;
                int hogsCount = 0;
                int bugsCount = 0;
                if (CaratApplication.getStorage() != null && v != null) {
                    SimpleHogBug[] h = CaratApplication.getStorage().getHogReport();
                    SimpleHogBug[] b = CaratApplication.getStorage().getBugReport();
                    if (h != null) {
                        hogsCount = CaratApplication.filterByVisibility(h).size();
                        actionsAmount += CaratApplication.filterByRunning(h).size();
                    }
                    if (b != null) {
                        bugsCount = CaratApplication.filterByVisibility(b).size();
                        actionsAmount += CaratApplication.filterByRunning(b).size();
                    }

                    // Subtract the 'help carat collect data' from action count if needed.
                    CaratApplication.refreshStaticActionCount();
                    int staticActionsAmount = mainActivity.getStaticActionsAmount();

                    hogAmountText.setText(String.valueOf(hogsCount));
                    bugAmountText.setText(String.valueOf(bugsCount));
                    actionsAmountText.setText(String.valueOf(actionsAmount+staticActionsAmount));
                    mainActivity.setBugAmount(String.valueOf(bugsCount));
                    mainActivity.setHogAmount(String.valueOf(hogsCount));
                    mainActivity.setActionsAmount(actionsAmount+staticActionsAmount);
                }
                mainActivity.setJScore(CaratApplication.getJscore());
                mainActivity.setCpuValue();
                setValues();
            }
        });

    }

    // Check if we should update and refresh afterwards
    public void checkReportsAndRefresh() {
        if(application == null) return;

        // Download new reports in separate networking thread
        // Ignore if already updating
        if(reportsThread != null && reportsThread.isAlive()) return;
        reportsThread = new Thread(new Runnable() {
            @Override
            public void run(){
                application.refreshUi();
            }
        });
        reportsThread.start();
    }
}
