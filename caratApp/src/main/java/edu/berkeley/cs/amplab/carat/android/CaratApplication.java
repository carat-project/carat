package edu.berkeley.cs.amplab.carat.android;

import java.net.InetAddress;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;

import android.app.ActivityManager.RunningAppProcessInfo;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.Resources;
import android.graphics.drawable.Drawable;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.preference.PreferenceManager;
import android.util.Log;
import android.util.SparseArray;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;

import edu.berkeley.cs.amplab.carat.android.model_classes.MyDeviceData;
import edu.berkeley.cs.amplab.carat.android.model_classes.StaticAction;
import edu.berkeley.cs.amplab.carat.android.protocol.CommunicationManager;
import edu.berkeley.cs.amplab.carat.android.protocol.SampleSender;
import edu.berkeley.cs.amplab.carat.android.sampling.Sampler;
import edu.berkeley.cs.amplab.carat.android.sampling.SamplingLibrary;
import edu.berkeley.cs.amplab.carat.android.storage.CaratDataStorage;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;
import edu.berkeley.cs.amplab.carat.thrift.Reports;

import static edu.berkeley.cs.amplab.carat.android.model_classes.StaticAction.ActionType;

/**
 * Application class for Carat Android App. Place App-global static constants
 * and methods here.
 *
 * @author Eemil Lagerspetz
 */
public class CaratApplication extends Application {

    private static CaratApplication mInstance;
    // Used for logging
    private static final String TAG = "CaratApp";

    public static Context mAppContext = null;
    public static SharedPreferences mPrefs = null;

    // Used to map importances to human readable strings for sending samples to
    // the server, and showing them in the process list.
    private static final SparseArray<String> importanceToString = new SparseArray<String>();

    {
        importanceToString.put(RunningAppProcessInfo.IMPORTANCE_EMPTY, "Not running");
        importanceToString.put(RunningAppProcessInfo.IMPORTANCE_BACKGROUND, "Background process");
        importanceToString.put(RunningAppProcessInfo.IMPORTANCE_SERVICE, "Service");
        importanceToString.put(RunningAppProcessInfo.IMPORTANCE_VISIBLE, "Visible task");
        importanceToString.put(RunningAppProcessInfo.IMPORTANCE_FOREGROUND, "Foreground app");

        importanceToString.put(Constants.IMPORTANCE_PERCEPTIBLE, "Perceptible task");
        importanceToString.put(Constants.IMPORTANCE_SUGGESTION, "Suggestion");

        mInstance = this;
    }

    public static Context getContext() {
        return mInstance;
    }

    // NOTE: This needs to be initialized before CommunicationManager.
    private static CaratDataStorage storage = null;
    // NOTE: The CommunicationManager requires a working instance of
    // CaratDataStorage.
    public CommunicationManager commManager = null;

    // Activity pointers so that all activity UIs can be updated with a callback
    // to CaratApplication
    static MainActivity main = null;
    // The Sampler samples the battery level when it changes.
    private static Sampler sampler = null;

    public static MyDeviceData myDeviceData = new MyDeviceData();

    // used to check if Internet is available
    private static ConnectivityManager mConnectivityManager = null;

    // Application overrides:

    @Override
    public void onLowMemory() {
        super.onLowMemory();
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
    }

    /**
     * 1. Create CaratDataStorage and read reports from disk. Does not seem too
     * slow.
     * <p/>
     * 2. Take a sample in a new thread so that the GUI has fresh data.
     * <p/>
     * 3. Create CommunicationManager for communicating with the Carat server.
     * <p/>
     * 4. Communicate with the server to fetch new reports if current ones are
     * outdated, and to send old stored and the new just-recorded sample. See
     * MainActivity for this task.
     */
    @Override
    public void onCreate() {

        // Create global configuration and initialize ImageLoader
        ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(this).build();
        ImageLoader.getInstance().init(config);

        mConnectivityManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);

