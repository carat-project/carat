package edu.berkeley.cs.amplab.carat.android.views.adapters;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.dialogs.BaseDialog;
import edu.berkeley.cs.amplab.carat.android.fragments.HogStatsFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.HogsFragment;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;

/**
 * Created by Valto on 30.9.2015.
 */
public class HogBugExpandListAdapter extends BaseExpandableListAdapter implements ExpandableListView.OnGroupExpandListener,
        ExpandableListView.OnChildClickListener, View.OnClickListener, ExpandableListView.OnGroupClickListener {

    private LayoutInflater mInflater;
    private CaratApplication a = null;
    private LinearLayout buttonView = null;
    private ArrayList<SimpleHogBug> allBugsOrHogs = null;
    private ExpandableListView lv;
    private MainActivity mainActivity;

    public HogBugExpandListAdapter(final MainActivity mainActivity, ExpandableListView lv, CaratApplication caratApplication, SimpleHogBug[] results) {
        this.a = caratApplication;
        mInflater = LayoutInflater.from(this.a);
        this.lv = lv;
        buttonView = (LinearLayout)lv.findViewById(R.id.footer_button_view);
        if(!results[0].isBug() && buttonView == null){
            LinearLayout footer = (LinearLayout)mInflater.inflate(R.layout.button_footer_item, lv, false);
            this.lv.addFooterView(footer);
            LinearLayout showStats = (LinearLayout)this.lv.findViewById(R.id.footer_button);
            showStats.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    HogStatsFragment hogStats = new HogStatsFragment();
                    mainActivity.replaceFragment(hogStats, Constants.FRAGMENG_HOG_STATS_TAG);
                }
            });
        }
        this.lv.setOnGroupExpandListener(this);
        this.mainActivity = mainActivity;
        this.lv.setOnChildClickListener(this);
        this.lv.setOnGroupClickListener(this);

        allBugsOrHogs = CaratApplication.filterByVisibility(results);
        Collections.sort(allBugsOrHogs);
    }

    @Override
    public Object getChild(int groupPosition, int childPosition) {
        return childPosition;
    }

    @Override
    public long getChildId(int groupPosition, int childPosition) {
        return childPosition;
    }

    @Override
    public View getChildView(int groupPosition, int childPosition,
                             boolean isLastChild, View convertView, ViewGroup parent) {

        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.bug_hog_list_child_item, null);
        }

        SimpleHogBug item = allBugsOrHogs.get(groupPosition);
        setViewsInChild(convertView, item);
        return convertView;
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        return 1;
    }

    @Override
    public Object getGroup(int groupPosition) {
        return allBugsOrHogs.get(groupPosition);
    }

    @Override
    public int getGroupCount() {
        return allBugsOrHogs.size();
    }

    @Override
    public long getGroupId(int groupPosition) {
        return groupPosition;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded,
                             View convertView, ViewGroup parent) {
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.bug_hog_list_header, null);
        }

        if (allBugsOrHogs == null || groupPosition < 0
                || groupPosition >= allBugsOrHogs.size())
            return convertView;

        SimpleHogBug item = allBugsOrHogs.get(groupPosition);
        if (item == null)
            return convertView;

        setItemViews(convertView, item, groupPosition);

        return convertView;
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }

    @Override
    public boolean isChildSelectable(int groupPosition, int childPosition) {
        return true;
    }

    private void setViewsInChild(View v, SimpleHogBug item) {
        TextView batteryImpact = (TextView) v.findViewById(R.id.impact_text);
        TextView samplesText = (TextView) v.findViewById(R.id.samples_title);
        TextView samplesValue = (TextView) v.findViewById(R.id.samples_amount);
        TextView samplesError = (TextView) v.findViewById(R.id.error_amount);
        TextView samplesWithoutText = (TextView) v.findViewById(R.id.samples_without_title);
        TextView samplesWithoutValue = (TextView) v.findViewById(R.id.samples_without_amount);
        TextView whatAreTheseNumbers = (TextView) v.findViewById(R.id.what_are_these_numbers);

        samplesText.setText(R.string.samples);
        int[] info = item.getBenefit();
        if(info.length >= 5){
            int errorMin = info[3];
            int errorSec = info[4];
            String error = errorMin >0 ? errorMin+"m" : errorSec+"s";
            samplesError.setText(error);
        }
        batteryImpact.setText(item.getBenefitText());
        samplesValue.setText(String.valueOf(item.getSamples()));
        samplesWithoutText.setText(R.string.samplesWithout);
        samplesWithoutValue.setText(String.valueOf(item.getSamplesWithout()));
        whatAreTheseNumbers.setText(R.string.what_are_these_numbers);

        whatAreTheseNumbers.setOnClickListener(this);

    }

    private void setItemViews(View v, SimpleHogBug item, int groupPosition) {
        ImageView processIcon = (ImageView) v.findViewById(R.id.process_icon);
        TextView processName = (TextView) v.findViewById(R.id.process_name);
        TextView processImprovement = (TextView) v.findViewById(R.id.process_improvement);

        processIcon.setImageDrawable(CaratApplication.iconForApp(a.getApplicationContext(),
                item.getAppName()));
        processName.setText(CaratApplication.labelForApp(a.getApplicationContext(),
                item.getAppName()));
        processImprovement.setText(item.getBenefitText());

    }

    // TODO COLLAPSE IMAGES NOT WORKING
    @Override
    public void onGroupExpand(int groupPosition) {
    }

    @Override
    public void onGroupCollapsed(int groupPosition) {
    }

    @Override
    public boolean onChildClick(ExpandableListView parent, View v, int groupPosition, int childPosition, long id) {
        return true;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.what_are_these_numbers:
                BaseDialog dialog = new BaseDialog(mainActivity,
                        mainActivity.getString(R.string.what_are_these_numbers_title),
                        mainActivity.getString(R.string.what_are_these_numbers_explanation),
                        "detailinfo");
                dialog.showDialog();
                break;
        }
    }

    @Override
    public boolean onGroupClick(ExpandableListView parent, View v, int groupPosition, long id) {
        if (parent.isGroupExpanded(groupPosition)) {
            ImageView collapseIcon = (ImageView) v.findViewById(R.id.collapse_icon);
            collapseIcon.setImageResource(R.drawable.collapse_down);
        } else {
            ImageView collapseIcon = (ImageView) v.findViewById(R.id.collapse_icon);
            collapseIcon.setImageResource(R.drawable.collapse_up);
        }
        return false;
    }
}
