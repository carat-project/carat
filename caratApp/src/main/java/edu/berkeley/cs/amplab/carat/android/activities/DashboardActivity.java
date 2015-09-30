package edu.berkeley.cs.amplab.carat.android.activities;

import android.graphics.Color;
import android.support.v4.app.ActionBarDrawerToggle;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.ui.CircleDisplay;
import edu.berkeley.cs.amplab.carat.android.utils.Tracker;

public class DashboardActivity extends ActionBarActivity implements View.OnClickListener {

    public static final String ACTION_BUGS = "bugs", ACTION_HOGS = "hogs";

    // Key File
    private static final String FLURRY_KEYFILE = "flurry.properties";
    private static final boolean debug = false;

    private String fullVersion = null;
    private Tracker tracker = null;

    private ImageView bugButton;
    private ImageView hogButton;
    private ImageView globeButton;
    private ImageView actionsButton;
    private Button myDeviceButton;
    private TextView batteryText;
    private CircleDisplay cd;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dashboard);
        initViewRefs();
        generateJScoreCircle();
    }

    @Override
    protected void onResume() {
        super.onResume();
        setJScore();
        setBatteryLife();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_carat, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    private void initViewRefs() {
        bugButton = (ImageView) findViewById(R.id.bugs_button);
        hogButton = (ImageView) findViewById(R.id.hogs_button);
        globeButton = (ImageView) findViewById(R.id.globe_button);
        actionsButton = (ImageView) findViewById(R.id.actions_button);
        myDeviceButton = (Button) findViewById(R.id.my_device_button);
        batteryText = (TextView) findViewById(R.id.battery_value);
    }

    private void setJScore() {
        int jscore = CaratApplication.getJscore();

        if (jscore == -1 || jscore == 0)
            cd.setCustomText(new String[] {"N", "/", "A"});
        else
            cd.showValue((float) jscore, 99f, false);
    }

    private void setBatteryLife() {
        String batteryLife = CaratApplication.myDeviceData.getBatteryLife();
        Log.d("debug", "*** " + batteryLife);
        batteryText.setText(batteryLife);
    }

    private void generateJScoreCircle() {
        cd = (CircleDisplay) findViewById(R.id.jscore_progress_circle);
        cd.setValueWidthPercent(10f);
        cd.setTextSize(30f);
        cd.setColor(Color.rgb(97, 65, 11));
        cd.setDrawText(true);
        cd.setDrawInnerCircle(true);
        cd.setFormatDigits(0);
        cd.setTouchEnabled(true);
        cd.setUnit("");
        cd.setStepSize(1f);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.bugs_button:
                break;
            case R.id.hogs_button:
                break;
            case R.id.globe_button:
                break;
            case R.id.actions_button:
                break;
            case R.id.my_device_button:
                break;
            default:
                break;
        }
    }
}
