package edu.berkeley.cs.amplab.carat.android.fragments;

import android.app.Activity;
import android.content.DialogInterface;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Shader;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.ScrollView;
import android.widget.TextView;

import java.sql.BatchUpdateException;

import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.dialogs.BaseDialog;

/**
 * Created by Valto on 30.9.2015.
 */
public class GlobalFragment extends Fragment implements Runnable, View.OnClickListener {

    private MainActivity mainActivity;
    private ScrollView mainFrame;
    private boolean locker;

    private SurfaceHolder wellBehavecSurfaceHolder;
    private SurfaceHolder bugsSurfaceHolder;
    private SurfaceHolder hogsSurfaceHolder;
    private SurfaceHolder globalSurfaceHolder;
    private SurfaceHolder androidSurfaceHolder;
    private SurfaceHolder iOSSurfaceHolder;
    private SurfaceHolder userSurfaceHolder;
    private Thread drawingThread;

    private SurfaceView wellBehavedSurface;
    private SurfaceView bugsSurface;
    private SurfaceView hogsSurface;
    private SurfaceView globalSurface;
    private SurfaceView androidSurface;
    private SurfaceView iOSSurface;
    private SurfaceView userSurface;

    private ImageView globalStats;
    private ImageView androidStats;
    private ImageView iOSStats;
    private ImageView userStats;

    private Button wellButton, bugsButton, hogsButton;

    private TextView deviceList;
    private TextView wellTitle, bugsTitle, hogsTitle;

    private BaseDialog dialog;

