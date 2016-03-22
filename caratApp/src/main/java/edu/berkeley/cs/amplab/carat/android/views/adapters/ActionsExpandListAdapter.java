package edu.berkeley.cs.amplab.carat.android.views.adapters;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.Button;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.HashMap;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.fragments.CallbackWebViewFragment;
import edu.berkeley.cs.amplab.carat.android.protocol.ClickTracking;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;
import edu.berkeley.cs.amplab.carat.thrift.Reports;

/**
 * Created by Valto on 2.10.2015.
 */
public class ActionsExpandListAdapter extends BaseExpandableListAdapter implements
        ExpandableListView.OnGroupClickListener, ExpandableListView.OnGroupExpandListener,
        ExpandableListView.OnChildClickListener {

    private enum ActionType{
        SURVEY, HELP
    }

    private class StaticAction {
        public ActionType type;
        public int icon;
        public String title;
        public String subtitle;
        public boolean expandable;
        public String text;
    }

    private CaratApplication caratApplication;
    private ArrayList<SimpleHogBug> allReports = new ArrayList<>();
    private ArrayList<StaticAction> staticActions = new ArrayList<>();
    private LayoutInflater mInflater;
    private ExpandableListView lv;
    private MainActivity mainActivity;

    private ImageView processIcon;
    private ImageView collapseIcon;
    private TextView processName;
    private TextView processImprovement;
    private TextView samplesAmount;
    private TextView appCategory;
    private Button killAppButton;
    private Button appManagerButton;
    private Context context;

    private SimpleHogBug storedHogBug;

    private int previousGroup = -1;

    public ActionsExpandListAdapter(MainActivity mainActivity, ExpandableListView lv, CaratApplication caratApplication,
                                    SimpleHogBug[] hogReport, SimpleHogBug[] bugReport, Context context) {

        this.context = context;
        this.caratApplication = caratApplication;
        this.lv = lv;
        this.lv.setOnGroupClickListener(this);
        this.lv.setOnGroupExpandListener(this);
        this.lv.setOnChildClickListener(this);
        this.mainActivity = mainActivity;

        if(hogReport != null){
            for (SimpleHogBug s : hogReport) {
                if (SamplingLibrary.isRunning(mainActivity, s.getAppName())) {
                    allReports.add(s);
                }
            }
        }
        if(bugReport != null){
            for (SimpleHogBug s : bugReport) {
                if (SamplingLibrary.isRunning(mainActivity, s.getAppName())) {
                    allReports.add(s);
                }
            }
        }

        createStaticActions();

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

        if(groupPosition >= allReports.size()) return convertView;

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
        return allReports.size() + staticActions.size();
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

        if (allReports == null || groupPosition < 0) return convertView;
        if(groupPosition >= allReports.size()){
            int offset = groupPosition-allReports.size();
            StaticAction staticAction = staticActions.get(offset);
            if(staticAction == null) return convertView;
            setStaticViews(convertView, staticAction);
        } else {
            SimpleHogBug item = allReports.get(groupPosition);
            if (item == null) return convertView;
            setItemViews(convertView, item, groupPosition);
        }

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

    private void setViewsInChild(View v, final SimpleHogBug item) {
        TextView samplesText = (TextView) v.findViewById(R.id.samples_title);
        samplesAmount = (TextView) v.findViewById(R.id.samples_amount);
        killAppButton = (Button) v.findViewById(R.id.stop_app_button);
        appManagerButton = (Button) v.findViewById(R.id.app_manager_button);
        appCategory = (TextView) v.findViewById(R.id.app_category);

        samplesText.setText(R.string.samples);
        samplesAmount.setText(String.valueOf(item.getSamples()));
        killAppButton.setTag(item.getAppName());
        appCategory.setText(SamplingLibrary.getAppPriority(context, item.getAppName()));

        // Currently these need to be set each time, refactor?
        killAppButton.setBackgroundResource(R.drawable.button_rounded_orange);
        killAppButton.setText(context.getString(R.string.stop_app_title));

        killAppButton.setEnabled(true);
        killAppButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                killApp(item, v);
            }
        });

        appManagerButton.setEnabled(true);
        appManagerButton.setTag(item.getAppName()+"_manager");
        appManagerButton.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                openAppDetails(item);
            }
        });

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

    private void setStaticViews(View v, StaticAction action){
        processIcon = (ImageView) v.findViewById(R.id.process_icon);
        processName = (TextView) v.findViewById(R.id.process_name);
        processImprovement = (TextView) v.findViewById(R.id.process_improvement);
        collapseIcon = (ImageView) v.findViewById(R.id.collapse_icon);

        processIcon.setImageResource(action.icon);
        processName.setText(action.title);
        processImprovement.setText(action.subtitle);
        collapseIcon.setImageResource(R.drawable.collapse_right);
    }

    private void createStaticActions(){
        String title = mainActivity.getString(R.string.survey_action_title);
        String subtitle = mainActivity.getString(R.string.survey_action_subtitle);

        StaticAction surveyAction = new StaticAction();
        surveyAction.type = ActionType.SURVEY;
        surveyAction.title = title;
        surveyAction.subtitle = subtitle;
        surveyAction.expandable = false;
        surveyAction.icon = R.drawable.ic_launcher_transp;

        staticActions.add(surveyAction);
    }

    public void killApp(SimpleHogBug fullObject, View v) {
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

            if (SamplingLibrary.killApp(mainActivity, raw, label)) {
                Log.d("debug", "disabling "+((label != null) ? label : "null"));
                killAppButton = (Button) v.findViewWithTag(fullObject.getAppName());
                killAppButton.setEnabled(false);
                killAppButton.setBackgroundResource(R.drawable.button_rounded_gray);
                killAppButton.setText(caratApplication.getString(R.string.stopped));
            }

        }
    }

    public boolean openAppDetails(SimpleHogBug fullObject) {
        return SamplingLibrary.openAppManager(mainActivity, fullObject.getAppName());
    }

    @Override
    public boolean onGroupClick(ExpandableListView parent, View v, int groupPosition, long id) {
        // Static cells
        if(groupPosition >= allReports.size()){
            int offset = groupPosition-allReports.size();
            StaticAction action = staticActions.get(offset);
            if(!action.expandable){
                handleStationaryAction(action);
                return true;
            }
        }

        // Normal cells
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
        if(groupPosition >= allReports.size()){
            int offset = groupPosition-allReports.size();
            StaticAction action = staticActions.get(offset);
            if(!action.expandable) return;
        }

        if (groupPosition != previousGroup){
            lv.collapseGroup(previousGroup);
        }
        previousGroup = groupPosition;
    }

    @Override
    public boolean onChildClick(ExpandableListView parent, View v, int groupPosition, int childPosition, long id) {
        return false;
    }
    
    private void handleStationaryAction(StaticAction action){
        switch(action.type){
            case SURVEY:
                // Construct form url and open in a custom webview fragment
                String surveyUrl = constructSurveyURL();
                CallbackWebViewFragment webView = createCallbackFragment(surveyUrl);
                mainActivity.setUpActionBar(R.string.survey_title, true);
                mainActivity.replaceFragment(webView, Constants.FRAGMENT_CB_WEBVIEW_TAG);
                break;
        }
    }

    private CallbackWebViewFragment createCallbackFragment(String surveyUrl){
        // Add a navigation callback to the fragment to catch form submission
        CallbackWebViewFragment fragment = CallbackWebViewFragment.getInstance(surveyUrl);
        fragment.setNavigationCallback(new CallbackWebViewFragment.NavigationCallback(){
            @Override
            public void onElementClicked() {
                mainActivity.runOnUiThread(new Runnable(){
                    @Override
                    public void run(){
                        String submitted = context.getString(R.string.submitted);
                        String thanks = context.getString(R.string.thank_you);
                        String message = submitted + ". " + thanks;
                        Toast.makeText(context, message, Toast.LENGTH_LONG).show();
                    }
                });
                mainActivity.onBackPressed();
            }
        });
        return fragment;
    }

    private String constructSurveyURL() {
        // These fields will be prefilled
        String surveyUrl = Constants.SURVEY_ROOT_URL;
        String uuid = SamplingLibrary.getUuid(mainActivity);
        String cc = SamplingLibrary.getCountryCode(context);
        Reports r = CaratApplication.getStorage().getReports();
        String os = SamplingLibrary.getOsVersion();
        String model = SamplingLibrary.getModel();

        // Format the url properly, %0A is a line break, + is a space
        if(uuid != null) surveyUrl += "Carat+ID:+"+uuid.replace(" ", "+")+"%0A";
        if(cc != null) surveyUrl += "Country:+"+cc.replace(" ", "+")+"%0A";
        if(r != null) surveyUrl += "JScore:+"+r.jScore+"%0A";
        if(os != null) surveyUrl += "OS+Version:+"+os.replace(" ", "+")+"%0A";
        if(model != null) surveyUrl += "Device+Model:+"+model.replace(" ", "+")+"%0A";

        // Strip last line break

        return surveyUrl;
    }

}
