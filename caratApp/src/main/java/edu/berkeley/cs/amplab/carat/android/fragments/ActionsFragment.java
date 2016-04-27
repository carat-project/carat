package edu.berkeley.cs.amplab.carat.android.fragments;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ExpandableListView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.android.storage.CaratDataStorage;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;
import edu.berkeley.cs.amplab.carat.android.views.adapters.ActionsExpandListAdapter;

/**
 * Created by Valto on 30.9.2015.
 */


public class ActionsFragment extends Fragment implements Serializable {
    private static final long serialVersionUID = -6034269327947014085L;

    private MainActivity mainActivity;
    private LinearLayout mainFrame;
    private LinearLayout noActionsLayout;
    private RelativeLayout actionsHeader;
    private ScrollView noActionsScroll;
    private ExpandableListView expandableListView;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.mainActivity = (MainActivity) activity;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        mainFrame = (LinearLayout) inflater.inflate(R.layout.fragment_actions, container, false);
        return mainFrame;

    }

    @Override
    public void onResume() {
        super.onResume();
        mainActivity.setUpActionBar(R.string.actions, true);
        initViewRefs();
        refresh();
    }

    private void initViewRefs() {
        noActionsScroll = (ScrollView) mainFrame.findViewById(R.id.no_actions_scroll_view);
        noActionsLayout = (LinearLayout) mainFrame.findViewById(R.id.empty_actions_layout);
        actionsHeader = (RelativeLayout) mainFrame.findViewById(R.id.actions_header);
        expandableListView = (ExpandableListView) mainFrame.findViewById(R.id.expandable_actions_list);
    }

    public void refresh() {
        SimpleHogBug[] hogReport, bugReport;
        CaratDataStorage s = CaratApplication.getStorage();

        hogReport = s.getHogReport();
        bugReport = s.getBugReport();

        ArrayList<SimpleHogBug> running = new ArrayList<>();
        running.addAll(filterByRunning(hogReport));
        running.addAll(filterByRunning(bugReport));

        // Populate actions list with running applications
        if (!s.hogsIsEmpty() || !s.bugsIsEmpty() || !CaratApplication.getStaticActions().isEmpty()) {
            noActionsScroll.setVisibility(View.GONE);
            noActionsLayout.setVisibility(View.GONE);
            actionsHeader.setVisibility(View.VISIBLE);
            expandableListView.setVisibility(View.VISIBLE);
            expandableListView.setAdapter(new ActionsExpandListAdapter(mainActivity,
                    expandableListView, (CaratApplication) getActivity().getApplication(),
                    running, mainActivity));
        } else {
            // Show a separate information screen when there are no actions
            noActionsScroll.setVisibility(View.VISIBLE);
            noActionsLayout.setVisibility(View.VISIBLE);
            actionsHeader.setVisibility(View.GONE);
            expandableListView.setVisibility(View.GONE);
        }
    }

    private ArrayList<SimpleHogBug> filterByRunning(SimpleHogBug[] report){
        HashMap<String, SimpleHogBug> running = new HashMap<>();
        if(report == null) return new ArrayList<>();
        for(SimpleHogBug s : report){
            if(SamplingLibrary.isRunning(mainActivity, s.getAppName())){
                SimpleHogBug duplicate = running.get(s.getAppName());
                if(duplicate != null
                        && s.getAppPriority() == duplicate.getAppPriority()
                        && s.getBenefit() == duplicate.getBenefit()){
                    continue;
                }

                // Enable this when we can reliably detect killable apps
                // if(CaratApplication.isPackageSystemApp(s.getAppName())){
                //   continue;
                // }
                running.put(s.getAppName(), s);
            }
        }
        return new ArrayList<>(running.values());
    }


    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
    }
}

