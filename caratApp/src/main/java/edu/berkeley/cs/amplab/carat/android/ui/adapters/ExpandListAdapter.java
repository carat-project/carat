package edu.berkeley.cs.amplab.carat.android.ui.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.security.acl.Group;
import java.util.ArrayList;

import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.model_classes.HogBug;
import edu.berkeley.cs.amplab.carat.android.model_classes.HogBugDetails;

/**
 * Created by Valto on 30.9.2015.
 */
public class ExpandListAdapter extends BaseExpandableListAdapter {

    private Context context;
    private ArrayList<HogBug> groups;

    public ExpandListAdapter(Context context, ArrayList<HogBug> groups) {
        this.context = context;
        this.groups = groups;
    }

    @Override
    public Object getChild(int groupPosition, int childPosition) {
        ArrayList<HogBugDetails> chList = groups.get(groupPosition).getItems();
        return chList.get(childPosition);
    }

    @Override
    public long getChildId(int groupPosition, int childPosition) {
        return childPosition;
    }

    @Override
    public View getChildView(int groupPosition, int childPosition,
                             boolean isLastChild, View convertView, ViewGroup parent) {

        HogBugDetails child = (HogBugDetails) getChild(groupPosition, childPosition);
        if (convertView == null) {
            LayoutInflater infalInflater = (LayoutInflater) context
                    .getSystemService(context.LAYOUT_INFLATER_SERVICE);
            convertView = infalInflater.inflate(R.layout.bug_hog_list_child_item, null);
        }
        TextView tv = (TextView) convertView.findViewById(R.id.country_name);
        ImageView iv = (ImageView) convertView.findViewById(R.id.flag);

        tv.setText(child.getName().toString());
        iv.setImageResource(child.getImage());

        return convertView;
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        ArrayList<HogBugDetails> chList = groups.get(groupPosition).getItems();
        return chList.size();
    }

    @Override
    public Object getGroup(int groupPosition) {
        return groups.get(groupPosition);
    }

    @Override
    public int getGroupCount() {
        return groups.size();
    }

    @Override
    public long getGroupId(int groupPosition) {
        return groupPosition;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded,
                             View convertView, ViewGroup parent) {
        Group group = (Group) getGroup(groupPosition);
        if (convertView == null) {
            LayoutInflater inf = (LayoutInflater) context
                    .getSystemService(context.LAYOUT_INFLATER_SERVICE);
            convertView = inf.inflate(R.layout.bug_hog_list_item, null);
        }
        TextView tv = (TextView) convertView.findViewById(R.id.bug_app_name);
        tv.setText(group.getName());
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

}
