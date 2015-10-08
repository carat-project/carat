package edu.berkeley.cs.amplab.carat.android.ui.adapters;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Arrays;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.fragments.BugsFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.HogsFragment;
import edu.berkeley.cs.amplab.carat.android.model_classes.AboutItem;

/**
 * Created by Valto on 6.10.2015.
 */
public class AboutExpandListAdapter extends BaseExpandableListAdapter implements ExpandableListView.OnGroupExpandListener,
        ExpandableListView.OnChildClickListener, View.OnClickListener, ExpandableListView.OnGroupClickListener {

    private LayoutInflater mInflater;
    private CaratApplication a = null;
    private ArrayList<AboutItem> allAboutItems = new ArrayList<>();
    private ExpandableListView lv;
    private ImageView collapseIcon;
    private ArrayList<ImageView> collapseTags;
    private MainActivity mainActivity;

    public AboutExpandListAdapter(MainActivity mainActivity, ExpandableListView lv, CaratApplication caratApplication, ArrayList<AboutItem> results) {
        collapseTags = new ArrayList<>();
        this.mainActivity = mainActivity;
        this.a = caratApplication;
        this.lv = lv;
        this.lv.setOnGroupExpandListener(this);
        this.lv.setOnChildClickListener(this);
        this.lv.setOnGroupClickListener(this);
        allAboutItems = results;
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
            convertView = infalInflater.inflate(R.layout.about_list_child_item, null);
        }

        AboutItem item = allAboutItems.get(groupPosition);
        setViewsInChild(convertView, item);
        return convertView;
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        return 1;
    }

    @Override
    public Object getGroup(int groupPosition) {
        return allAboutItems.get(groupPosition);
    }

    @Override
    public int getGroupCount() {
        return allAboutItems.size();
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
            convertView = inf.inflate(R.layout.about_list_header, null);
        }

        if (allAboutItems == null || groupPosition < 0
                || groupPosition >= allAboutItems.size())
            return convertView;

        AboutItem item = allAboutItems.get(groupPosition);
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

    private void setViewsInChild(View v, AboutItem item) {
        TextView childMessage = (TextView) v.findViewById(R.id.about_child_text);
        childMessage.setText(item.getChildMessage());

    }

    private void setItemViews(View v, AboutItem item, int groupPosition) {

        TextView aboutTitle = (TextView) v.findViewById(R.id.about_item_title);
        TextView aboutMessage = (TextView) v.findViewById(R.id.about_item_message);

        aboutTitle.setText(item.getAboutTitle());
        aboutMessage.setText(item.getAboutMessage());

        Log.d("debug", "*** TAGS: " + item.getAboutTitle());

        if (item.getAboutTitle().equals("Bugs")) {
            aboutMessage.setTag("see_bugs");
            aboutMessage.setTextColor(mainActivity.getResources().getColor(R.color.orange));
            aboutMessage.setOnClickListener(this);
        } else if (item.getAboutTitle().equals("Hogs")) {
            aboutMessage.setTag("see_hogs");
            aboutMessage.setTextColor(mainActivity.getResources().getColor(R.color.orange));
            aboutMessage.setOnClickListener(this);
        }
        if (item.getAboutTitle().equals("Carat")) {
            aboutMessage.setTextColor(mainActivity.getResources().getColor(R.color.gray));
            aboutMessage.setOnClickListener(null);
        }

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
        if (v.getId() == R.id.about_item_message) {
            if (v.getTag().equals("see_bugs")) {
                BugsFragment bugsFragment = new BugsFragment();
                mainActivity.replaceFragment(bugsFragment, Constants.FRAGMENT_BUGS_TAG);
            } else if (v.getTag().equals("see_hogs")) {
                HogsFragment hogsFragment = new HogsFragment();
                mainActivity.replaceFragment(hogsFragment, Constants.FRAGMENT_HOGS_TAG);
            }
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
