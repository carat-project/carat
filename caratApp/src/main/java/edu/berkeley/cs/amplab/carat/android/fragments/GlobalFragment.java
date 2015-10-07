package edu.berkeley.cs.amplab.carat.android.fragments;

import android.app.Activity;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Shader;
import android.media.Image;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.activities.DashboardActivity;
import edu.berkeley.cs.amplab.carat.android.ui.CircleDisplay;

/**
 * Created by Valto on 30.9.2015.
 */
public class GlobalFragment extends Fragment implements Runnable {

    private DashboardActivity dashboardActivity;
    private ScrollView mainFrame;
    private boolean locker = true;

    private SurfaceHolder globalSurfaceHolder;
    private SurfaceHolder androidSurfaceHolder;
    private SurfaceHolder iOSSurfaceHolder;
    private SurfaceHolder userSurfaceHolder;
    private Thread drawingThread;

    private SurfaceView globalSurface;
    private SurfaceView androidSurface;
    private SurfaceView iOSSurface;
    private SurfaceView userSurface;

    private ImageView globalStats;
    private ImageView androidStats;
    private ImageView iOSStats;
    private ImageView userStats;

    private TextView deviceList;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        this.dashboardActivity = (DashboardActivity) activity;
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
        dashboardActivity.setUpActionBar(R.string.global_results, true);
        initViewRefs();
        initListeners();
        setValues();
        drawValues();
    }


    private void initViewRefs() {
        globalSurface = (SurfaceView) mainFrame.findViewById(R.id.all_stats_surface);
        androidSurface = (SurfaceView) mainFrame.findViewById(R.id.android_stats_surface);
        iOSSurface = (SurfaceView) mainFrame.findViewById(R.id.ios_stats_surface);
        userSurface = (SurfaceView) mainFrame.findViewById(R.id.user_stats_surface);
        globalSurfaceHolder = globalSurface.getHolder();
        androidSurfaceHolder = androidSurface.getHolder();
        iOSSurfaceHolder = iOSSurface.getHolder();
        userSurfaceHolder = userSurface.getHolder();
        globalStats = (ImageView) mainFrame.findViewById(R.id.all_stats);
        androidStats = (ImageView) mainFrame.findViewById(R.id.android_stats);
        iOSStats = (ImageView) mainFrame.findViewById(R.id.ios_stats);
        userStats = (ImageView) mainFrame.findViewById(R.id.user_stats);
        deviceList = (TextView) mainFrame.findViewById(R.id.device_list);

    }

    private void initListeners() {

    }

    private void setValues() {
        //TODO GET GLOBAL VALUES
        deviceList.setText("Samsung Galaxy S2: 17%\nGalaxy Nexus: 3%\nNexus 7: 3%\n" +
                "DROIDX: 2%\nSamsung Galaxy Note II: 2%\nNexus S: 1%\nHTC One X: 1%\n" +
                "Samsung Droid Charge: 1%\nOther: 66%");
    }

    private void drawValues() {
        drawingThread = new Thread(this);
        drawingThread.start();
    }

    @Override
    public void run() {
        while (locker) {
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
        switch (which) {
            case 0:
                r = new RectF(0, 0, canvas.getWidth() * (float)Math.random(), canvas.getHeight());
                break;
            case 1:
                r = new RectF(0, 0, canvas.getWidth() * (float)Math.random(), canvas.getHeight());
                break;
            case 2:
                r = new RectF(0, 0, canvas.getWidth() * (float)Math.random(), canvas.getHeight());
                break;
            case 3:
                r = new RectF(0, 0, canvas.getWidth() * (float)Math.random(), canvas.getHeight());
                break;
            default:
                r = new RectF(0, 0, 0, 0);
                break;
        }
        Shader shader = new LinearGradient(0, 0, canvas.getWidth(), canvas.getHeight(),
                Color.argb(255, 243, 53, 53), Color.argb(255, 255, 198, 0), Shader.TileMode.CLAMP);
        canvas.drawColor(Color.argb(255, 180, 180, 180));
        Paint paint = new Paint();
        paint.setShader(shader);
        canvas.drawRect(r, paint);
    }

}
