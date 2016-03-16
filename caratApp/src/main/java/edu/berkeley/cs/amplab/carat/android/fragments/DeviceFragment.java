package edu.berkeley.cs.amplab.carat.android.fragments;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.dialogs.BaseDialog;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.android.views.CircleDisplay;

/**
 * Created by Valto on 30.9.2015.
 */
public class DeviceFragment extends Fragment implements View.OnClickListener, Runnable {

    private MainActivity mainActivity;
    private RelativeLayout mainFrame;
    private CircleDisplay cd;

    private ImageView memoryUsedBar;
    private ImageView memoryActiveBar;
    private ImageView cpuUsageBar;

    private Button memoryUsedButton;
    private Button memoryActiveButton;
    private Button cpuUsageButton;
    private Button processListButton;

    private TextView deviceModel;
    private TextView osVersion;
    private TextView caratID;
    private TextView batteryLife;
    private TextView whatIsJScore;

    private boolean locker;
    private float memoryUsedConverted = 0;
    private float memoryActiveConverted = 0;
    private float cpuUsageConverted = 0;
    private BaseDialog dialog;


    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.mainActivity = (MainActivity) activity;
        Log.d("debug", "*** : " + "ONATTACH");
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        mainFrame = (RelativeLayout) inflater.inflate(R.layout.fragment_device, container, false);
        Log.d("debug", "*** : " + "ONCREATEVIEW");
        return mainFrame;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        Log.d("debug", "*** : " + "ONACTIVITYCREATED");
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.d("debug", "*** : " + "ONRESUME");
        mainActivity.setUpActionBar(R.string.my_device, true);
        locker = true;
        initViewRefs();
        generateJScoreCircle();
        initListeners();
        setValues();

        mainFrame.post(this);
    }

    private void initViewRefs() {
        cd = (CircleDisplay) mainFrame.findViewById(R.id.jscore_progress_circle);
        memoryUsedBar = (ImageView) mainFrame.findViewById(R.id.memory_used_bar);
        memoryActiveBar = (ImageView) mainFrame.findViewById(R.id.memory_active_bar);
        cpuUsageBar = (ImageView) mainFrame.findViewById(R.id.cpu_usage_bar);

        caratID = (TextView) mainFrame.findViewById(R.id.carat_id_value);
        deviceModel = (TextView) mainFrame.findViewById(R.id.device_model_value);
        osVersion = (TextView) mainFrame.findViewById(R.id.os_version_value);
        whatIsJScore = (TextView) mainFrame.findViewById(R.id.what_are_jscore_numbers);

        memoryUsedButton = (Button) mainFrame.findViewById(R.id.memory_used_info_button);
        memoryActiveButton = (Button) mainFrame.findViewById(R.id.memory_active_button);
        cpuUsageButton = (Button) mainFrame.findViewById(R.id.cpu_usage_button);
        batteryLife = (TextView) mainFrame.findViewById(R.id.battery_value);
        processListButton = (Button) mainFrame.findViewById(R.id.process_list_button);

    }

    private void initListeners() {
        cd.setOnClickListener(this);
        memoryUsedButton.setOnClickListener(this);
        memoryActiveButton.setOnClickListener(this);
        cpuUsageButton.setOnClickListener(this);
        processListButton.setOnClickListener(this);
        whatIsJScore.setOnClickListener(this);
    }


    private void generateJScoreCircle() {
        cd.setValueWidthPercent(10f);
        cd.setTextSize(40f);
        cd.setColor(Color.argb(255, 247, 167, 27));
        cd.setDrawText(true);
        cd.setDrawInnerCircle(true);
        cd.setFormatDigits(0);
        cd.setTouchEnabled(false);
        cd.setUnit("");
        cd.setStepSize(1f);
    }

    private void setValues() {
        if (mainActivity.getJScore() == -1 || mainActivity.getJScore() == 0) {
            cd.setCustomText(new String[]{"N/A"});
        } else {
            cd.showValue((float) mainActivity.getJScore(), 99f, false);
        }

        osVersion.setText(SamplingLibrary.getOsVersion());
        deviceModel.setText(SamplingLibrary.getModel());
        caratID.setText(CaratApplication.myDeviceData.getCaratId());
        batteryLife.setText(CaratApplication.myDeviceData.getBatteryLife());

        setMemoryValues();

    }

    private void setMemoryValues() {
        int[] totalAndUsed = SamplingLibrary.readMeminfo();
        memoryUsedConverted = 1 - ((float) totalAndUsed[0] / totalAndUsed[1]);
        if (totalAndUsed.length > 2) {
            memoryActiveConverted = (float) totalAndUsed[2] / (totalAndUsed[3] + totalAndUsed[2]);
        }

        cpuUsageConverted = mainActivity.getCpuValue();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.process_list_button:
                ProcessListFragment processListFragment = new ProcessListFragment();
                mainActivity.replaceFragment(processListFragment, Constants.FRAGMENT_PROCESS_LIST);
                break;
            case R.id.jscore_progress_circle:
                dialog = new BaseDialog(getContext(),
                        getString(R.string.jscore_dialog_title),
                        getString(R.string.jscore_explanation),
                        "jscoreinfo");
                dialog.showDialog();
                break;
            case R.id.memory_used_info_button:
                dialog = new BaseDialog(getContext(),
                        getString(R.string.memory_used_title),
                        getString(R.string.memory_explanation),
                        "memoryinfo");
                dialog.showDialog();
                break;
            case R.id.memory_active_button:
                dialog = new BaseDialog(getContext(),
                        getString(R.string.memory_active_title),
                        getString(R.string.memory_explanation),
                        "memoryinfo");
                dialog.showDialog();
                break;
            case R.id.cpu_usage_button:
                dialog = new BaseDialog(getContext(),
                        getString(R.string.cpu_usage_title),
                        getString(R.string.cpu_usage_explanation),
                        null);
                dialog.showDialog();
                break;
            case R.id.what_are_jscore_numbers:
                dialog = new BaseDialog(getContext(),
                        getString(R.string.jscore_dialog_title),
                        getString(R.string.jscore_explanation),
                        "jscoreinfo");
                dialog.showDialog();
                break;
            default:
                break;
        }
    }

    @Override
    public void run() {
        while (locker) {
            if(memoryUsedBar == null
                    || memoryUsedBar.getWidth() <= 0
                    || memoryUsedBar.getHeight() <= 0) continue;
            setPercentageBar(memoryUsedBar, 0);
            setPercentageBar(memoryActiveBar, 1);
            setPercentageBar(cpuUsageBar, 2);
            locker = false;
        }
    }

    private void draw(Canvas canvas, int which) {
        RectF r;
        switch (which) {
            case 0:
                r = new RectF(0, 0, memoryUsedConverted * canvas.getWidth(), canvas.getHeight());
                break;
            case 1:
                r = new RectF(0, 0, memoryActiveConverted * canvas.getWidth(), canvas.getHeight());
                break;
            case 2:
                r = new RectF(0, 0, cpuUsageConverted * canvas.getWidth(), canvas.getHeight());
                break;
            default:
                r = new RectF(0, 0, 0, 0);
                break;
        }
        canvas.drawColor(Color.argb(255, 180, 180, 180));
        Paint paint = new Paint();
        paint.setARGB(255, 75, 200, 127);
        canvas.drawRect(r, paint);
    }

    private void setPercentageBar(ImageView view, int id) {
        Bitmap image = Bitmap.createBitmap(view.getWidth(), view.getHeight(), Bitmap.Config.RGB_565);
        Canvas canvas = new Canvas(image);
        draw(canvas, id);
        view.setImageBitmap(image);
    }
}
