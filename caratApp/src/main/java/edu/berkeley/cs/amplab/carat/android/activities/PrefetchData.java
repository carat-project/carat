package edu.berkeley.cs.amplab.carat.android.activities;

import android.annotation.SuppressLint;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Build;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Field;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.utils.JsonParser;

public class PrefetchData extends AsyncTask<Void, Void, Void> {

    // counts (general Carat statistics shown in the summary fragment)
    public int mWellbehaved = Constants.VALUE_NOT_AVAILABLE,
            mHogs = Constants.VALUE_NOT_AVAILABLE,
            mBugs = Constants.VALUE_NOT_AVAILABLE;

    private DashboardActivity a = null;

    public PrefetchData(DashboardActivity a) {
        this.a = a;
    }

    String serverResponseJson = null;
    private final String TAG = "PrefetchData";

    @Override
    protected Void doInBackground(Void... arg0) {
        // Log.d(TAG, "started doInBackground() method of the asyncTask");
        JsonParser jsonParser = new JsonParser();
        try {
            if (CaratApplication.isInternetAvailable()) {
                serverResponseJson = jsonParser
                        .getJSONFromUrl("http://carat.cs.helsinki.fi/statistics-data/stats.json");
            }
        } catch (Exception e) {
        }

        if (serverResponseJson != null && serverResponseJson != "") {
            try {
                JSONArray jsonArray = new JSONObject(serverResponseJson).getJSONArray("android-apps");
                // Using Java reflections to set fields by passing their name to a method
                try {
                    setIntFieldsFromJson(jsonArray, 0, "mWellbehaved");
                    setIntFieldsFromJson(jsonArray, 1, "mHogs");
                    setIntFieldsFromJson(jsonArray, 2, "mBugs");

                    if (CaratApplication.mPrefs != null) {
                        saveStatsToPref();
                    } else {
                        // Log.e(TAG, "The shared preference is null (not loaded yet. "
                        //		+ "Check CaratApplication's new thread for loading the sharedPref)");
                    }

                    // Log.i(TAG, "received JSON: " + "mBugs: " + mWellbehaved
                    //		+ ", mHogs: " + mHogs + ", mBugs: " + mBugs);
                } catch (IllegalArgumentException e) {
                    Log.e(TAG, "IllegalArgumentException in setFieldsFromJson()");
                } catch (IllegalAccessException e) {
                    Log.e(TAG, "IllegalAccessException in setFieldsFromJson()");
                }
            } catch (JSONException e) {
                // Log.e(TAG, e.getStackTrace().toString());
            }
        } else {
            // Log.d(TAG, "server response JSON is null.");
        }
        return null;
    }

    @SuppressLint("NewApi")
    private void saveStatsToPref() {
        SharedPreferences.Editor editor = CaratApplication.mPrefs.edit();
        // the returned values (from setIntFieldsFromJson()
        // might be -1 (Constants.VALUE_NOT_AVAILABLE). So
        // when we are reading the following pref values, we
        // should check that condition )
        editor.putInt(Constants.STATS_WELLBEHAVED_COUNT_PREFERENCE_KEY, mWellbehaved);
        editor.putInt(Constants.STATS_HOGS_COUNT_PREFERENCE_KEY, mHogs);
        editor.putInt(Constants.STATS_BUGS_COUNT_PREFERENCE_KEY, mBugs);

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
        //refreshSummaryFragment();
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
}
