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
import java.util.Collections;
import java.util.HashMap;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.dialogs.BaseDialog;
import edu.berkeley.cs.amplab.carat.android.fragments.AboutFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.CallbackWebViewFragment;
import edu.berkeley.cs.amplab.carat.android.fragments.DeviceFragment;
import edu.berkeley.cs.amplab.carat.android.model_classes.StaticAction;
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

    private static class ActionViewHolder {
        private ImageView icon;
        private ImageView collapseIcon;
        private TextView title;
        private TextView subtitle;
    }

    private static class ExpandedViewHolder extends ActionViewHolder {
        private TextView batteryImpact;
        private TextView samplesText;
        private TextView samplesAmount;
        private Button killAppButton;
        private Button appManagerButton;
        private TextView appCategory;
        private TextView reportType;
        private TextView informationLink;
    }

    private static class StaticViewHolder extends ActionViewHolder {
        private TextView expandedTitle;
        private TextView expandedText;
    }

    private Context context;
    private LayoutInflater inflater;
    private CaratApplication caratApplication;
    private ArrayList<SimpleHogBug> appActions = new ArrayList<>();
    private ArrayList<StaticAction> staticActions = new ArrayList<>();
    private ExpandableListView lv;
    private MainActivity mainActivity;
    private BaseDialog dialog;

    private int previousGroup = -1;
    private final int NORMAL_ACTION = 0;
    private final int STATIC_ACTION = 1;

    public ActionsExpandListAdapter(MainActivity mainActivity, ExpandableListView lv,
                                    CaratApplication caratApplication, ArrayList<SimpleHogBug> appActions, Context context) {

        this.context = context;
        this.caratApplication = caratApplication;
        this.lv = lv;
        this.lv.setOnGroupClickListener(this);
        this.lv.setOnGroupExpandListener(this);
        this.lv.setOnChildClickListener(this);
        this.mainActivity = mainActivity;
        this.appActions = appActions;
        Collections.sort(this.appActions);

        this.staticActions = CaratApplication.getStaticActions();

        inflater = LayoutInflater.from(caratApplication);
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
    public View getChildView(int groupPosition, int childPosition, boolean isLastChild,
                             View convertView, ViewGroup parent) {

        // Create and inflate child views
        int type = getChildType(groupPosition, childPosition);
        if (convertView == null || getType(convertView.getTag()) != type) {
            switch(type){
                case NORMAL_ACTION:
                    convertView = inflater.inflate(R.layout.actions_list_child_item, null);
                    ExpandedViewHolder expandedHolder = getExpandedViewHolder(convertView);
                    convertView.setTag(expandedHolder);
                    break;
                case STATIC_ACTION:
                    int offset = groupPosition - appActions.size();
                    StaticAction item = staticActions.get(offset);
                    if(!item.isExpandable()) return convertView;
                    convertView = inflater.inflate(R.layout.actions_list_static_child, null);
                    StaticViewHolder staticHolder = getStaticViewHolder(convertView);
                    convertView.setTag(staticHolder);
                    break;
                default:
                    return convertView;
            }
        }

        // Set child values
        switch(type) {
            case NORMAL_ACTION:
                SimpleHogBug app = appActions.get(groupPosition);
                setViewsInChild(convertView, app);
                break;
            case STATIC_ACTION:
                groupPosition -= appActions.size();
                StaticAction action = staticActions.get(groupPosition);
                if(action.isExpandable()){
                    setStaticViewInChild(convertView, action);
                }
                break;
        }
        return convertView;
    }

    private int getType(Object tag){
        if(tag.getClass().isInstance(ExpandedViewHolder.class)) return NORMAL_ACTION;
        if(tag.getClass().isInstance(StaticViewHolder.class)) return STATIC_ACTION;
        return -1;
    }

    private ActionViewHolder getActionViewHolder(View v){
        ActionViewHolder holder = new ActionViewHolder();
        holder.icon = (ImageView)v.findViewById(R.id.process_icon);
        holder.collapseIcon = (ImageView) v.findViewById(R.id.collapse_icon);
        holder.title = (TextView)v.findViewById(R.id.process_name);
        holder.subtitle = (TextView) v.findViewById(R.id.process_improvement);
        return holder;
    }
    private ExpandedViewHolder getExpandedViewHolder(View v){
        ExpandedViewHolder holder = new ExpandedViewHolder();
        holder.batteryImpact = (TextView) v.findViewById(R.id.impact_text);
        holder.samplesText = (TextView) v.findViewById(R.id.samples_title);
        holder.samplesAmount = (TextView) v.findViewById(R.id.samples_amount);
        holder.killAppButton = (Button) v.findViewById(R.id.stop_app_button);
        holder.appManagerButton = (Button) v.findViewById(R.id.app_manager_button);
        holder.appCategory = (TextView) v.findViewById(R.id.app_category);
        holder.informationLink = (TextView) v.findViewById(R.id.action_information);
        holder.reportType = (TextView) v.findViewById(R.id.hogbug_text);
        return holder;
    }

    private StaticViewHolder getStaticViewHolder(View v){
        StaticViewHolder holder = new StaticViewHolder();
        holder.expandedText = (TextView) v.findViewById(R.id.action_expanded_text);
        holder.expandedTitle = (TextView) v.findViewById(R.id.action_expanded_title);
        return holder;
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        return 1;
    }

    @Override
    public Object getGroup(int groupPosition) {
        return appActions.get(groupPosition);
    }

    @Override
    public int getGroupCount() {
        return appActions.size() + staticActions.size();
    }

    @Override
    public int getChildType(int groupPosition, int childPosition){
        return (groupPosition >= appActions.size()) ? STATIC_ACTION : NORMAL_ACTION;
    }

    @Override
    public int getChildTypeCount(){
        return 2;
    }

    @Override
    public long getGroupId(int groupPosition) {
        return groupPosition;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded,
                             View convertView, ViewGroup parent) {
        if (convertView == null) {
            convertView = inflater.inflate(R.layout.bug_hog_list_header, null);
            ActionViewHolder holder = getActionViewHolder(convertView);
            convertView.setTag(holder);
        }

        if (appActions == null || groupPosition < 0) return convertView;
        if(groupPosition >= appActions.size()){
            groupPosition -= appActions.size();
            StaticAction staticAction = staticActions.get(groupPosition);
            if(staticAction == null) return convertView;
            setStaticViews(convertView, staticAction);
        } else {
            SimpleHogBug item = appActions.get(groupPosition);
            if (item == null) return convertView;
            setItemViews(convertView, item);
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
        final ExpandedViewHolder holder = (ExpandedViewHolder)v.getTag();
        holder.batteryImpact.setText(item.getBenefitText());
        holder.samplesText.setText(R.string.samples);
        holder.samplesAmount.setText(String.valueOf(item.getSamples()));
        holder.killAppButton.setTag(item.getAppName());
        holder.appCategory.setText(SamplingLibrary.getAppPriority(context, item.getAppName()));

        // Currently these need to be set each time, refactor?
        holder.killAppButton.setBackgroundResource(R.drawable.button_rounded_orange);
        holder.killAppButton.setText(context.getString(R.string.stop_app_title));

        holder.killAppButton.setEnabled(true);
        holder.killAppButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                killApp(item, v, holder);
            }
        });

        holder.appManagerButton.setEnabled(true);
        holder.appManagerButton.setTag(item.getAppName()+"_manager");
        holder.appManagerButton.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                openAppDetails(item);
            }
        });

        holder.informationLink.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                dialog = new BaseDialog(context,
                        context.getString(R.string.actions_info_title),
                        context.getString(R.string.actions_expanded_info),
                        null);
                dialog.showDialog();
            }
        });

        holder.reportType.setText(item.isBug() ? context.getString(R.string.bug) : context.getString(R.string.hog));
        holder.reportType.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v){
                AboutFragment aboutFragment = new AboutFragment();
                aboutFragment.openGroup(item.isBug() ? 2 : 3);
                mainActivity.replaceFragment(aboutFragment, Constants.FRAGMENT_ABOUT_TAG);
            }
        });
    }

    private void setItemViews(View v, SimpleHogBug item) {
        ActionViewHolder holder = (ActionViewHolder) v.getTag();

        holder.icon.setImageDrawable(CaratApplication.iconForApp(caratApplication.getApplicationContext(),
                item.getAppName()));
        holder.title.setText(CaratApplication.labelForApp(caratApplication.getApplicationContext(),
                item.getAppName()));

        holder.subtitle.setText(item.getBenefitText());
    }

    private void setStaticViews(View v, StaticAction action){
        ActionViewHolder holder = (ActionViewHolder) v.getTag();

        holder.icon.setImageResource(action.getIcon());
        holder.title.setText(action.getTitle());
        holder.subtitle.setText(action.getSubtitle());

        if(!action.isExpandable()){
            holder.collapseIcon.setImageResource(R.drawable.collapse_right);
        }
    }

    private void setStaticViewInChild(View v, StaticAction action){
        StaticViewHolder holder = (StaticViewHolder)v.getTag();
        String text = caratApplication.getString(action.getExpandedText());
        String title = caratApplication.getString(action.getExpandedTitle());
        holder.expandedTitle.setText(title);
        holder.expandedText.setText(text);
    }

    public void killApp(SimpleHogBug fullObject, View v, ExpandedViewHolder holder) {
        final String raw = fullObject.getAppName();
        final PackageInfo pak = SamplingLibrary.getPackageInfo(mainActivity, raw);
        final String label = CaratApplication.labelForApp(mainActivity, raw);

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
            options.put("benefit", holder.samplesAmount.getText().toString().replace('\u00B1', '+'));
            ClickTracking.track(uuId, "killbutton", options, caratApplication);
        }

        if (SamplingLibrary.killApp(mainActivity, raw, label)) {
            Log.d("debug", "disabling "+((label != null) ? label : "null"));
            holder.killAppButton.setEnabled(false);
            holder.killAppButton.setBackgroundResource(R.drawable.button_rounded_gray);
            holder.killAppButton.setText(caratApplication.getString(R.string.stopped));
        }

        CaratApplication.refreshStaticActionCount();
    }

    public boolean openAppDetails(SimpleHogBug fullObject) {
        return SamplingLibrary.openAppManager(mainActivity, fullObject.getAppName());
    }

    @Override
    public boolean onGroupClick(ExpandableListView parent, View v, int groupPosition, long id) {
        // Static actions might have a different action
        if(groupPosition >= appActions.size()){
            int offset = groupPosition - appActions.size();
            StaticAction action = staticActions.get(offset);
            if(!action.isExpandable()){
                handleStationaryAction(action);
                return true;
            }
        }

        // Expandable cells
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
        if(groupPosition >= appActions.size()){
            int offset = groupPosition - appActions.size();
            StaticAction action = staticActions.get(offset);
            if(!action.isExpandable()) return;
        }
        if (groupPosition != previousGroup){
            lv.collapseGroup(previousGroup);
            View v = lv.getChildAt(previousGroup);
            if(v != null){
                ImageView collapseIcon = (ImageView) v.findViewById(R.id.collapse_icon);
                if(collapseIcon != null){
                    collapseIcon.setImageResource(R.drawable.collapse_down);
                }
            }
        }
        previousGroup = groupPosition;
    }

    @Override
    public boolean onChildClick(ExpandableListView parent, View v, int groupPosition, int childPosition, long id) {
        return false;
    }
    
    private void handleStationaryAction(StaticAction action){
        switch(action.getType()){
            case SURVEY:
                // Construct form url and open in a custom webview fragment
                String surveyUrl = constructSurveyURL();
                CallbackWebViewFragment webView = createCallbackFragment(surveyUrl);
                mainActivity.replaceFragment(webView, Constants.FRAGMENT_CB_WEBVIEW_TAG);
                mainActivity.setUpActionBar(R.string.survey_title, true);
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
                        Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
                    }
                });
                mainActivity.onBackPressed();
            }
        });
        return fragment;
    }

    private String constructSurveyURL() {
        // These fields will be prefilled
        String surveyUrl = CaratApplication.getStorage().getQuestionnaireUrl();
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
