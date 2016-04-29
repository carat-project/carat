package edu.berkeley.cs.amplab.carat.android.protocol;

import android.os.AsyncTask;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.storage.CaratDataStorage;
import edu.berkeley.cs.amplab.carat.android.storage.HogStat;
import edu.berkeley.cs.amplab.carat.android.utils.JsonParser;

/**
 * Created by Jonatan Hamberg on 28.4.2016.
 */
public class AsyncStats extends AsyncTask<Void, Void, Void> {

    private CaratDataStorage storage;
    private CaratApplication application;
    private String date;
    private ArrayList<HogStat> hogStats;
    public AsyncStats(MainActivity mainActivity){
        this.application = (CaratApplication)mainActivity.getApplication();
        this.storage = application.getStorage();
        this.hogStats = new ArrayList<>();
    }

    @Override
    protected Void doInBackground(Void... params) {
        if(storage == null) return null;

        // Load cache as a fallback
        hogStats = new ArrayList<>(storage.getHogStats());

        // Check not more than once in an hour to prevent a flood of requests.
        long freshness = storage.getHogStatsFreshness();
        if(System.currentTimeMillis() - freshness > Constants.FRESHNESS_TIMEOUT_HOGSTATS
                || hogStats.isEmpty()){
            date = getLatestStatsDate();
            if(shouldUpdate()){
                storage.writeHogStatsDate(date);
                hogStats = getHogStats();

                // Save new data, update freshness and let other views know
                // about the updated stats so they can be refreshed.
                if(hogStats != null && hogStats.size() > 0){
                    storage.writeHogStats(hogStats);
                    storage.writeHogStatsFreshness();
                }
            } else {
                Log.d("debug", "Update not needed or possible");
            }
        } else {
            Log.d("debug", "Stored statistics are fresh enough, skipping update");
        }
        return null;
    }

    public boolean shouldUpdate(){
        String previous = storage.getHogStatsDate();

        // When the date is unavailable we might still have previous stats
        // available without updating, however in the case of no stored data
        // we need to check if a previous timestamp is available for fetching
        // at least some old data for the user.
        if(date == null){
            if(!hogStats.isEmpty() && (previous != null)){
                date = previous;
                return true;
            }
            return false;
        } else {
            // Always update when there is no record of a previous download.
            // If we have updated previously, check the date to see if the
            // data would actually be fresh.
            return previous == null
                    || !date.equalsIgnoreCase(previous)
                    || hogStats.isEmpty();
        }
    }

    public void proceed(){

    }

    public String getLatestStatsDate(){
        String url = "http://carat.cs.helsinki.fi/statistics-data/apps/data.json";
        String jsonData = JsonParser.getJSONFromUrl(url);
        if(jsonData == null || jsonData.isEmpty()) return null;
        try{
            JSONArray dataArray = new JSONArray(jsonData);
            if(dataArray.length() == 0) return null;

            // Iterate through platforms in case the order changes at some
            // point. Currently android is always first in the list.
            for(int i=0; i<dataArray.length(); i++){
                JSONObject platform = dataArray.getJSONObject(i);
                if(platform == null || platform.length() == 0) continue;

                // Find our platform, which is Android and attempt to get
                // the "days" array, making sure the data is available
                if("android".equalsIgnoreCase(platform.getString("name"))){
                    // These are the days, the time is now
                    JSONArray days = platform.getJSONArray("days");
                    if(days != null && days.length() > 0){
                        String latest = days.getString(days.length()-1);
                        Log.d("debug", "Successfully downloaded stats date from server: "+latest);
                        return latest;
                    }
                }
            }
        } catch(Exception e){
            if(e.getLocalizedMessage() != null){
                Log.d("debug", "Error when checking data.json", e);
            }
        }
        return null;
    }

    private ArrayList<HogStat> getHogStats(){
        String url = "http://carat.cs.helsinki.fi/statistics-data/apps/" + date + "-android.json";
        String jsonData = JsonParser.getJSONFromUrl(url);
        ArrayList<HogStat> result = new ArrayList<>();
        if(jsonData == null || jsonData.isEmpty()) return null;
        try {
            JSONArray dataArray = new JSONArray(jsonData);
            if(dataArray.length() == 0) return null;
            Log.d("debug", "Successfully downloaded hog statistics from server");
            for(int i=0; i<dataArray.length(); i++){
                JSONObject app = dataArray.getJSONObject(i);
                if(app == null || app.length() == 0) continue;
                HogStat hogStat = convert(app);
                if(hogStat != null){
                    result.add(hogStat);
                }
            }
        } catch(Exception e){
            if(e.getLocalizedMessage() != null){
                Log.d("debug", "Error checking hog statistics", e);
            }
        }
        return result;
    }

    private HogStat convert(JSONObject app){
        // Discard application if its format is inadequate or malformed.
        // Note that json operations throw an exception when a field does
        // not exist or has an invalid type.
        try{
            String name = app.getString("name");
            long killBenefit = app.getLong("killBenefit");
            long users = app.getLong("users");
            long samples = app.getLong("samples");
            String packageName = app.getString("package");
            return new HogStat(name, killBenefit, users, samples, packageName);
        } catch(Exception e){
            if(e.getLocalizedMessage() != null){
                Log.d("debug", "Skipping an app with invalid json format", e);
            }
        }
        return null;
    }
}
