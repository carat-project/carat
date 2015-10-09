package edu.berkeley.cs.amplab.carat.android.ui.adapters;

import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.Button;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.HashMap;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.protocol.ClickTracking;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;

/**
 * Created by Valto on 2.10.2015.
 */
public class ActionsExpandListAdapter extends BaseExpandableListAdapter implements View.OnClickListener,
        Runnable, ExpandableListView.OnGroupClickListener, ExpandableListView.OnGroupExpandListener {

    private CaratApplication caratApplication;
    private SimpleHogBug[] hogReport, bugReport;
    private ArrayList<SimpleHogBug> allReports = new ArrayList<>();
    private LayoutInflater mInflater;
    private ExpandableListView lv;
    private MainActivity mainActivity;

    private ImageView processIcon;
    private TextView processName;
    private TextView processImprovement;
    private TextView samplesAmount;
    private TextView appCategory;
    private Button killAppButton;
    private SurfaceHolder progressSurfaceHolder;
    private Thread drawingThread;

    private SurfaceView progressSurface;

    private SimpleHogBug storedHogBug;

    private boolean locker;
    private int previousGroup = -1;

    public ActionsExpandListAdapter(MainActivity mainActivity, ExpandableListView lv, CaratApplication caratApplication,
                                    SimpleHogBug[] hogReport, SimpleHogBug[] bugReport) {

        this.caratApplication = caratApplication;
        this.hogReport = hogReport;
        this.bugReport = bugReport;
        this.lv = lv;
        this.lv.setOnGroupClickListener(this);
        this.lv.setOnGroupExpandListener(this);
        this.mainActivity = mainActivity;

        for (SimpleHogBug s : hogReport) {
            allReports.add(s);
        }
        for (SimpleHogBug s : bugReport) {
            allReports.add(s);
        }

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
            convertView = infalInflater.inflate(R.layout.actions_list_child_item, null);
        }

        SimpleHogBug item = allReports.get(groupPosition);
        setViewsInChild(convertView, item);
        return convertView;
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        return 1;
    }

    @Override
    public Object getGroup(int groupPosition) {
        return allReports.get(groupPosition);
    }

    @Override
    public int getGroupCount() {
        return allReports.size();
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
            convertView = inf.inflate(R.layout.bug_hog_list_header, null);
        }

        if (allReports == null || groupPosition < 0
                || groupPosition >= allReports.size())
            return convertView;

        SimpleHogBug item = allReports.get(groupPosition);
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
        samplesAmount = (TextView) v.findViewById(R.id.samples_amount);
        killAppButton = (Button) v.findViewById(R.id.stop_app_button);
        appCategory = (TextView) v.findViewById(R.id.app_category);
        samplesText.setText(R.string.samples);
        samplesAmount.setText(String.valueOf(item.getSamples()));
        locker = true;
        drawProgress(v, item);
        killAppButton.setOnClickListener(this);

    }

    private void setItemViews(View v, SimpleHogBug item, int groupPosition) {
        processIcon = (ImageView) v.findViewById(R.id.process_icon);
        processName = (TextView) v.findViewById(R.id.process_name);
        processImprovement = (TextView) v.findViewById(R.id.process_improvement);

        processIcon.setImageDrawable(CaratApplication.iconForApp(caratApplication.getApplicationContext(),
                item.getAppName()));
        processName.setText(CaratApplication.labelForApp(caratApplication.getApplicationContext(),
                item.getAppName()));
        processImprovement.setText(item.getBenefitText());
    }

    private void drawProgress(View v, SimpleHogBug item) {
        progressSurface = (SurfaceView) v.findViewById(R.id.progress_surface);
        progressSurfaceHolder = progressSurface.getHolder();
        drawingThread = new Thread(this);
        drawingThread.start();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.stop_app_button:
                if (storedHogBug != null) {
                    killApp(storedHogBug);
                }
                break;
            default:
                break;
        }
    }

    public void killApp(SimpleHogBug fullObject) {
        final String raw = fullObject.getAppName();
        final PackageInfo pak = SamplingLibrary.getPackageInfo(mainActivity, raw);
        final String label = CaratApplication.labelForApp(mainActivity, raw);

        if (raw.equals("OsUpgrade")) {
            //m.showHTMLFile("upgradeos", dashboardActivity.getString(R.string.upgradeosinfo), false);
        } else if (raw.equals(mainActivity.getString(R.string.helpcarat))) {
            //m.showHTMLFile("collectdata", dashboardActivity.getString(R.string.collectdatainfo), false);
        } else if (raw.equals(mainActivity.getString(R.string.questionnaire))) {
            //openQuestionnaire();
        } else {
            SharedPreferences p = PreferenceManager.getDefaultSharedPreferences(mainActivity);
            if (p != null) {
                String uuId = p.getString(CaratApplication.getRegisteredUuid(), "UNKNOWN");
                HashMap<String, String> options = new HashMap<String, String>();
                if (pak != null) {
                    options.put("app", pak.packageName);
                    options.put("version", pak.versionName);
                    options.put("versionCode", pak.versionCode + "");
                    options.put("label", label);
                }
                options.put("benefit", samplesAmount.getText().toString().replace('\u00B1', '+'));
                ClickTracking.track(uuId, "killbutton", options, caratApplication);
            }

            killAppButton.setEnabled(false);
            killAppButton.setBackgroundResource(R.drawable.button_rounded_gray);
            killAppButton.setText(caratApplication.getString(R.string.stopped));
            SamplingLibrary.killApp(mainActivity, raw, label);

        }
    }

    @Override
    public void run() {
        while (locker) {
            if (!progressSurfaceHolder.getSurface().isValid()) {
                continue;
            }
            Canvas c = progressSurfaceHolder.lockCanvas();
            draw(c);
            progressSurfaceHolder.unlockCanvasAndPost(c);
        }
    }

    private void draw(Canvas canvas) {
        RectF r = new RectF(0, 0, canvas.getWidth(), canvas.getHeight());
        canvas.drawColor(Color.argb(255, 180, 180, 180));
        Paint paint = new Paint();
        paint.setARGB(255, 75, 200, 127);
        canvas.drawRect(r, paint);
        locker = false;
    }

    @Override
    public boolean onGroupClick(ExpandableListView parent, View v, int groupPosition, long id) {
        storedHogBug = allReports.get(groupPosition);
        if (parent.isGroupExpanded(groupPosition)) {
            ImageView collapseIcon = (ImageView) v.findViewById(R.id.collapse_icon);
            collapseIcon.setImageResource(R.drawable.collapse_down);
        } else {
            ImageView collapseIcon = (ImageView) v.findViewById(R.id.collapse_icon);
            collapseIcon.setImageResource(R.drawable.collapse_up);
        }
        return false;
    }

    @Override
    public void onGroupExpand(int groupPosition) {
        storedHogBug = allReports.get(groupPosition);
        if (groupPosition != previousGroup)
            lv.collapseGroup(previousGroup);
        previousGroup = groupPosition;
    }
}
