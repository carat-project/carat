package edu.berkeley.cs.amplab.carat.android.fragments;

import android.app.Activity;
import android.bluetooth.le.ScanRecord;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ExpandableListView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.views.adapters.HogBugExpandListAdapter;

/**
 * Created by Valto on 30.9.2015.
 */
public class BugsFragment extends Fragment {

    private MainActivity mainActivity;
    private LinearLayout mainFrame;
    private ScrollView noBugsLayout;
    private RelativeLayout bugsHeader;
    private ExpandableListView expandableListView;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.mainActivity = (MainActivity) activity;

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        mainFrame = (LinearLayout) inflater.inflate(R.layout.fragment_bugs, container, false);
        return mainFrame;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
    }

    @Override
    public void onResume() {
        super.onResume();
        mainActivity.setUpActionBar(R.string.bugs, true);
        initViewRefs();
        refresh();
    }

    private void initViewRefs() {
        noBugsLayout = (ScrollView) mainFrame.findViewById(R.id.empty_bugs_layout);
        bugsHeader = (RelativeLayout) mainFrame.findViewById(R.id.bugs_header);
        expandableListView = (ExpandableListView) mainFrame.findViewById(R.id.expandable_bugs_list);
    }

    private void refresh() {
        if (getActivity() == null)
            Log.e("BugsOrHogsFragment", "unable to get activity");
        CaratApplication app = (CaratApplication) getActivity().getApplication();
        if (CaratApplication.getStorage().bugsIsEmpty()) {
            noBugsLayout.setVisibility(View.VISIBLE);
            bugsHeader.setVisibility(View.GONE);
            expandableListView.setVisibility(View.GONE);
            return;
        } else {
            noBugsLayout.setVisibility(View.GONE);
            bugsHeader.setVisibility(View.VISIBLE);
            expandableListView.setVisibility(View.VISIBLE);
            expandableListView.setAdapter(new HogBugExpandListAdapter((MainActivity)getActivity(),
                    expandableListView, app, CaratApplication.getStorage().getBugReport()));
        }

    }

}
