package edu.berkeley.cs.amplab.carat.android.fragments;


import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.dialogs.BaseDialog;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;
import edu.berkeley.cs.amplab.carat.android.views.CircleDisplay;

/**
 * Created by Valto on 30.9.2015.
 */
public class DashboardFragment extends Fragment implements View.OnClickListener {

    private MainActivity mainActivity;
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
        this.mainActivity = (MainActivity) activity;
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
    }

    @Override
    public void onResume() {
        super.onResume();
        mainActivity.setUpActionBar(R.string.title_activity_dashboard, false);
        initViewRefs();
        initListeners();
        generateJScoreCircle();
        setValues();
        shareButton.setVisibility(View.VISIBLE);
        shareBar.setVisibility(View.GONE);
        scheduleRefresh();
    }

    private void initViewRefs() {
        cd = (CircleDisplay) ll.findViewById(R.id.jscore_progress_circle);
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
            cd.showValue((float) mainActivity.getJScore(), 99f, false);
        }
        batteryText.setText(CaratApplication.myDeviceData.getBatteryLife());
        bugAmountText.setText(mainActivity.getBugAmount());
        hogAmountText.setText(mainActivity.getHogAmount());
        actionsAmountText.setText(mainActivity.getActionsAmount());
        updatedText.setText(mainActivity.getLastUpdated());
    }

    public void setUpdatingValue(String what) {
        updatedText.setText(getString(R.string.updating) + " " + what);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.jscore_progress_circle:
                BaseDialog dialog = new BaseDialog(getContext(),
                        getString(R.string.jscore_dialog_title),
                        getString(R.string.jscore_explanation));
                dialog.showDialog();
                break;
            case R.id.bugs_button:
                BugsFragment bugsFragment = new BugsFragment();
                mainActivity.replaceFragment(bugsFragment, Constants.FRAGMENT_BUGS_TAG);
                break;
            case R.id.hogs_button:
                HogsFragment hogsFragment = new HogsFragment();
                mainActivity.replaceFragment(hogsFragment, Constants.FRAGMENT_HOGS_TAG);
                break;
            case R.id.globe_button:
                GlobalFragment globalFragment = new GlobalFragment();
                mainActivity.replaceFragment(globalFragment, Constants.FRAGMENT_GLOBAL_TAG);
                break;
            case R.id.actions_button:
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

    public void scheduleRefresh() {
        Log.d("debug", "*** SCHELUDE START");
        if (mainActivity != null)
            mainActivity.runOnUiThread(new Runnable() {
                public void run() {
                    View v = getView();
                    if (v != null) {
                        Log.d("debug", "*** battery");
                        String batteryLife = CaratApplication.myDeviceData.getBatteryLife();
                        mainActivity.setBatteryLife(batteryLife);
                        batteryText.setText(batteryLife);

                    }

                    int hogsCount = 0;
                    int bugsCount = 0;
                    if (CaratApplication.getStorage() != null && v != null) {
                        SimpleHogBug[] h = CaratApplication.getStorage().getHogReport();
                        SimpleHogBug[] b = CaratApplication.getStorage().getBugReport();
                        if (h != null) {
                            hogsCount = h.length;
                            Log.d("debug", "*** hogsCount: " + h.length);
                        }
                        if (b != null) {
                            bugsCount = b.length;
                            Log.d("debug", "*** bugsCount: " + b.length);
                        }
                        hogAmountText.setText(String.valueOf(hogsCount));
                        bugAmountText.setText(String.valueOf(bugsCount));
                        actionsAmountText.setText(String.valueOf(hogsCount + bugsCount));
                        mainActivity.setBugAmount(String.valueOf(bugsCount));
                        mainActivity.setHogAmount(String.valueOf(hogsCount));
                        mainActivity.setActionsAmount(bugsCount + hogsCount);
                    }
                }
            });
        mainActivity.setJScore(CaratApplication.getJscore());
        mainActivity.setCpuValue();
        setValues();
        Log.d("debug", "*** SCHELUDE END");
    }
}
