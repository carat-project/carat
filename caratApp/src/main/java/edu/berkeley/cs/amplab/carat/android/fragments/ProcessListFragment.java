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

import java.util.List;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.android.views.adapters.ProcessExpandListAdapter;
import edu.berkeley.cs.amplab.carat.thrift.ProcessInfo;

/**
 * Created by Valto on 7.10.2015.
 */
public class ProcessListFragment extends Fragment {
    private MainActivity mainActivity;
    private LinearLayout mainFrame;
    private RelativeLayout processHeader;
    private ExpandableListView expandableListView;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.mainActivity = (MainActivity) activity;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        mainFrame = (LinearLayout) inflater.inflate(R.layout.fragment_process_list, container, false);
        return mainFrame;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
    }

    @Override
    public void onResume() {
        super.onResume();
        mainActivity.setUpActionBar(R.string.process_list_title, true);
        initViewRefs();
        refresh();
    }

    private void initViewRefs() {
        processHeader = (RelativeLayout) mainFrame.findViewById(R.id.process_header);
        expandableListView = (ExpandableListView) mainFrame.findViewById(R.id.expandable_process_list);
    }

    private void refresh() {
        CaratApplication app = (CaratApplication) getActivity().getApplication();
        SamplingLibrary.resetRunningProcessInfo();
        List<ProcessInfo> searchResults = SamplingLibrary
                .getRunningAppInfo(getActivity());
        expandableListView.setAdapter(new ProcessExpandListAdapter((MainActivity) getActivity(),
                expandableListView, app, searchResults));
    }

}
