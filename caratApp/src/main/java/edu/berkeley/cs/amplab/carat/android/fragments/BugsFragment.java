package edu.berkeley.cs.amplab.carat.android.fragments;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ExpandableListView;
import android.widget.LinearLayout;
import android.widget.ListView;

import java.util.HashMap;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.activities.DashboardActivity;
import edu.berkeley.cs.amplab.carat.android.lists.HogsBugsAdapter;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;
import edu.berkeley.cs.amplab.carat.android.ui.adapters.ExpandListAdapter;

/**
 * Created by Valto on 30.9.2015.
 */
public class BugsFragment extends Fragment {

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
        ll = (LinearLayout) inflater.inflate(R.layout.fragment_bugs, container, false);
        return ll;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        dashboardActivity.setUpActionBar(R.string.bugs, getFragmentManager().getBackStackEntryCount() > 0);
    }

    @Override
    public void onResume() {
        super.onResume();
        refresh();
    }

    public void refresh() {
        if (getActivity() == null)
            Log.e("BugsOrHogsFragment", "unable to get activity");
        CaratApplication app = (CaratApplication) getActivity().getApplication();
        final ExpandableListView lv = (ExpandableListView) ll.findViewById(R.id.expandable_bugs_list);
        if (CaratApplication.getStorage().bugsIsEmpty()) {
            return;
        } else {
            lv.setAdapter(new ExpandListAdapter(lv, app, CaratApplication.getStorage().getBugReport()));
        }

    }

}
