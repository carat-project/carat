package edu.berkeley.cs.amplab.carat.android.views.adapters;

import android.provider.ContactsContract;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.ImageView;
import android.widget.TextView;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.storage.HogStats;

/**
 * Created by Jonatan Hamberg on 2.5.2016.
 */
public class HogStatsExpandAdapter extends BaseExpandableListAdapter implements ExpandableListView.OnGroupExpandListener,
        ExpandableListView.OnChildClickListener, View.OnClickListener, ExpandableListView.OnGroupClickListener, Filterable{
    private MainActivity mainActivity;
    private LayoutInflater mInflater;
    private ExpandableListView lv;
    private CaratApplication a = null;
    private List<HogStats> allHogStats = null;
    private List<HogStats> filteredHogStats = null;
    private int previousGroup = -1;

    private static class CollapsedViewHolder {
        private TextView rank;
        private TextView appName;
        private TextView batteryImpact;
    }

    private static class ExpandedViewHolder{
        private TextView packageName;
        private TextView reportedBy;
        private TextView samples;
    }

    public HogStatsExpandAdapter(MainActivity mainActivity, ExpandableListView lv, List<HogStats> hogStats) {
        this.mainActivity = mainActivity;
        this.lv = lv;
        this.a = (CaratApplication) mainActivity.getApplication();
        this.allHogStats = new ArrayList<>(hogStats);
        this.filteredHogStats = new ArrayList<>(hogStats);

        this.mInflater = LayoutInflater.from(a);

        // Setup listeners
        this.lv.setOnGroupExpandListener(this);
        this.lv.setOnChildClickListener(this);
        this.lv.setOnGroupClickListener(this);
    }

    /**
     * Updates current list view when new data arrives.
     * @param hogStats Updated data
     */
    public void refresh(List<HogStats> hogStats){
        this.allHogStats = hogStats;
        this.filteredHogStats = hogStats;
        notifyDataSetChanged();
    }

    @Override
    public int getGroupCount() {
        return filteredHogStats.size();
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        return 1;
    }

    @Override
    public Object getGroup(int groupPosition) {
        return filteredHogStats.get(groupPosition);
    }

    @Override
    public Object getChild(int groupPosition, int childPosition) {
        return childPosition;
    }

    @Override
    public long getGroupId(int groupPosition) {
        return groupPosition;
    }

    @Override
    public long getChildId(int groupPosition, int childPosition) {
        return childPosition;
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded, View convertView, ViewGroup parent) {
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.hog_stats_header, parent, false);
            CollapsedViewHolder holder = getCollapsedViewHolder(convertView);
            convertView.setTag(holder);
        }

        if(filteredHogStats == null || groupPosition < 0) return convertView;
        HogStats item = filteredHogStats.get(groupPosition);
        if(item == null) return convertView;

        setupCollapsedValues(convertView, item, groupPosition);
        return convertView;

    }

    public CollapsedViewHolder getCollapsedViewHolder(View v){
        CollapsedViewHolder holder = new CollapsedViewHolder();
        holder.rank = (TextView) v.findViewById(R.id.app_rank);
        holder.appName = (TextView) v.findViewById(R.id.app_name);
        holder.batteryImpact = (TextView) v.findViewById(R.id.battery_impact);
        return holder;
    }

    public void setupCollapsedValues(View v, HogStats stats, int position){
        CollapsedViewHolder holder = (CollapsedViewHolder) v.getTag();

        // Not using position here since we need to filter data
        // while retaining the original rank
        String rank = stats.getIndex()+")";
        long benefit = stats.getKillBenefit();

        holder.rank.setText(rank);
        holder.appName.setText(stats.getAppName());
        String impact = mainActivity.getString(R.string.impact);
        String benefitText = impact + " " + getBenefitString(benefit);
        holder.batteryImpact.setText(benefitText);
    }

    public String getBenefitString(long benefitMinutes){
        long minutes = benefitMinutes % 60;
        long hours = benefitMinutes / 60;
        return hours+"h "+minutes+"m";
    }

    @Override
    public View getChildView(int groupPosition, int childPosition, boolean isLastChild, View convertView, ViewGroup parent) {
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.hog_stats_child_item, null);
            ExpandedViewHolder holder = getExpandedViewHolder(convertView);
            convertView.setTag(holder);
        }

        if(filteredHogStats == null || groupPosition < 0) return convertView;
        HogStats item = filteredHogStats.get(groupPosition);
        if(item == null) return convertView;

        setupExpandedValues(convertView, item);

        return convertView;
    }

    public void setupExpandedValues(View v, HogStats stats){
        ExpandedViewHolder holder = (ExpandedViewHolder) v.getTag();
        String samples = String.valueOf(stats.getSamples());
        holder.samples.setText(samples);
        holder.packageName.setText(stats.getPackageName());
        String users = stats.getUsers()+" "+mainActivity.getString(R.string.by_users);
        holder.reportedBy.setText(users);
    }

    public ExpandedViewHolder getExpandedViewHolder(View v){
        ExpandedViewHolder holder = new ExpandedViewHolder();
        holder.packageName = (TextView) v.findViewById(R.id.package_name);
        holder.reportedBy = (TextView) v.findViewById(R.id.reported_by);
        holder.samples = (TextView) v.findViewById(R.id.samples);
        return holder;
    }

    @Override
    public boolean isChildSelectable(int groupPosition, int childPosition) {
        return true;
    }

    @Override
    public boolean onChildClick(ExpandableListView parent, View v, int groupPosition, int childPosition, long id) {
        return true;
    }

    @Override
    public void onClick(View v) {

    }

    @Override
    public boolean onGroupClick(ExpandableListView parent, View v, int groupPosition, long id) {
        ImageView collapseIcon = (ImageView) v.findViewById(R.id.collapse_icon);
        if(collapseIcon == null) return false;
        if(parent.isGroupExpanded(groupPosition)){
            collapseIcon.setImageResource(R.drawable.collapse_down);
        } else {
            collapseIcon.setImageResource(R.drawable.collapse_up);
        }
        return false;
    }

    @Override
    public void onGroupExpand(int groupPosition) {
        if(groupPosition != previousGroup){
            lv.collapseGroup(previousGroup);
            View v = lv.getChildAt(previousGroup);
            if(v != null){
                ImageView collapseIcon = (ImageView) v.findViewById(R.id.collapse_icon);
                if(collapseIcon != null){
                    collapseIcon.setImageResource(R.drawable.collapse_down);
                }
            }
        }
        previousGroup = groupPosition;
    }

    @Override
    public Filter getFilter() {
        final Filter filter = new Filter() {
            @Override
            protected FilterResults performFiltering(CharSequence constraint) {
                FilterResults results = new FilterResults();

                // Even when the query user entered is empty, we want to
                // reset the view back to its original state.
                if(constraint == null || constraint.length() == 0){
                    results.count = allHogStats.size();
                    results.values = allHogStats;
                } else {

                    // Filter by app names and include items that contain the
                    // search query. Both are first converted lowercase.
                    ArrayList<HogStats> filtered = new ArrayList<>();
                    for(HogStats stats : allHogStats){
                        String appName = stats.getAppName().toLowerCase();
                        if(appName.contains(constraint.toString().toLowerCase())){
                            filtered.add(stats);
                        }
                    }
                    results.count = filtered.size();
                    results.values = filtered;
                }
                return results;
            }

            @SuppressWarnings("unchecked")
            @Override
            protected void publishResults(CharSequence constraint, FilterResults results) {
                filteredHogStats.clear();
                filteredHogStats.addAll((ArrayList<HogStats>) results.values);
                notifyDataSetChanged();
            }
        };
        return filter;
    }
}
