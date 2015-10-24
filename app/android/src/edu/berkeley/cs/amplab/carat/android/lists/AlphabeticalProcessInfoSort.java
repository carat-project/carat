package edu.berkeley.cs.amplab.carat.android.lists;

import java.util.Comparator;

import android.content.Context;

import edu.berkeley.cs.amplab.carat.android.CaratApplication;
import edu.berkeley.cs.amplab.carat.thrift.ProcessInfo;

public class AlphabeticalProcessInfoSort implements
        Comparator<ProcessInfo> {

    private Context c;
    
    public AlphabeticalProcessInfoSort(Context c){
        this.c = c;
    }

    @Override
    public int compare(ProcessInfo lhs, ProcessInfo rhs) {
        if (lhs.isSetApplicationLabel() && rhs.isSetApplicationLabel()){
            return lhs.getApplicationLabel().compareTo(rhs.getApplicationLabel());
        }
        String l = lhs.getPName();
        String r = rhs.getPName();
        if (l != null && r != null){
            return l.compareTo(r);
        }else
            return 0;
    }
}