        // use a private preference file (created and used only by CaratApp).
        // don't use PreferenceManager.getDefaultSharedPreferences (it might cause problem in different OS versions).
        new Thread() {
            public void run() {
                mPrefs = CaratApplication.this.getSharedPreferences(Constants.PREFERENCE_FILE_NAME, Context.MODE_PRIVATE);
            }
        }.start();

        setStorage(new CaratDataStorage(this));
        setReportData(); // Show initial data asap

        new Thread() {
            private IntentFilter intentFilter;

            public void run() {
                /*
				 * Schedule recurring sampling event: (currently not used)
				 */
				/*
				 * SharedPreferences p = PreferenceManager
				 * 			.getDefaultSharedPreferences(CaratApplication.this); 
				 * boolean firstRun = p.getBoolean(PREFERENCE_SAMPLE_FIRST_RUN, true);
				 */
                // do this always for now for debugging purposes:
                // if (firstRun) {
                // What to start when the event fires (this is unused at the
                // moment)
				/*
				 * Intent intent = new Intent(getApplicationContext(), Sampler.class); 
				 * intent.setAction(ACTION_CARAT_SAMPLE); 
				 * // In reality, you would want to have a static variable for the 
				 * // request code instead of 192837 
				 * PendingIntent sender =
				 * 			PendingIntent.getBroadcast( CaratApplication.this, 192837,
				 * 							intent, PendingIntent.FLAG_UPDATE_CURRENT); 
				 * // Cancel if this has been set up. 
				 * // Do not use timer at all any more.
				 *  sender.cancel();
				 */

                // Let sampling happen on battery change
                intentFilter = new IntentFilter();
                intentFilter.addAction(Intent.ACTION_BATTERY_CHANGED);
				/*
				 * intentFilter.addAction(Intent.ACTION_PACKAGE_REMOVED);
				 * intentFilter.addDataScheme("package"); // add addDataScheme
				 */
                sampler = Sampler.getInstance();
                // Unregister, since Carat may have been started multiple times
                // since reboot
                try {
                    unregisterReceiver(sampler);
                } catch (IllegalArgumentException e) {
                }
                registerReceiver(sampler, intentFilter);

                // register for screen_on and screen-off as well

                // for the debugging purpose, let's comment out these actions
                // TODO: re-enable
                // intentFilter.addAction(Intent.ACTION_SCREEN_ON);
                // registerReceiver(sampler, intentFilter);
                // intentFilter.addAction(Intent.ACTION_SCREEN_OFF);
                // registerReceiver(sampler, intentFilter);
            }
        }.start();

        new Thread() {
            public void run() {
                commManager = new CommunicationManager(CaratApplication.this);
            }
        }.start();

