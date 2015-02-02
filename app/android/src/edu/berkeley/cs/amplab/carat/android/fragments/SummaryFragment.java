package edu.berkeley.cs.amplab.carat.android.fragments;

import java.util.ArrayList;

import android.graphics.Typeface;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.TextView;

import com.github.mikephil.charting.charts.PieChart;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.PieData;
import com.github.mikephil.charting.data.PieDataSet;
import com.github.mikephil.charting.utils.Legend;
import com.github.mikephil.charting.utils.Legend.LegendPosition;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.storage.SimpleHogBug;

/**
 * 
 * @author Javad Sadeqzadeh
 *
 */
public class SummaryFragment extends ExtendedTitleFragment {
	// private final String TAG = "SummaryFragment";
	private MainActivity mMainActivity = CaratApplication.getMainActivity();
	private PieChart mChart;
	
	@Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		final View inflatedView;
        
		int hogsCount = 0;
		int bugsCount = 0;
		if (CaratApplication.storage != null){
			SimpleHogBug[] h = CaratApplication.storage.getHogReport();
			SimpleHogBug[] b = CaratApplication.storage.getBugReport();
			if (h != null)
				hogsCount = h.length;
			if (b != null)
				bugsCount = b.length;
		}
		
		// Log.i(TAG, "isStatsDataAvailable()=" + mMainActivity.isStatsDataAvailable());
		
		if (mMainActivity.isStatsDataAvailable()) {
			inflatedView = inflater.inflate(R.layout.summary, container, false);
			drawPieChart(inflatedView);
			setClickableUserStatsText(inflatedView, hogsCount, bugsCount);
		} else {
			inflatedView = inflater.inflate(R.layout.summary_unavailable, container, false);
		}
		
        // onCreateView() method should always return the inflated view
        return inflatedView;
    }

	private void setClickableUserStatsText(final View inflatedView, int hogsCount, int bugsCount) {
		CountClickListener l = new CountClickListener();
		
		TextView hogsCountTv = (TextView) inflatedView.findViewById(R.id.summary_hogs_count);
		hogsCountTv.setText(hogsCount + " hogs");
		hogsCountTv.setTextColor(Constants.CARAT_COLORS[1]);
		hogsCountTv.setOnClickListener(l);
		
		TextView bugsCountTv = (TextView) inflatedView.findViewById(R.id.summary_bugs_count);
		bugsCountTv.setText(bugsCount + " bugs");
		bugsCountTv.setTextColor(Constants.CARAT_COLORS[2]);
		bugsCountTv.setOnClickListener(l);
	}
	
	/**
	 * Concisely handle clicks on the hogs/bugs text items.
	 * @author Eemil Lagerspetz
	 *
	 */
	private class CountClickListener implements OnClickListener{
		@Override
		public void onClick(View v) {
			if (v == v.getRootView().findViewById(R.id.summary_hogs_count)){
				mMainActivity.replaceFragment(mMainActivity.getHogsFragment(), mMainActivity.getFragmentTag(4), true);
			}else{
				mMainActivity.replaceFragment(mMainActivity.getBugsFragment(), mMainActivity.getFragmentTag(3), true);
			}
		}
	}
	
	private void drawPieChart(final View inflatedView) {
		mChart = (PieChart) inflatedView.findViewById(R.id.chart1);
		mChart.setDescription("");
		
		Typeface tf = Typeface.createFromAsset(getActivity().getAssets(), "fonts/OpenSans-Regular.ttf");
		
		mChart.setValueTypeface(tf);
		mChart.setCenterTextTypeface(Typeface.createFromAsset(getActivity().getAssets(), "fonts/OpenSans-Light.ttf"));
		mChart.setUsePercentValues(true);
		mChart.setCenterText(getString(R.string.summary_chart_center_text)); 
		mChart.setCenterTextSize(22f);
		 
		// radius of the center hole in percent of maximum radius
		mChart.setHoleRadius(40f); 
		mChart.setTransparentCircleRadius(50f);
		
		// disable click / touch / tap on the chart
		mChart.setTouchEnabled(false);
		
		// enable / disable drawing of x- and y-values
	    //    mChart.setDrawYValues(false);
	    //    mChart.setDrawXValues(false);
		
		mChart.setData(generatePieData());
		Legend l = mChart.getLegend();
		l.setPosition(LegendPosition.NONE);
	}

	protected PieData generatePieData() {
        ArrayList<Entry> entries = new ArrayList<Entry>();
        ArrayList<String> xVals = new ArrayList<String>();
        
        xVals.add(getString(R.string.chart_wellbehaved));
        xVals.add(getString(R.string.chart_hogs));
        xVals.add(getString(R.string.chart_bugs));
        
        int wellbehaved = mMainActivity.mWellbehaved;
		int hogs = mMainActivity.mHogs;
		int bugs = mMainActivity.mBugs;
        
		entries.add(new Entry((float) (wellbehaved), 1));
		entries.add(new Entry((float) (hogs), 2));
		entries.add(new Entry((float) (bugs), 3));
		
        PieDataSet ds1 = new PieDataSet(entries, getString(R.string.summary_android_apps));
        ds1.setColors(Constants.CARAT_COLORS);
        ds1.setSliceSpace(2f);
        
        PieData d = new PieData(xVals, ds1);
        return d;
    }
	
}
