package edu.berkeley.cs.amplab.carat.android.fragments.tutorial;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import edu.berkeley.cs.amplab.carat.android.R;


public class HogsTutorialFragment extends Fragment {


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_hogs_tutorial, container, false);
    }

    @Override
    public void onDetach() {
        super.onDetach();

    }

}
