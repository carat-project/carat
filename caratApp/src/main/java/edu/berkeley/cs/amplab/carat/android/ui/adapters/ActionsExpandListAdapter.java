package edu.berkeley.cs.amplab.carat.android.ui.adapters;

import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;

/**
 * Created by Valto on 2.10.2015.
 */
public class ActionsExpandListAdapter extends BaseExpandableListAdapter implements ExpandableListView.OnGroupExpandListener,
        ExpandableListView.OnChildClickListener {

    private CaratApplication caratApplication;
    private SimpleHogBug[] hogReport, bugReport;

    public ActionsExpandListAdapter(CaratApplication caratApplication, SimpleHogBug[] hogReport, SimpleHogBug[] bugReport) {
        this.caratApplication = caratApplication;
        this.hogReport = hogReport;
        this.bugReport = bugReport;
    }

    @Override
    public int getGroupCount() {
        return 0;
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        return 0;
    }

    @Override
    public Object getGroup(int groupPosition) {
        return null;
    }

    @Override
    public Object getChild(int groupPosition, int childPosition) {
        return null;
    }

    @Override
    public long getGroupId(int groupPosition) {
        return 0;
    }

    @Override
    public long getChildId(int groupPosition, int childPosition) {
        return 0;
    }

    @Override
    public boolean hasStableIds() {
        return false;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded, View convertView, ViewGroup parent) {
        return null;
    }

    @Override
    public View getChildView(int groupPosition, int childPosition, boolean isLastChild, View convertView, ViewGroup parent) {
        return null;
    }

    @Override
    public boolean isChildSelectable(int groupPosition, int childPosition) {
        return false;
    }

    @Override
    public boolean onChildClick(ExpandableListView parent, View v, int groupPosition, int childPosition, long id) {
        return false;
    }

    @Override
    public void onGroupExpand(int groupPosition) {

    }
}
