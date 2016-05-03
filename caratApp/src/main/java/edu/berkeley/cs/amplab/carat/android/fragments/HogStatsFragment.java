package edu.berkeley.cs.amplab.carat.android.fragments;

import android.app.Activity;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.SearchView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import java.util.Collections;
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
    private RelativeLayout loadingScreen;
    private SearchView search;
    private ExpandableListView expandableListView;
    private HogStatsExpandAdapter adapter;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.mainActivity = (MainActivity) activity;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        mainFrame = (LinearLayout) inflater.inflate(R.layout.fragment_hog_stats, container, false);
        search = (SearchView)mainFrame.findViewById(R.id.hog_statistics_search);
        loadingScreen = (RelativeLayout) mainFrame.findViewById(R.id.loading_screen);
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
        expandableListView.setVisibility(View.VISIBLE);

        if(expandableListView.getAdapter() == null){
            updateHogStatsAsynchronously();
            HogStatsExpandAdapter adapter = setupAdapter();
            expandableListView.setAdapter(adapter);
            setupListeners(adapter);
        }
    }

    public void refresh(){
        if(adapter != null){
            CaratDataStorage storage = CaratApplication.getStorage();
            List<HogStats> hogStats = storage.getHogStats();
            if(hogStats != null && !hogStats.isEmpty()){
                adapter.refresh(hogStats);
                loadingScreen.setVisibility(View.GONE);
            }
        }
    }

    public MainActivity getMainActivity(){
        if(mainActivity == null){
            mainActivity = (MainActivity)getActivity();
        } return mainActivity;
    }

    public void initViewRefs(){
        if(expandableListView == null){
            expandableListView = (ExpandableListView) mainFrame.findViewById(R.id.expandable_hog_stats);
        }
    }

    public void updateHogStatsAsynchronously(){
        AsyncStats fetchHogStats = new AsyncStats(getMainActivity());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB){
            fetchHogStats.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
        } else fetchHogStats.execute();
    }

    public HogStatsExpandAdapter setupAdapter(){
        CaratDataStorage storage = CaratApplication.getStorage();
        List<HogStats> hogStats = storage.getHogStats();
        if(hogStats != null && !hogStats.isEmpty()){
            loadingScreen.setVisibility(View.GONE);
        }
        adapter = new HogStatsExpandAdapter(getMainActivity(), expandableListView, hogStats);
        return adapter;
    }

    public void setupListeners(final HogStatsExpandAdapter adapter){
        expandableListView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                mainActivity.hideKeyboard(v);
                return false;
            }
        });

        search.setOnQueryTextFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if(!hasFocus) mainActivity.hideKeyboard(v);
            }
        });
        search.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                adapter.getFilter().filter(query);
                search.clearFocus();
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                adapter.getFilter().filter(newText);
                return false;
            }
        });
    }
}
