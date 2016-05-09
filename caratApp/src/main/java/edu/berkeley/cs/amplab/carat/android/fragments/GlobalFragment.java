package edu.berkeley.cs.amplab.carat.android.fragments;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Shader;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import java.util.HashMap;

import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.dialogs.BaseDialog;

/**
 * Created by Valto on 30.9.2015.
 * Refactored by Jonatan on 7.3.2015
 */
public class GlobalFragment extends Fragment implements Runnable, View.OnClickListener {

    private MainActivity mainActivity;
    private RelativeLayout mainFrame;
    private RelativeLayout loadingScreen;
    private ScrollView scrollContent;
    private boolean locker;
    private Thread drawingThread;

    private ImageView wellBehavedImage;
    private ImageView bugsImage;
    private ImageView hogsImage;
    private ImageView globalImage;
    private ImageView androidImage;
    private ImageView iOSImage;
    private ImageView userImage;

    private Button wellButton, bugsButton, hogsButton;

    private TextView deviceList;
    private TextView wellTitle, bugsTitle, hogsTitle;
    private TextView allText, androidText, iosText, userText;

    private BaseDialog dialog;

    private float wellBehavedValue, hogsValue, bugsValue;
    private float appHogsValue, appBugsValue;
    private float iosHogsValue, iosBugsValue;
    private float userBugsValue, userNoBugsValue;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.mainActivity = (MainActivity) activity;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        mainFrame = (RelativeLayout) inflater.inflate(R.layout.fragment_global, container, false);
        return mainFrame;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
    }

    @Override
    public void onResume() {
        super.onResume();
        mainActivity.setUpActionBar(R.string.global_results, true);
        locker = true;

        initViewRefs();
        initListeners();

        // Check if data is not yet available
        if(mainActivity.appWellbehaved != Constants.VALUE_NOT_AVAILABLE){
            this.refresh();
        }
    }


    public void refresh(){
        this.setValues();
        this.mainFrame.post(this);

        // Hide loading screen, show content
        scrollContent.setVisibility(View.VISIBLE);
        loadingScreen.setVisibility(View.INVISIBLE);
    }

    private void initViewRefs() {
        // Main content views
        loadingScreen = (RelativeLayout) mainFrame.findViewById(R.id.loading_screen);
        scrollContent = (ScrollView) mainFrame.findViewById(R.id.global_scrollview);

        // Percentage bars
        wellBehavedImage = (ImageView) mainFrame.findViewById(R.id.well_behaved_imageview);
        bugsImage = (ImageView) mainFrame.findViewById(R.id.bugs_imageview);
        hogsImage = (ImageView) mainFrame.findViewById(R.id.hogs_imageview);
        globalImage = (ImageView) mainFrame.findViewById(R.id.all_stats_imageview);
        androidImage = (ImageView) mainFrame.findViewById(R.id.android_stats_imageview);
        iOSImage = (ImageView) mainFrame.findViewById(R.id.ios_stats_imageview);
        userImage = (ImageView) mainFrame.findViewById(R.id.user_stats_imageview);

        // Statistics
        deviceList = (TextView) mainFrame.findViewById(R.id.device_list);

        // Titles
        wellTitle = (TextView) mainFrame.findViewById(R.id.well_behaved_title);
        bugsTitle = (TextView) mainFrame.findViewById(R.id.bugs_title);
        hogsTitle = (TextView) mainFrame.findViewById(R.id.hogs_title);

        // Buttons
        wellButton = (Button) mainFrame.findViewById(R.id.well_behaved_button);
        bugsButton = (Button) mainFrame.findViewById(R.id.bugs_button);
        hogsButton = (Button) mainFrame.findViewById(R.id.hogs_button);

        // Texts
        allText = (TextView) mainFrame.findViewById(R.id.all_general_text);
        androidText = (TextView) mainFrame.findViewById(R.id.android_general_text);
        iosText = (TextView) mainFrame.findViewById(R.id.ios_general_text);
        userText = (TextView) mainFrame.findViewById(R.id.user_general_text);
    }

    private void initListeners() {
        wellButton.setOnClickListener(this);
        bugsButton.setOnClickListener(this);
        hogsButton.setOnClickListener(this);
    }

    private void setValues() {
        HashMap<String, Integer> androidMap = mainActivity.getAndroidDevices();
        //HashMap<String, Integer> iosMap = mainActivity.getIosDevices();
        String androids = "";
        //String iOSs = "";
        int androidDeviceSum = 0;
        //int iosDeviceSum = 0;

        if (androidMap != null) {
            for (int i : androidMap.values()) {
                androidDeviceSum += i;
            }
            int limit = 0;
            for (String key : androidMap.keySet()) {
                androids += key + ": " + String.format("%.1f", (float)androidMap.get(key) / androidDeviceSum * 100) + "%" + "\n";
                limit++;
                if (limit == 8) {
                    break;
                }
            }
        }
        /*if (iosMap != null) {
            for (int i : iosMap.values()) {
                iosDeviceSum += i;
            }
            for (String key : iosMap.keySet()) {
                iOSs += key + ": " + String.format("%.2f", (float)iosMap.get(key) / iosDeviceSum * 100) + "%" + "\n";
            }
        } */

        deviceList.setText(androids);

        int sum = mainActivity.mWellbehaved + mainActivity.mBugs + mainActivity.mHogs;
        int appSum = mainActivity.appWellbehaved + mainActivity.appBugs + mainActivity.appHogs;
        int iosSum = mainActivity.iosWellbehaved + mainActivity.iosHogs + mainActivity.iosBugs;
        int userSum = mainActivity.userHasBug + mainActivity.userHasNoBugs;

        wellBehavedValue = (float)mainActivity.mWellbehaved / sum;
        bugsValue = (float)mainActivity.mBugs / sum;
        hogsValue = (float)mainActivity.mHogs / sum;

        appBugsValue = (float)mainActivity.appBugs / appSum;
        appHogsValue = (float)mainActivity.appHogs / appSum;

        iosBugsValue = (float)mainActivity.iosBugs / iosSum;
        iosHogsValue = (float)mainActivity.iosHogs / iosSum;

        userBugsValue = (float)mainActivity.userHasBug / userSum;

        String wellBehaved = String.format("%.0f", wellBehavedValue * 100);
        String bugs = String.format("%.0f", bugsValue * 100);
        String hogs = String.format("%.0f", hogsValue * 100);

        String appHogPercent = String.format("%.0f", appHogsValue * 100);
        String appBugPercent = String.format("%.0f", appBugsValue * 100);

        String iosHogPercent = String.format("%.0f", iosHogsValue * 100);
        String iosBugPercent = String.format("%.0f", iosBugsValue * 100);

        String userBugPercent = String.format("%.0f", userBugsValue * 100);

        wellTitle.setText(getString(R.string.well_behaved) + " " + wellBehaved + "%");
        bugsTitle.setText(getString(R.string.bugs_camel) + " " + bugs + "%");
        hogsTitle.setText(getString(R.string.hogs_camel) + " " + hogs + "%");

        allText.setText(getString(R.string.out_of)+ appSum + " " + getString(R.string.all_installed)
            + " " + appHogPercent + "% " + getString(R.string.hog_intensity) + " " + appBugPercent +
            "% " + getString(R.string.bug_intensity));

        androidText.setText(getString(R.string.out_of) + sum + " " + getString(R.string.android_installed)
                + " " + hogs + "% " + getString(R.string.hog_intensity) + " " + bugs +
                "% " + getString(R.string.bug_intensity));

        iosText.setText(getString(R.string.out_of) + iosSum + " " + getString(R.string.ios_installed)
                + " " + iosHogPercent + "% " + getString(R.string.hog_intensity) + " " + iosBugPercent +
                "% " + getString(R.string.bug_intensity));

        userText.setText(getString(R.string.out_of) + userSum + " " + getString(R.string.users)
                + " " + userBugPercent + "% " + getString(R.string.user_intensity));
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState){
        super.onViewCreated(view, savedInstanceState);
    }

    private void drawValues() {
        drawingThread = new Thread(this);
        drawingThread.start();
    }

    @Override
    public void run() {
        while (locker) {
            if(wellBehavedImage == null
                    || wellBehavedImage.getWidth() <= 0
                    || wellBehavedImage.getHeight() <= 0) continue;

            setPercentageBar(wellBehavedImage, 4);
            setPercentageBar(bugsImage, 5);
            setPercentageBar(hogsImage, 6);
            setPercentageBar(globalImage, 0);
            setPercentageBar(androidImage, 1);
            setPercentageBar(iOSImage, 2);
            setPercentageBar(userImage, 3);
            locker = false;
        }

        scrollContent.setVisibility(View.VISIBLE);
    }

    private void setPercentageBar(ImageView view, int id){
        Bitmap image = Bitmap.createBitmap(view.getWidth(), view.getHeight(), Bitmap.Config.RGB_565);
        Canvas canvas = new Canvas(image);
        draw(canvas, id);
        view.setImageBitmap(image);
    }

    private void draw(Canvas canvas, int which) {
        RectF r;
        Shader shader = new LinearGradient(0, 0, canvas.getWidth(), canvas.getHeight(),
                Color.argb(255, 243, 53, 53), Color.argb(255, 255, 198, 0), Shader.TileMode.CLAMP);
        Paint paint;
        switch (which) {
            case 0:
                r = new RectF(0, 0, canvas.getWidth() * (appBugsValue + appHogsValue), canvas.getHeight());
                canvas.drawColor(Color.argb(255, 180, 180, 180));
                paint = new Paint();
                paint.setShader(shader);
                canvas.drawRect(r, paint);
                break;
            case 1:
                r = new RectF(0, 0, canvas.getWidth() * (bugsValue + hogsValue), canvas.getHeight());
                canvas.drawColor(Color.argb(255, 180, 180, 180));
                paint = new Paint();
                paint.setShader(shader);
                canvas.drawRect(r, paint);
                break;
            case 2:
                r = new RectF(0, 0, canvas.getWidth() * (iosBugsValue + iosHogsValue), canvas.getHeight());
                canvas.drawColor(Color.argb(255, 180, 180, 180));
                paint = new Paint();
                paint.setShader(shader);
                canvas.drawRect(r, paint);
                break;
            case 3:
                r = new RectF(0, 0, canvas.getWidth() * userBugsValue, canvas.getHeight());
                canvas.drawColor(Color.argb(255, 180, 180, 180));
                paint = new Paint();
                paint.setShader(shader);
                canvas.drawRect(r, paint);
                break;
            case 4:
                r = new RectF(0, 0, canvas.getWidth() * wellBehavedValue * 1.04f, canvas.getHeight());
                canvas.drawColor(Color.argb(255, 180, 180, 180));
                paint = new Paint();
                paint.setARGB(255, 75, 200, 127);
                canvas.drawRect(r, paint);
                break;
            case 5:
                r = new RectF(0, 0, canvas.getWidth() * bugsValue * 1.04f, canvas.getHeight());
                canvas.drawColor(Color.argb(255, 180, 180, 180));
                paint = new Paint();
                paint.setARGB(255, 75, 200, 127);
                canvas.drawRect(r, paint);
                break;
            case 6:
                r = new RectF(0, 0, canvas.getWidth() * hogsValue * 1.04f, canvas.getHeight());
                canvas.drawColor(Color.argb(255, 180, 180, 180));
                paint = new Paint();
                paint.setARGB(255, 75, 200, 127);
                canvas.drawRect(r, paint);
                break;
            default:
                break;
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.well_behaved_button:
                dialog = new BaseDialog(getContext(),
                        getString(R.string.well_behaved_caps),
                        getString(R.string.well_behaved_explanation),
                        null);
                dialog.showDialog();
                break;
            case R.id.bugs_button:
                dialog = new BaseDialog(getContext(),
                        getString(R.string.bugs),
                        getString(R.string.tutorial_fragment_bugs_message),
                        null);
                dialog.showDialog();
                break;
            case R.id.hogs_button:
                dialog = new BaseDialog(getContext(),
                        getString(R.string.hogs),
                        getString(R.string.tutorial_fragment_hogs_message),
                        null);
                dialog.showDialog();
                break;
            default:
                break;
        }
    }
}
