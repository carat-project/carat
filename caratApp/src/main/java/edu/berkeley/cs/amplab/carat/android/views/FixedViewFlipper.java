package edu.berkeley.cs.amplab.carat.android.views;

import edu.berkeley.cs.amplab.carat.android.Constants;
import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.widget.ViewFlipper;

public class FixedViewFlipper extends ViewFlipper {

    public FixedViewFlipper(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    protected void onDetachedFromWindow() {
        try {
            super.onDetachedFromWindow();
        } catch (Exception e) {
            if (Constants.DEBUG)
                Log.d("MyViewFlipper", "Stopped a viewflipper crash");
            stopFlipping();
        }
    }
}
