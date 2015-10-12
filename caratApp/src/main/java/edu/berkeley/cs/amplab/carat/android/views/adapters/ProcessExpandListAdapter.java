package edu.berkeley.cs.amplab.carat.android.views.adapters;

import android.content.pm.PackageInfo;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.dialogs.BaseDialog;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.thrift.ProcessInfo;

/**
 * Created by Valto on 7.10.2015.
 */
public class ProcessExpandListAdapter extends BaseExpandableListAdapter implements View.OnClickListener, ExpandableListView.OnGroupClickListener {

    private MainActivity mainActivity;
    private CaratApplication caratApplication;
    private List<ProcessInfo> processInfoList = new ArrayList<>();
    private ExpandableListView lv;
    private LayoutInflater mInflater;

    public ProcessExpandListAdapter(MainActivity mainActivity, ExpandableListView lv,
                                    CaratApplication caratApplication, List<ProcessInfo> processInfoList) {
        this.caratApplication = caratApplication;
        this.mainActivity = mainActivity;
        this.processInfoList = processInfoList;
        this.lv = lv;
        this.lv.setOnGroupClickListener(this);

        mInflater = LayoutInflater.from(caratApplication);

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
            LayoutInflater infalInflater = (LayoutInflater) caratApplication.getApplicationContext()
                    .getSystemService(caratApplication.getApplicationContext().LAYOUT_INFLATER_SERVICE);
            convertView = infalInflater.inflate(R.layout.process_list_child_item, null);
        }

        ProcessInfo item = processInfoList.get(groupPosition);
        setViewsInChild(convertView, item);
        return convertView;
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        return 1;
    }

    @Override
    public Object getGroup(int groupPosition) {
        return processInfoList.get(groupPosition);
    }

    @Override
    public int getGroupCount() {
        return processInfoList.size();
    }

    @Override
    public long getGroupId(int groupPosition) {
        return groupPosition;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded,
                             View convertView, ViewGroup parent) {
        if (convertView == null) {
            LayoutInflater inf = (LayoutInflater) caratApplication.getApplicationContext()
                    .getSystemService(caratApplication.getApplicationContext().LAYOUT_INFLATER_SERVICE);
            convertView = inf.inflate(R.layout.process_list_header, null);
        }

        if (processInfoList == null || groupPosition < 0
                || groupPosition >= processInfoList.size())
            return convertView;

        ProcessInfo item = processInfoList.get(groupPosition);
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

    private void setViewsInChild(View v, ProcessInfo item) {
        TextView priorityValue = (TextView) v.findViewById(R.id.priority_value);
        TextView processVersion = (TextView) v.findViewById(R.id.version_amount);

        String p = item.getPName();
        String versionName;
        PackageInfo pkgInfo = SamplingLibrary.getPackageInfo(caratApplication.getApplicationContext(), p);
        if (pkgInfo != null) {
            versionName = pkgInfo.versionName;
            if (versionName == null) {
                versionName = pkgInfo.versionCode + "";
            }
        } else {
            versionName = "N/A";
        }

        processVersion.setText(versionName);
        priorityValue.setText(item.getImportance());

    }

    private void setItemViews(View v, ProcessInfo item, int groupPosition) {
        ImageView processIcon = (ImageView) v.findViewById(R.id.process_icon);
        TextView processName = (TextView) v.findViewById(R.id.process_name);
        TextView processPackage = (TextView) v.findViewById(R.id.process_package);

        String p = item.getPName();

        processIcon.setImageDrawable(CaratApplication.iconForApp(caratApplication.getApplicationContext(), p));
        processName.setText(CaratApplication.labelForApp(caratApplication.getApplicationContext(), p));
        processPackage.setText(p);

    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.what_are_these_numbers:
                BaseDialog dialog = new BaseDialog(mainActivity,
                        mainActivity.getString(R.string.what_are_these_numbers_title),
                        mainActivity.getString(R.string.what_are_these_numbers_explanation));
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