    private float wellBehavedValue, hogsValue, bugsValue;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.mainActivity = (MainActivity) activity;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        mainFrame = (ScrollView) inflater.inflate(R.layout.fragment_global, container, false);
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
        setValues();
        drawValues();
    }


    private void initViewRefs() {
        wellBehavedSurface = (SurfaceView) mainFrame.findViewById(R.id.well_behaved_surface);
        bugsSurface = (SurfaceView) mainFrame.findViewById(R.id.bugs_surface);
        hogsSurface = (SurfaceView) mainFrame.findViewById(R.id.hogs_surface);

        globalSurface = (SurfaceView) mainFrame.findViewById(R.id.all_stats_surface);
        androidSurface = (SurfaceView) mainFrame.findViewById(R.id.android_stats_surface);
        iOSSurface = (SurfaceView) mainFrame.findViewById(R.id.ios_stats_surface);
        userSurface = (SurfaceView) mainFrame.findViewById(R.id.user_stats_surface);
        wellBehavecSurfaceHolder = wellBehavedSurface.getHolder();
        bugsSurfaceHolder = bugsSurface.getHolder();
        hogsSurfaceHolder = hogsSurface.getHolder();
        globalSurfaceHolder = globalSurface.getHolder();
        androidSurfaceHolder = androidSurface.getHolder();
        iOSSurfaceHolder = iOSSurface.getHolder();
        userSurfaceHolder = userSurface.getHolder();
        globalStats = (ImageView) mainFrame.findViewById(R.id.all_stats);
        androidStats = (ImageView) mainFrame.findViewById(R.id.android_stats);
        iOSStats = (ImageView) mainFrame.findViewById(R.id.ios_stats);
        userStats = (ImageView) mainFrame.findViewById(R.id.user_stats);
        deviceList = (TextView) mainFrame.findViewById(R.id.device_list);

        wellTitle = (TextView) mainFrame.findViewById(R.id.well_behaved_title);
        bugsTitle = (TextView) mainFrame.findViewById(R.id.bugs_title);
        hogsTitle = (TextView) mainFrame.findViewById(R.id.hogs_title);

        wellButton = (Button) mainFrame.findViewById(R.id.well_behaved_button);
        bugsButton = (Button) mainFrame.findViewById(R.id.bugs_button);
        hogsButton = (Button) mainFrame.findViewById(R.id.hogs_button);

    }

    private void initListeners() {
        wellButton.setOnClickListener(this);
        bugsButton.setOnClickListener(this);
        hogsButton.setOnClickListener(this);
    }

    private void setValues() {
        deviceList.setText("Samsung Galaxy S2: 17%\nGalaxy Nexus: 3%\nNexus 7: 3%\n" +
                "DROIDX: 2%\nSamsung Galaxy Note II: 2%\nNexus S: 1%\nHTC One X: 1%\n" +
                "Samsung Droid Charge: 1%\nOther: 66%");
        int sum = mainActivity.mWellbehaved + mainActivity.mBugs + mainActivity.mHogs;
        wellBehavedValue = (float)mainActivity.mWellbehaved / sum;
        bugsValue = (float)mainActivity.mBugs / sum;
        hogsValue = (float)mainActivity.mHogs / sum;
        String wellBehaved = String.format("%.0f", wellBehavedValue * 100);
        String bugs = String.format("%.0f", bugsValue * 100);
        String hogs = String.format("%.0f", hogsValue * 100);

        wellTitle.setText(getString(R.string.well_behaved) + " " + wellBehaved + "%");
        bugsTitle.setText(getString(R.string.bugs_camel) + " " + bugs + "%");
        hogsTitle.setText(getString(R.string.hogs_camel) + " " + hogs + "%");

    }

    private void drawValues() {
        drawingThread = new Thread(this);
        drawingThread.start();
    }

    @Override
    public void run() {
        while (locker) {
            if (!wellBehavecSurfaceHolder.getSurface().isValid()) {
                continue;
            }
            Canvas c4 = wellBehavecSurfaceHolder.lockCanvas();
            draw(c4, 4);
            wellBehavecSurfaceHolder.unlockCanvasAndPost(c4);

            if (!bugsSurfaceHolder.getSurface().isValid()) {
                continue;
            }
            Canvas c5 = bugsSurfaceHolder.lockCanvas();
            draw(c5, 5);
            bugsSurfaceHolder.unlockCanvasAndPost(c5);

            if (!hogsSurfaceHolder.getSurface().isValid()) {
                continue;
            }
            Canvas c6 = hogsSurfaceHolder.lockCanvas();
            draw(c6, 6);
            hogsSurfaceHolder.unlockCanvasAndPost(c6);

            if (!globalSurfaceHolder.getSurface().isValid()) {
                continue;
            }
            Canvas c = globalSurfaceHolder.lockCanvas();
            draw(c, 0);
            globalSurfaceHolder.unlockCanvasAndPost(c);

            if (!androidSurfaceHolder.getSurface().isValid()) {
                continue;
            }
            Canvas c1 = androidSurfaceHolder.lockCanvas();
            draw(c1, 1);
            androidSurfaceHolder.unlockCanvasAndPost(c1);

            if (!iOSSurfaceHolder.getSurface().isValid()) {
                continue;
            }
            Canvas c2 = iOSSurfaceHolder.lockCanvas();
            draw(c2, 2);
            iOSSurfaceHolder.unlockCanvasAndPost(c2);

            if (!userSurfaceHolder.getSurface().isValid()) {
                continue;
            }
            Canvas c3 = userSurfaceHolder.lockCanvas();
            draw(c3, 3);
            userSurfaceHolder.unlockCanvasAndPost(c3);
            locker = false;
        }
    }

    private void draw(Canvas canvas, int which) {
        RectF r;
        Shader shader = new LinearGradient(0, 0, canvas.getWidth(), canvas.getHeight(),
                Color.argb(255, 243, 53, 53), Color.argb(255, 255, 198, 0), Shader.TileMode.CLAMP);
        Paint paint;
        switch (which) {
            case 0:
                r = new RectF(0, 0, canvas.getWidth() * (float) Math.random(), canvas.getHeight());
                canvas.drawColor(Color.argb(255, 180, 180, 180));
                paint = new Paint();
                paint.setShader(shader);
                canvas.drawRect(r, paint);
                break;
            case 1:
                r = new RectF(0, 0, canvas.getWidth() * (float) Math.random(), canvas.getHeight());
                canvas.drawColor(Color.argb(255, 180, 180, 180));
                paint = new Paint();
                paint.setShader(shader);
                canvas.drawRect(r, paint);
                break;
            case 2:
                r = new RectF(0, 0, canvas.getWidth() * (float) Math.random(), canvas.getHeight());
                canvas.drawColor(Color.argb(255, 180, 180, 180));
                paint = new Paint();
                paint.setShader(shader);
                canvas.drawRect(r, paint);
                break;
            case 3:
                r = new RectF(0, 0, canvas.getWidth() * (float) Math.random(), canvas.getHeight());
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
                        getString(R.string.cpu_usage_explanation));
                dialog.showDialog();
                break;
            case R.id.bugs_button:
                dialog = new BaseDialog(getContext(),
                        getString(R.string.bugs),
                        getString(R.string.cpu_usage_explanation));
                dialog.showDialog();
                break;
            case R.id.hogs_button:
                dialog = new BaseDialog(getContext(),
                        getString(R.string.hogs),
                        getString(R.string.cpu_usage_explanation));
                dialog.showDialog();
                break;
            default:
                break;
        }
    }
}
