package edu.berkeley.cs.amplab.carat.android.views.adapters;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.dialogs.BaseDialog;
import edu.berkeley.cs.amplab.carat.android.model_classes.SimpleProcessInfo;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.thrift.ProcessInfo;

/**
 * Created by Valto on 7.10.2015.
 */
public class ProcessExpandListAdapter extends BaseExpandableListAdapter implements View.OnClickListener, ExpandableListView.OnGroupClickListener {

    private MainActivity mainActivity;
    private CaratApplication caratApplication;
    private SimpleProcessInfo[] processInfoList;
    private ExpandableListView lv;
    private LayoutInflater mInflater;

    public ProcessExpandListAdapter(MainActivity mainActivity, ExpandableListView lv,
                                    final CaratApplication caratApplication, List<ProcessInfo> processInfoList) {

        this.caratApplication = caratApplication;
        this.mainActivity = mainActivity;

        SimpleProcessInfo[] convertedResults = convertProcessInfo(processInfoList);
        Arrays.sort(convertedResults);
        this.processInfoList = convertedResults;
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
            convertView = mInflater.inflate(R.layout.process_list_child_item, null);
        }

        SimpleProcessInfo item = processInfoList[groupPosition];
        setViewsInChild(convertView, item);
        return convertView;
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        return 1;
    }

    @Override
    public Object getGroup(int groupPosition) {
        return processInfoList[groupPosition];
    }

    @Override
    public int getGroupCount() {
        return processInfoList.length;
    }

    @Override
    public long getGroupId(int groupPosition) {
        return groupPosition;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded,
                             View convertView, ViewGroup parent) {
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.process_list_header, null);
        }

        if (processInfoList == null || groupPosition < 0
                || groupPosition >= processInfoList.length)
            return convertView;

        SimpleProcessInfo item = processInfoList[groupPosition];
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

    private void setViewsInChild(View v, SimpleProcessInfo item) {
        TextView priorityValue = (TextView) v.findViewById(R.id.priority_value);
        TextView processVersion = (TextView) v.findViewById(R.id.version_amount);
        processVersion.setText(item.getVersionName());
        priorityValue.setText(item.getImportance());

    }

    private void setItemViews(View v, SimpleProcessInfo item, int groupPosition) {
        ImageView processIcon = (ImageView) v.findViewById(R.id.process_icon);
        TextView processName = (TextView) v.findViewById(R.id.process_name);
        TextView processPackage = (TextView) v.findViewById(R.id.process_package);

        processIcon.setImageDrawable(item.getIcon());
        processName.setText(item.getLocalizedName());
        processPackage.setText(item.getPackageName());

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

    private SimpleProcessInfo[] convertProcessInfo(List<ProcessInfo> list){
        List<SimpleProcessInfo> result = new LinkedList<SimpleProcessInfo>();
        Context context = caratApplication.getApplicationContext();
        for(ProcessInfo pi : list){
            String pName = pi.getPName();
            String localizedName = CaratApplication.labelForApp(context, pName);
            String importance = SamplingLibrary.getAppPriority(context, pName);
            Drawable icon = CaratApplication.iconForApp(context, pName);
            PackageInfo pInfo = SamplingLibrary.getPackageInfo(context, pName);
            String versionName;
            if (pInfo != null) {
                versionName = pInfo.versionName;
                if (versionName == null) {
                    versionName = pInfo.versionCode + "";
                }
            } else {
                versionName = "N/A";
            }
            result.add(new SimpleProcessInfo(pName, localizedName, importance, versionName, icon));
        }
        return result.toArray(new SimpleProcessInfo[result.size()]);
    }

}
