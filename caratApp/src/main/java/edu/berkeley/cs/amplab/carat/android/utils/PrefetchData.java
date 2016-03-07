package edu.berkeley.cs.amplab.carat.android.utils;

import android.annotation.SuppressLint;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Build;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Field;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;

public class PrefetchData extends AsyncTask<Void, Void, Void> {

    // counts (general Carat statistics shown in the summary fragment)
    public int appWellbehaved = Constants.VALUE_NOT_AVAILABLE,
            appHogs = Constants.VALUE_NOT_AVAILABLE,
            appBugs = Constants.VALUE_NOT_AVAILABLE;

    public int mWellbehaved = Constants.VALUE_NOT_AVAILABLE,
            mHogs = Constants.VALUE_NOT_AVAILABLE,
            mBugs = Constants.VALUE_NOT_AVAILABLE;

    public int iosWellbehaved = Constants.VALUE_NOT_AVAILABLE,
            iosHogs = Constants.VALUE_NOT_AVAILABLE,
            iosBugs = Constants.VALUE_NOT_AVAILABLE;

    public int userHasBug = Constants.VALUE_NOT_AVAILABLE,
            userHasNoBugs = Constants.VALUE_NOT_AVAILABLE;

    private MainActivity a = null;

    private HashMap<String, Integer> androidMap;
    private HashMap<String, Integer> iosMap;
    private boolean parseAndroid;

    public PrefetchData(MainActivity a) {
        this.a = a;
    }

    String serverResponseJson = null;
    String serverResponseJsonDevices = null;
    private final String TAG = "PrefetchData";

    @Override
    protected Void doInBackground(Void... arg0) {
        // Log.d(TAG, "started doInBackground() method of the asyncTask");
        JsonParser jsonParser = new JsonParser();
        androidMap = new HashMap<>();
        iosMap = new HashMap<>();
        try {
            if (CaratApplication.isInternetAvailable()) {
                serverResponseJson = jsonParser
                        .getJSONFromUrl("http://carat.cs.helsinki.fi/statistics-data/stats.json");
                serverResponseJsonDevices = jsonParser.getJSONFromUrl("http://carat.cs.helsinki.fi/statistics-data/shares.json");
            }
        } catch (Exception e) {
        }

        if (serverResponseJson != null && serverResponseJson != "") {
            try {
                saveAppValues(new JSONObject(serverResponseJson).getJSONArray("apps"), 0);
                saveAppValues(new JSONObject(serverResponseJson).getJSONArray("android-apps"), 1);
                saveAppValues(new JSONObject(serverResponseJson).getJSONArray("ios-apps"), 2);
                saveAppValues(new JSONObject(serverResponseJson).getJSONArray("users"), 3);

                JSONObject tmp = new JSONObject(serverResponseJsonDevices).getJSONObject("All");
                parseAndroid = true;
                parseJson(tmp.getJSONObject("Android"));

                a.setAndroidDevices(sortByComparator(androidMap));
                parseAndroid = false;
                //parseJson(tmp.getJSONObject("iOS"));
                //a.setIosDevices(iosMap);

                if (CaratApplication.mPrefs != null) {
                    saveStatsToPref();
                } else {
                    // Log.e(TAG, "The shared preference is null (not loaded yet. "
                    //		+ "Check CaratApplication's new thread for loading the sharedPref)");
                }

            } catch (JSONException e) {
                // Log.e(TAG, e.getStackTrace().toString());
            }
        } else {
            // Log.d(TAG, "server response JSON is null.");
        }
        return null;
    }

    private void parseJson(JSONObject data) {

        if (data != null) {
            Iterator<String> it = data.keys();
            while (it.hasNext()) {
                String key = it.next();

                try {
                    if (data.get(key) instanceof JSONArray) {
                        JSONArray arry = data.getJSONArray(key);
                        int size = arry.length();
                        for (int i = 0; i < size; i++) {
                            parseJson(arry.getJSONObject(i));
                        }
                    } else if (data.get(key) instanceof JSONObject) {
                        parseJson(data.getJSONObject(key));
                    } else {
                        if (parseAndroid) {
                            if (androidMap.containsKey(key)) {
                                androidMap.put(key, androidMap.get(key) + Integer.parseInt(data.optString(key)));
                            } else {
                                androidMap.put(key, Integer.parseInt(data.optString(key)));
                            }
                        } /* else {
                            if (iosMap.containsKey(key)) {
                                iosMap.put(key, iosMap.get(key) + Integer.parseInt(data.optString(key)));
                            } else {
                                iosMap.put(key, Integer.parseInt(data.optString(key)));
                            }
                        } */
                    }
                } catch (Throwable e) {
                    e.printStackTrace();

                }
            }
        }
    }

