package edu.berkeley.cs.amplab.carat.android.fragments;

import android.app.Activity;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.SearchView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ExpandableListView;
import android.widget.LinearLayout;

import java.util.List;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.protocol.AsyncStats;
import edu.berkeley.cs.amplab.carat.android.storage.CaratDataStorage;
import edu.berkeley.cs.amplab.carat.android.storage.HogStats;
import edu.berkeley.cs.amplab.carat.android.views.adapters.HogStatsExpandAdapter;

/**
 * Created by Jonatan Hamberg on 2.5.2016.
 */
public class HogStatsFragment extends Fragment{
    private MainActivity mainActivity;
    private LinearLayout mainFrame;
    private ExpandableListView expandableListView;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.mainActivity = (MainActivity) activity;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        AsyncStats fetchHogStats = new AsyncStats(getMainActivity());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
            fetchHogStats.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
        else
            fetchHogStats.execute();
        super.onCreateView(inflater, container, savedInstanceState);
        mainFrame = (LinearLayout) inflater.inflate(R.layout.fragment_hog_stats, container, false);
        SearchView search = (SearchView)mainFrame.findViewById(R.id.hog_statistics_search);
        search.setIconifiedByDefault(false);
        return mainFrame;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
    }

    @Override
    public void onResume() {
        super.onResume();
        mainActivity.setUpActionBar(R.string.global_hogs, true);
        initViewRefs();
        refresh();
    }

    public MainActivity getMainActivity(){
        if(mainActivity == null){
            mainActivity = (MainActivity)getActivity();
        }
        return mainActivity;
    }

    public void initViewRefs(){
        if(expandableListView == null){
            expandableListView = (ExpandableListView) mainFrame.findViewById(R.id.expandable_hog_stats);
        }
    }

    public void refresh(){
        CaratDataStorage storage = CaratApplication.getStorage();
        List<HogStats> hogStats = storage.getHogStats();
        expandableListView.setVisibility(View.VISIBLE);
        HogStatsExpandAdapter adapter = new HogStatsExpandAdapter(getMainActivity(), expandableListView, hogStats);
        expandableListView.setAdapter(adapter);
    }
}
