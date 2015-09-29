package edu.berkeley.cs.amplab.carat.android.activities;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.animation.DecelerateInterpolator;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.nineoldandroids.animation.ObjectAnimator;

import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.ui.CircleDisplay;

public class DashboardActivity extends ActionBarActivity implements View.OnClickListener {

    private ImageView bugButton;
    private ImageView hogButton;
    private ImageView globeButton;
    private ImageView actionsButton;
    private Button myDeviceButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dashboard);
        initButtons();
        generateJScoreCircle();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_dashboard, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    private void initButtons() {
        bugButton = (ImageView) findViewById(R.id.bugs_button);
        hogButton = (ImageView) findViewById(R.id.hogs_button);
        globeButton = (ImageView) findViewById(R.id.globe_button);
        actionsButton = (ImageView) findViewById(R.id.actions_button);
        myDeviceButton = (Button) findViewById(R.id.my_device_button);
    }

    private void generateJScoreCircle() {
        CircleDisplay cd = (CircleDisplay) findViewById(R.id.jscore_progress_circle);
        cd.setValueWidthPercent(10f);
        cd.setTextSize(16f);
        cd.setColor(R.color.orange);
        cd.setDrawText(true);
        cd.setDrawInnerCircle(true);
        cd.setFormatDigits(0);
        cd.setTouchEnabled(true);
        cd.setUnit("");
        cd.setStepSize(1f);
        // cd.setCustomText(...); // sets a custom array of text
        cd.showValue(69f, 99f, false);
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
