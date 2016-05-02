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
import android.widget.RelativeLayout;
import android.widget.ScrollView;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.views.adapters.HogBugExpandListAdapter;

/**
 * Created by Valto on 30.9.2015.
 */
public class HogsFragment extends Fragment {

    private MainActivity mainActivity;
    private LinearLayout mainFrame;
    private RelativeLayout hogsHeader;
    private ScrollView noHogsLayout;
    private ExpandableListView expandableListView;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.mainActivity = (MainActivity) activity;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        mainFrame = (LinearLayout) inflater.inflate(R.layout.fragment_hogs, container, false);
        LinearLayout footer = (LinearLayout)mainFrame.findViewById(R.id.footer_button);
        footer.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                HogStatsFragment hogStats = new HogStatsFragment();
                mainActivity.replaceFragment(hogStats, Constants.FRAGMENG_HOG_STATS_TAG);
            }
        });
        return mainFrame;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
    }

    @Override
    public void onResume() {
        super.onResume();
        mainActivity.setUpActionBar(R.string.hogs, true);
        initViewRefs();
        refresh();
    }

    private void initViewRefs() {
        noHogsLayout = (ScrollView) mainFrame.findViewById(R.id.empty_hogs_layout);
        hogsHeader = (RelativeLayout) mainFrame.findViewById(R.id.hogs_header);
        expandableListView = (ExpandableListView) mainFrame.findViewById(R.id.expandable_hogs_list);
    }

    private void refresh() {
        if (getActivity() == null)
            Log.e("BugsOrHogsFragment", "unable to get activity");
        CaratApplication app = (CaratApplication) getActivity().getApplication();
        if (CaratApplication.getStorage().hogsIsEmpty()) {
            noHogsLayout.setVisibility(View.VISIBLE);
            hogsHeader.setVisibility(View.GONE);
            expandableListView.setVisibility(View.GONE);
            return;
        } else {
            noHogsLayout.setVisibility(View.GONE);
            hogsHeader.setVisibility(View.VISIBLE);
            expandableListView.setVisibility(View.VISIBLE);
            expandableListView.setAdapter(new HogBugExpandListAdapter((MainActivity)getActivity(),
                    expandableListView, app, CaratApplication.getStorage().getHogReport()));
        }

    }

}