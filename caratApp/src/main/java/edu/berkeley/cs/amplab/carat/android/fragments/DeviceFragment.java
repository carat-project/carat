package edu.berkeley.cs.amplab.carat.android.fragments;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.activities.DashboardActivity;
import edu.berkeley.cs.amplab.carat.android.ui.CircleDisplay;

/**
 * Created by Valto on 30.9.2015.
 */
public class DeviceFragment extends Fragment {

    private DashboardActivity dashboardActivity;
    private RelativeLayout mainFrame;
    private CircleDisplay cd;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.dashboardActivity = (DashboardActivity) activity;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        mainFrame = (RelativeLayout) inflater.inflate(R.layout.fragment_device, container, false);
        return mainFrame;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

    }

    @Override
    public void onResume() {
        super.onResume();
        generateJScoreCircle();
        setValues();
    }

    private void generateJScoreCircle() {
        cd = (CircleDisplay) mainFrame.findViewById(R.id.jscore_progress_circle);
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
    }

}