        super.onCreate();
    }

    // Utility methods

    /**
     * Converts <code>importance</code> to a human readable string.
     *
     * @param importance the importance from Android process info.
     * @return a human readable String describing the importance.
     */
    public static String importanceString(int importance) {
        String s = importanceToString.get(importance);
        if (s == null || s.length() == 0) {
            Log.e("Importance not found:", "" + importance);
            s = "Unknown";
        }
        return s;
    }

    /**
     * Here is where you define static actions
     * @return List of static actions
     */
    public static ArrayList<StaticAction> getStaticActions(){
            ArrayList<StaticAction> actions = new ArrayList<>();

            // Participate in Carat survey
            String surveyUrl = CaratApplication.getStorage().getQuestionnaireUrl();
            if(surveyUrl != null && surveyUrl.contains("http")){
                actions.add(new StaticAction(ActionType.SURVEY,
                        R.string.survey_action_title,
                        R.string.survey_action_subtitle));
            }

            // Help Carat collect data
            if(getActionsAmount() == 0){
                actions.add(new StaticAction(ActionType.COLLECT,
                        R.string.helpcarat, R.string.helpcarat_subtitle)
                        .makeExpandable(R.string.helpcarat_expanded_title,
                                R.string.no_actions_message));
            }
            return actions;
    }

    public static void refreshStaticActionCount(){
        main.setStaticActionsAmount(getStaticActions().size());
    }

    public static int getActionsAmount(){
        int actionsAmount=0;
        if(CaratApplication.getStorage() != null){
            SimpleHogBug[] report = CaratApplication.getStorage().getBugReport();
            actionsAmount += filterByRunning(report).size();
            report = CaratApplication.getStorage().getHogReport();
            actionsAmount += filterByRunning(report).size();
        }
        return actionsAmount;
    }

    public static ArrayList<SimpleHogBug> filterByRunning(SimpleHogBug[] packages){
        if(packages == null || packages.length == 0) return new ArrayList<>();

        ArrayList<SimpleHogBug> report = filterByVisibility(packages);
;        HashMap<String, SimpleHogBug> running = new HashMap<>();
        if(report == null) return new ArrayList<>();
        for(SimpleHogBug s : report){
            if(SamplingLibrary.isRunning(getContext(), s.getAppName())){
                SimpleHogBug duplicate = running.get(s.getAppName());
                if(duplicate != null
                        && s.getAppPriority() == duplicate.getAppPriority()
                        && s.getBenefit() == duplicate.getBenefit()){
                    continue;
                }
                running.put(s.getAppName(), s);
            }
        }
        return new ArrayList<>(running.values());
    }

    public static ArrayList<SimpleHogBug> filterByVisibility(SimpleHogBug[] reports){
        ArrayList<SimpleHogBug> result = new ArrayList<>();
        if(reports == null) return result;
        ArrayList<SimpleHogBug> temp = new ArrayList<>(Arrays.asList(reports));

        for (SimpleHogBug app : temp) {
            String packageName = app.getAppName();
            if(packageName == null) continue;
            if(!CaratApplication.isPackageInstalled(packageName)) continue;
            // Enable this when we can reliably detect killable apps
            //if(CaratApplication.isPackageSystemApp(packageName)) continue;
            if(packageName.equalsIgnoreCase(Constants.CARAT_PACKAGE_NAME)) continue;;
            if(packageName.equalsIgnoreCase(Constants.CARAT_OLD)) continue;
            result.add(app);
        }

        return result;
    }

    public static String translatedPriority(String importanceString) {
        if (main != null) {
            if (importanceString == null)
                return main.getString(R.string.priorityDefault);
            if (importanceString.equals("Not running")) {
                return main.getString(R.string.prioritynotrunning);
            } else if (importanceString.equals("Background process")) {
                return main.getString(R.string.prioritybackground);
            } else if (importanceString.equals("Service")) {
                return main.getString(R.string.priorityservice);
            } else if (importanceString.equals("Visible task")) {
                return main.getString(R.string.priorityvisible);
            } else if (importanceString.equals("Foreground app")) {
                return main.getString(R.string.priorityforeground);
            } else if (importanceString.equals("Perceptible task")) {
                return main.getString(R.string.priorityperceptible);
            } else if (importanceString.equals("Suggestion")) {
                return main.getString(R.string.prioritysuggestion);
            } else
                return main.getString(R.string.priorityDefault);
        } else if(importanceString == null) {
            return "Not running";
        }

        return importanceString;
    }

    /**
     * Return a Drawable that contains an app icon for the named app. If not
     * found, return the Drawable for the Carat icon.
     *
     * @param appName the application name
     * @return the Drawable for the application's icon
     */
    public static Drawable iconForApp(Context context, String appName) {
        try {
            return context.getPackageManager().getApplicationIcon(appName);
        } catch (NameNotFoundException e) {
            return context.getResources().getDrawable(R.drawable.process_icon);
        }
    }

    /**
     * Return a human readable application label for the named app. If not
     * found, return appName.
     *
     * @param appName the application name
     * @return the human readable application label
     */
    public static String labelForApp(Context context, String appName) {
        if (appName == null)
            return "Unknown";
        try {
            ApplicationInfo i = context.getPackageManager().getApplicationInfo(appName, 0);
            if (i != null)
                return context.getPackageManager().getApplicationLabel(i).toString();
            else
                return appName;
        } catch (NameNotFoundException e) {
            return appName;
        }
    }

    /**
     * Searches system for a matching package and tells if it's installed.
     * This considers apps that are disabled uninstalled.
     *
     * @param packageName Package name
     * @return True if package is found, otherwise false
     */
    public static boolean isPackageInstalled(String packageName){
        PackageManager packageManager = getContext().getPackageManager();
        ApplicationInfo applicationInfo = null;
        try {
            // Throws an exception when there is no such package installed
            applicationInfo = packageManager.getApplicationInfo(packageName, 0);
            return applicationInfo.enabled;
        } catch (NameNotFoundException e) {
            return false;
        }
    }

    /**
     * Compares package flags and signature with those of a system app.
     *
     * @param packageName Package name
     * @return True if package is a system app
     */
    public static boolean isPackageSystemApp(String packageName){
        if(packageName == null) return false;

        PackageManager packageManager = getContext().getPackageManager();
        try{
            ApplicationInfo info = packageManager.getApplicationInfo(packageName, 0);
            if(info != null){
                return (isSystemPackage(info) && isSystemSigned(packageName));
            }
            return false;
        } catch(Exception e){
            return false;
        }
    }

    private static boolean isSystemPackage(ApplicationInfo info){
        return (info.flags & ApplicationInfo.FLAG_SYSTEM) != 0
                || (info.flags & ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0;
    }

    private static boolean isSystemSigned(String packageName){
        try {

            PackageManager pm = getContext().getPackageManager();
            PackageInfo pi = pm.getPackageInfo(packageName, PackageManager.GET_SIGNATURES);
            PackageInfo sys = pm.getPackageInfo("android", PackageManager.GET_SIGNATURES);
            if(pi==null || pi.signatures == null) return false;
            if(sys==null || sys.signatures == null) return false;
            return (sys.signatures[0].equals(pi.signatures[0]));
        } catch (Exception e) {
            // Package not found
            return false;
        }
    }

    public static int getJscore() {
        final Reports reports = getStorage().getReports();
        int jscore = 0;
        if (reports != null) {
            jscore = ((int) (reports.getJScore() * 100));
        }
        return jscore;
    }

    /**
     * Return titles from the drawer items array.
     *
     * @return titles from the drawer items array.
     */
    public static String[] getTitles() {
        Resources res = getContext().getResources();
        return res.getStringArray(R.array.drawer_items);
    }

    public static void setActionInProgress() {
        if (main != null) {
            main.runOnUiThread(new Runnable() {
                public void run() {
                    // Updating done
                    //main.setTitleUpdating(getTitles()[2]);
                    main.setProgress(0);
                    main.setProgressBarVisibility(true);
                    main.setProgressBarIndeterminateVisibility(true);
                }
            });
        }
    }

    public static void setActionProgress(final int progress, final String what, final boolean fail) {
        if (main != null) {
            main.runOnUiThread(new Runnable() {
                public void run() {
					if (fail)
						main.setTitleUpdatingFailed(what);
					else
						main.setTitleUpdating(what);
					//main.setProgress(progress * 100);
                }
            });
        }
    }

    public static void setSampleProgress(final String what){
        if (main != null) {
            main.runOnUiThread(new Runnable() {
                public void run() {
                    main.setSampleProgress(what);
                }
            });
        }
    }

    public static void setActionFinished() {
        if (main != null) {
            main.runOnUiThread(new Runnable() {
                public void run() {
                    // Updating done
                    //main.setTitleNormal();
                    main.setProgress(100);
                    main.setProgressBarVisibility(false);
                    main.setProgressBarIndeterminateVisibility(false);
                }
            });
        }
    }

    protected static void setMain(MainActivity mainActivity) {
        main = mainActivity;
    }

    public static String getRegisteredUuid() {
        return Constants.REGISTERED_UUID;
    }


    public void refreshUi() {
        boolean connecting = false;
        boolean newData = false;
        Log.d("debug", "*** Start refresh");
        Context co = getApplicationContext();
        // TODO: using a shared preferences object might cause problem in different OS versions. replace with a private one. see MainActivity.AsyncTask.doInBackground().
        final SharedPreferences p = PreferenceManager.getDefaultSharedPreferences(co);
        final boolean useWifiOnly = p.getBoolean(getString(R.string.wifi_only_key), false);
        if (Constants.DEBUG)
            Log.d(TAG, "Wi-Fi only: " + useWifiOnly);
        String networkStatus = SamplingLibrary.getNetworkStatus(getApplicationContext());
        String networkType = SamplingLibrary.getNetworkType(co);

        boolean connected = (!useWifiOnly && networkStatus == SamplingLibrary.NETWORKSTATUS_CONNECTED)
                || networkType.equals("WIFI");

        long freshness = getStorage().getFreshness();
        long elapsed = System.currentTimeMillis() - freshness;

        // Check freshness here to avoid unnecessary load on older devices
        if (connected && commManager != null && elapsed > Constants.FRESHNESS_TIMEOUT) {
            // Show we are updating...
            main.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    main.setProgressCircle(true);
                }
            });
            CaratApplication.setActionInProgress();
            try {
                commManager.refreshAllReports();
            } catch (Throwable th) {
                // Any sort of malformed response, too short string,
                // etc...
                Log.w(TAG, "Failed to refresh reports: " + th + Constants.MSG_TRY_AGAIN);
                th.printStackTrace();
            }
            connecting = false;
            CaratApplication.setActionProgress(90, getString(R.string.finishing), false);
            main.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    main.setProgressCircle(false);
                }
            });
        } else if (networkStatus.equals(SamplingLibrary.NETWORKSTATUS_CONNECTING)) {
            Log.w(TAG, "Network status: " + networkStatus + ", trying again in 10s.");
            connecting = true;
        }

        if (connecting) {
            // wait for WiFi to come up
            main.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    main.setProgressCircle(true);
                }
            });
            try {
                Thread.sleep(Constants.COMMS_WIFI_WAIT);
            } catch (InterruptedException e1) {
                // ignore
            }

            // Show we are updating...
            CaratApplication.setActionInProgress();
            try {
                commManager.refreshAllReports();
            } catch (Throwable th) {
                // Any sort of malformed response, too short string,
                // etc...
                Log.w(TAG, "Failed to refresh reports: " + th + Constants.MSG_TRY_AGAIN);
                th.printStackTrace();
            }

            setActionProgress(90, getString(R.string.finishing), false);
            main.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    main.setProgressCircle(false);
                }
            });
        }

        //CaratApplication.setActionFinished();
        setReportData();
        CaratApplication.refreshStaticActionCount();
        main.runOnUiThread(new Runnable() {
            @Override
            public void run() {main.refreshCurrentFragment();
            }
        });
        //CaratApplication.setActionFinished();

        SampleSender.sendSamples(CaratApplication.this);
        main.runOnUiThread(new Runnable() {
            @Override
            public void run() {main.refreshDashboardProgress();
            }
        });

        Log.d("debug", "*** End refresh");
    }

    public boolean isSendingSamples(){
        return SampleSender.isSendingSamples();
    }

    // Checks if communication manager is busy
    public boolean isUpdatingReports(){
        if(commManager != null){
            return commManager.isRefreshingReports();
        }
        return false;
    }


    public static boolean isInternetAvailable2() {
        try {
            InetAddress ipAddr = InetAddress.getByName("google.com"); //You can replace it with your name
            if (ipAddr.equals("")) {
                return false;
            } else {
                return true;
            }

        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Checks whether WiFi or mobile data is enabled
     *
     * @return true of false
     */
    public static boolean isInternetAvailable() {
        boolean haveConnectedWifi = false;
        boolean haveConnectedMobile = false;


        NetworkInfo[] netInfo = mConnectivityManager.getAllNetworkInfo();
        for (NetworkInfo ni : netInfo) {
            if (ni.getTypeName().equalsIgnoreCase("WIFI"))
                if (ni.isConnected())
                    haveConnectedWifi = true;
            if (ni.getTypeName().equalsIgnoreCase("MOBILE"))
                if (ni.isConnected())
                    haveConnectedMobile = true;
        }
        return haveConnectedWifi || haveConnectedMobile;
    }


    public static void setReportData() {
        final Reports r = getStorage().getReports();
        if (Constants.DEBUG)
            Log.d(TAG, "Got reports.");
        long freshness = CaratApplication.getStorage().getFreshness();
        long l = System.currentTimeMillis() - freshness;
        final long h = l / 3600000;
        final long min = (l - h * 3600000) / 60000;
        double bl = 0;
        double error = 0;

        if (r != null) {
            if (Constants.DEBUG)
                Log.d(TAG, "r (reports) not null.");
            // Try exact battery life
            if (r.jScoreWith != null) {
                // Log.d(TAG, "jscoreWith not null.");
                double exp = r.jScoreWith.expectedValue;
                if (exp > 0.0) {
                    bl = 100 / exp;
                    error = 100 / (exp + r.jScoreWith.error);
                } else if (r.getModel() != null) {
                    exp = r.getModel().expectedValue;
                    if (Constants.DEBUG)
                        Log.d(TAG, "Model expected value: " + exp);
                    if (exp > 0.0) {
                        bl = 100 / exp;
                        error = 100 / (exp + r.getModel().error);
                    }
                }
                // If not possible, try model battery life
            }
        }


        // Only take the error part
        error = bl - error;

        int blh = (int) (bl / 3600);
        bl -= blh * 3600;
        int blmin = (int) (bl / 60);

        int errorH = 0;
        int errorMin = 0;
        if (error > 7200) {
            errorH = (int) (error / 3600);
            error -= errorH * 3600;
        }

        errorMin = (int) (error / 60);


        String blS;
        if(blh == 0 && blmin == 0){
            blS = getContext().getString(R.string.calibrating);
        } else {
            blS =  blh + "h " + blmin + "m \u00B1 " + (errorH > 0 ? errorH + "h " : "") + errorMin + " m";
        }

		/*
		 * we removed direct manipulation of MyDevice fragment,
		 * and moved the data pertaining to this fragment to a class field, called myDeviceData.
		 * In the onResume() method of MyDeviceFragment, we fetch this data and show (see setViewData())
		 * The reason for this movement is that we migrated from tabs to fragments.
		 * We cannot change a fragment's view while it's not in the foreground
		 * (fragments get replaced by a fragment transaction:
		 * the parent activity which hosts a frame-layout
		 * (a placeholder for fragment's layout), replaces the frame-layout with
		 * the new fragment's layout)
		 */

        SharedPreferences p = PreferenceManager
                .getDefaultSharedPreferences(getContext());
        String caratId = p.getString(Constants.REGISTERED_UUID, "0");

        myDeviceData.setAllFields(freshness, h, min, caratId, blS);
    }

    /**
     * @return the storage
     */
    public static CaratDataStorage getStorage() {
        if (storage == null)
            storage = new CaratDataStorage(CaratApplication.getContext());
        return storage;
    }

    /**
     * @param storage the storage to set
     */
    public static void setStorage(CaratDataStorage storage) {
        CaratApplication.storage = storage;
    }
}
