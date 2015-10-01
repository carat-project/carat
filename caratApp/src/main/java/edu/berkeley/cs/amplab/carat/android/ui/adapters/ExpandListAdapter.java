package edu.berkeley.cs.amplab.carat.android.ui.adapters;

import android.content.Context;
import android.media.Image;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.TextView;

import org.w3c.dom.Text;

import java.security.acl.Group;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.model_classes.HogBug;
import edu.berkeley.cs.amplab.carat.android.model_classes.HogBugDetails;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;
import edu.berkeley.cs.amplab.carat.thrift.Reports;

/**
 * Created by Valto on 30.9.2015.
 */
public class ExpandListAdapter extends BaseExpandableListAdapter implements ExpandableListView.OnGroupExpandListener,
        ExpandableListView.OnChildClickListener {

    private LayoutInflater mInflater;
    private CaratApplication a = null;
    private SimpleHogBug[] allBugsOrHogs = null;
    private ExpandableListView lv;
    private ImageView collapseIcon;
    private ArrayList<ImageView> collapseTags;

    public ExpandListAdapter(ExpandableListView lv, CaratApplication caratApplication, SimpleHogBug[] results) {
        collapseTags = new ArrayList<>();
        this.a = caratApplication;
        this.lv = lv;
        this.lv.setOnGroupExpandListener(this);
        this.lv.setOnChildClickListener(this);
        int items = 0;
        if (results != null)
            for (SimpleHogBug app : results) {
                String appName = app.getAppName();
                if (appName == null)
                    appName = caratApplication.getString(R.string.unknown);
                // don't show special apps: Carat or system apps
                // (DISABLED FOR DEBUGGING. TODO: ENABLE IT AFTER DEBUGGING, and check whether this has any problem)
                //                if (SpecialAppCases.isSpecialApp(appName))
                if (appName.equals(Constants.CARAT_PACKAGE_NAME) || appName.equals(Constants.CARAT_OLD))
                    continue;
                items++;
            }
        allBugsOrHogs = new SimpleHogBug[items];
        int i = 0;
        if (results != null && results.length > 0 && allBugsOrHogs.length > 0
                && i < allBugsOrHogs.length)
            for (SimpleHogBug b : results) {
                String appName = b.getAppName();
                if (appName == null)
                    appName = caratApplication.getString(R.string.unknown);
                if (appName.equals(Constants.CARAT_PACKAGE_NAME)
                        || appName.equals(Constants.CARAT_OLD))
                    continue;
                // Apparently the number of items changes from "items" above?
                /*
                 * This must be handled by Carat data storage.
    			 * */
                if (i < allBugsOrHogs.length) {
                    allBugsOrHogs[i] = b;
                    i++;
                }
            }
        Arrays.sort(allBugsOrHogs);
        mInflater = LayoutInflater.from(a);
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
            LayoutInflater infalInflater = (LayoutInflater) a.getApplicationContext()
                    .getSystemService(a.getApplicationContext().LAYOUT_INFLATER_SERVICE);
            convertView = infalInflater.inflate(R.layout.bug_hog_list_child_item, null);
        }

        SimpleHogBug item = allBugsOrHogs[groupPosition];
        setViewsInChild(convertView, item);
        return convertView;
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        return 1;
    }

    @Override
    public Object getGroup(int groupPosition) {
        return allBugsOrHogs[groupPosition];
    }

    @Override
    public int getGroupCount() {
        return allBugsOrHogs.length;
    }

    @Override
    public long getGroupId(int groupPosition) {
        return groupPosition;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded,
                             View convertView, ViewGroup parent) {
        if (convertView == null) {
            LayoutInflater inf = (LayoutInflater) a.getApplicationContext()
                    .getSystemService(a.getApplicationContext().LAYOUT_INFLATER_SERVICE);
            convertView = inf.inflate(R.layout.bug_hog_list_item, null);
        }

        if (allBugsOrHogs == null || groupPosition < 0
                || groupPosition >= allBugsOrHogs.length)
            return convertView;

        SimpleHogBug item = allBugsOrHogs[groupPosition];
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
        TextView samplesText = (TextView) v.findViewById(R.id.samples_title);
        TextView samplesValue = (TextView) v.findViewById(R.id.samples_amount);
        TextView samplesWithoutText = (TextView) v.findViewById(R.id.samples_without_title);
        TextView samplesWithoutValue = (TextView) v.findViewById(R.id.samples_without_amount);
        TextView whatAreTheseNumbers = (TextView) v.findViewById(R.id.what_are_these_numbers);

        samplesText.setText(R.string.samples);
        samplesValue.setText(String.valueOf(item.getSamples()));
        samplesWithoutText.setText(R.string.samplesWithout);
        samplesWithoutValue.setText(String.valueOf(item.getSamplesWithout()));
        whatAreTheseNumbers.setText(R.string.what_are_these_numbers);

    }

    private void setItemViews(View v, SimpleHogBug item, int groupPosition) {
        ImageView processIcon = (ImageView) v.findViewById(R.id.process_icon);
        TextView processName = (TextView) v.findViewById(R.id.process_name);
        TextView processImprovement = (TextView) v.findViewById(R.id.process_improvement);
        collapseIcon = (ImageView) v.findViewById(R.id.collapse_icon);

        processIcon.setImageDrawable(CaratApplication.iconForApp(a.getApplicationContext(),
                item.getAppName()));
        processName.setText(CaratApplication.labelForApp(a.getApplicationContext(),
                item.getAppName()));
        processImprovement.setText(item.getBenefitText());
        collapseIcon.setImageResource(R.drawable.collapse_down);
        collapseIcon.setTag(groupPosition);
        collapseTags.add(collapseIcon);

    }

    // TODO COLLAPSE IMAGES NOT WORKING
    @Override
    public void onGroupExpand(int groupPosition) {
        for (ImageView iV : collapseTags) {
            if (groupPosition == (int) iV.getTag()) {
                iV.setImageResource(R.drawable.collapse_up);
            }
        }
    }

    @Override
    public void onGroupCollapsed(int groupPosition) {
        for (ImageView iV : collapseTags) {
            if (groupPosition == (int) iV.getTag()) {
                iV.setImageResource(R.drawable.collapse_down);
            }
        }
    }

    @Override
    public boolean onChildClick(ExpandableListView parent, View v, int groupPosition, int childPosition, long id) {
       /* v.findFocus()
        if (v.findViewById(R.id.what_are_these_numbers)) {

        }*/
        return true;
    }
}
