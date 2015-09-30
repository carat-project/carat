package edu.berkeley.cs.amplab.carat.android.fragments;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.activities.DashboardActivity;

/**
 * Created by Valto on 30.9.2015.
 */
public class GlobalFragment extends Fragment {

    private DashboardActivity dashboardActivity;
    private LinearLayout ll;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.dashboardActivity = (DashboardActivity) activity;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        ll = (LinearLayout) inflater.inflate(R.layout.fragment_global, container, false);
        return ll;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

    }

}