    private void saveAppValues(JSONArray jsonArray, int which) {
        try {
            switch (which) {
                case 0:
                    setIntFieldsFromJson(jsonArray, 0, "appWellbehaved");
                    setIntFieldsFromJson(jsonArray, 1, "appHogs");
                    setIntFieldsFromJson(jsonArray, 2, "appBugs");
                    break;
                case 1:
                    setIntFieldsFromJson(jsonArray, 0, "mWellbehaved");
                    setIntFieldsFromJson(jsonArray, 1, "mHogs");
                    setIntFieldsFromJson(jsonArray, 2, "mBugs");
                    break;
                case 2:
                    setIntFieldsFromJson(jsonArray, 0, "iosWellbehaved");
                    setIntFieldsFromJson(jsonArray, 1, "iosHogs");
                    setIntFieldsFromJson(jsonArray, 2, "iosBugs");
                    break;
                case 3:
                    setIntFieldsFromJson(jsonArray, 0, "userHasBug");
                    setIntFieldsFromJson(jsonArray, 1, "userHasNoBugs");
                    break;
            }
        } catch (IllegalArgumentException e) {
            Log.e(TAG, "IllegalArgumentException in setFieldsFromJson()");
        } catch (IllegalAccessException e) {
            Log.e(TAG, "IllegalAccessException in setFieldsFromJson()");
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @SuppressLint("NewApi")
    private void saveStatsToPref() {
        SharedPreferences.Editor editor = CaratApplication.mPrefs.edit();
        // the returned values (from setIntFieldsFromJson()
        // might be -1 (Constants.VALUE_NOT_AVAILABLE). So
        // when we are reading the following pref values, we
        // should check that condition )
        editor.putInt(Constants.STATS_APP_WELLBEHAVED_COUNT_PREFERENCE_KEY, appWellbehaved);
        editor.putInt(Constants.STATS_APP_HOGS_COUNT_PREFERENCE_KEY, appHogs);
        editor.putInt(Constants.STATS_APP_BUGS_COUNT_PREFERENCE_KEY, appBugs);

        editor.putInt(Constants.STATS_WELLBEHAVED_COUNT_PREFERENCE_KEY, mWellbehaved);
        editor.putInt(Constants.STATS_HOGS_COUNT_PREFERENCE_KEY, mHogs);
        editor.putInt(Constants.STATS_BUGS_COUNT_PREFERENCE_KEY, mBugs);

        editor.putInt(Constants.STATS_IOS_WELLBEHAVED_COUNT_PREFERENCE_KEY, iosWellbehaved);
        editor.putInt(Constants.STATS_IOS_HOGS_COUNT_PREFERENCE_KEY, iosHogs);
        editor.putInt(Constants.STATS_IOS_BUGS_COUNT_PREFERENCE_KEY, iosBugs);

        editor.putInt(Constants.STATS_USER_BUGS_COUNT_PREFERENCE_KEY, userHasBug);
        editor.putInt(Constants.STATS_USER_NO_BUGS_COUNT_PREFERENCE_KEY, userHasNoBugs);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD) {
            editor.apply(); // async (runs in parallel
            // in a new shared thread (off the UI thread)
        } else {
            editor.commit();
        }
    }

    @Override
    protected void onPostExecute(Void result) {
        // Log.d(TAG, "started the onPostExecute() of the asyncTask");
        super.onPostExecute(result);
        // SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
        // sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
        // Log.d(TAG, "asyncTask.onPstExecute(). mWellbehaved=" + mWellbehaved);
        // TODO REFRESH SUMMARY FRAGMENT
        a.refreshCurrentFragment();
    }

    /**
     * Using Java reflections to set fields by passing their name to a method
     *
     * @param jsonArray the json array from which we want to extract different json objects
     * @param objIdx    the index of the object in the json array
     * @param fieldName the name of the field in the current NESTED class (PrefetchData)
     */
    private void setIntFieldsFromJson(JSONArray jsonArray, int objIdx, String fieldName)
            throws JSONException, IllegalArgumentException, IllegalAccessException {
        // Class<? extends PrefetchData> currentClass = this.getClass();
        Field field = null;
        int res = Constants.VALUE_NOT_AVAILABLE;

        try {
            // important: getField() can only get PUBLIC fields.
            // For private fields, use another method: getDeclaredField(fieldName)
            field = a.getClass().getField(fieldName);
        } catch (NoSuchFieldException e) {
            // Log.e(TAG, "NoSuchFieldException when trying to get a reference to the field: " + fieldName);
        }

        if (field != null) {
            JSONObject jsonObject = null;
            if (jsonArray != null) {
                jsonObject = jsonArray.getJSONObject(objIdx);
                if (jsonObject != null && jsonObject.getString("value") != null && jsonObject.getString("value") != "") {
                    res = Integer.parseInt(jsonObject.getString("value"));
                    field.set(a, res);
                } else {
                    // Log.e(TAG, "json object (server response) is null: jsonArray(" + objIdx + ")=null (or ='')");
                }
            }
        }
        // if an exception occurs, the value of the field would be -1 (Constants.VALUE_NOT_AVAILABLE)
    }

    private HashMap<String, Integer> sortByComparator(Map<String, Integer> unsortMap) {

        List<Map.Entry<String, Integer>> list = new LinkedList<Map.Entry<String, Integer>>(unsortMap.entrySet());

        Collections.sort(list, new Comparator<Map.Entry<String, Integer>>() {
            public int compare(Map.Entry<String, Integer> o1,
                               Map.Entry<String, Integer> o2) {
                return o2.getValue().compareTo(o1.getValue());
            }
        });

        HashMap<String, Integer> sortedMap = new LinkedHashMap<String, Integer>();
        for (Map.Entry<String, Integer> entry : list) {
            sortedMap.put(entry.getKey(), entry.getValue());
        }

        return sortedMap;
    }

}


