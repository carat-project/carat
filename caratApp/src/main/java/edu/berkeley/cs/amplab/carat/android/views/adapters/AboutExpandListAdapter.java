package edu.berkeley.cs.amplab.carat.android.views.adapters;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.TextView;
import com.nostra13.universalimageloader.core.ImageLoader;

import java.util.ArrayList;

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
public class AboutExpandListAdapter extends BaseExpandableListAdapter implements View.OnClickListener, ExpandableListView.OnGroupClickListener {

    // Use view holders for smoother scrolling
    public static class GroupViewHolder {
        TextView aboutTitle;
        TextView aboutMessage;
    }
    public static class ChildViewHolder {
        TextView childMessage;
    }
    public static class ImageChildViewHolder {
        TextView childMessage;
        ImageView logoView;
    }

    private LayoutInflater mInflater;
    private CaratApplication a = null;
    private ArrayList<AboutItem> allAboutItems = new ArrayList<>();
    private ExpandableListView lv;
    private MainActivity mainActivity;
    private ImageLoader imageLoader;

    public AboutExpandListAdapter(MainActivity mainActivity, ExpandableListView lv, CaratApplication caratApplication, ArrayList<AboutItem> results) {
        this.mainActivity = mainActivity;
        this.a = caratApplication;
        this.lv = lv;
        this.lv.setOnGroupClickListener(this);
        this.allAboutItems = results;
        mInflater = LayoutInflater.from(a);
        this.imageLoader = ImageLoader.getInstance();
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
        // This is used to detect the type of view in view setters
        Object tag = (null == convertView) ? null : convertView.getTag();
        AboutItem item = allAboutItems.get(groupPosition);

        // Child view with an image
        if(item != null && item.getAboutTitle().equals("Carat")) {
            return setupImageChildView(convertView, tag, item);
        }

        // Normal child view
        return setupChildView(convertView, tag, item);
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
        GroupViewHolder holder;

        if (convertView == null || convertView.getTag() == null) {
            convertView = mInflater.inflate(R.layout.about_list_header, null);
            holder = new GroupViewHolder();
            holder.aboutTitle = (TextView) convertView.findViewById(R.id.about_item_title);
            holder.aboutMessage = (TextView) convertView.findViewById(R.id.about_item_message);
            convertView.setTag(holder);
        } else {
            holder = (GroupViewHolder) convertView.getTag();
        }

        if (allAboutItems == null || groupPosition < 0
                || groupPosition >= allAboutItems.size())
            return convertView;

        AboutItem item = allAboutItems.get(groupPosition);
        if (item == null) return convertView;

        setItemViews(holder, item, groupPosition);

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

    private void setItemViews(GroupViewHolder holder, AboutItem item, int groupPosition) {

        holder.aboutTitle.setText(item.getAboutTitle());
        holder.aboutMessage.setText(item.getAboutMessage());

        Log.d("debug", "*** TAGS: " + item.getAboutTitle());

        if (item.getAboutTitle().equals(mainActivity.getResources().getString(R.string.bugs_camel))) {
            holder.aboutMessage.setTag("see_bugs");
            holder.aboutMessage.setTextColor(mainActivity.getResources().getColor(R.color.orange));
            holder.aboutMessage.setOnClickListener(this);
        } else if (item.getAboutTitle().equals(mainActivity.getResources().getString(R.string.hogs_camel))) {
            holder.aboutMessage.setTag("see_hogs");
            holder.aboutMessage.setTextColor(mainActivity.getResources().getColor(R.color.orange));
            holder.aboutMessage.setOnClickListener(this);
        } else {
            holder.aboutMessage.setTextColor(mainActivity.getResources().getColor(R.color.gray));
            holder.aboutMessage.setOnClickListener(null);
        }

    }

    private View setupChildView(View v, Object tag, AboutItem item){
        ChildViewHolder holder;
        if(tag instanceof ChildViewHolder){
            holder = (ChildViewHolder) tag;
        } else {
            v = mInflater.inflate(R.layout.about_list_child_item, null);

            holder = new ChildViewHolder();
            holder.childMessage = (TextView) v.findViewById(R.id.about_child_text);
            v.setTag(holder);
        }
        holder.childMessage.setText(item.getChildMessage());
        return v;
    }

    private View setupImageChildView(View v, Object tag, AboutItem item){
        ImageChildViewHolder holder;
        if(tag instanceof ImageChildViewHolder){
            holder = (ImageChildViewHolder) tag;
        } else {
            v = mInflater.inflate(R.layout.about_list_child_item_logo, null);

            holder = new ImageChildViewHolder();
            holder.childMessage = (TextView) v.findViewById(R.id.about_child_text);
            holder.logoView = (ImageView) v.findViewById(R.id.university_logo);
            v.setTag(holder);
        }

        holder.childMessage.setText(item.getChildMessage());
        holder.logoView.setVisibility(View.VISIBLE);
        imageLoader.displayImage("drawable://" + R.drawable.university_logo, holder.logoView);
        return v;
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
