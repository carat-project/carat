package edu.berkeley.cs.amplab.carat.android.fragments.tutorial;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.view.ViewPager;
import android.text.Html;
import android.text.method.LinkMovementMethod;
import android.text.method.MovementMethod;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.activities.TutorialActivity;

/**
 * Created by Valto on 26.10.2015.
 */
public class EulaTutorialFragment extends Fragment{

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_eula_tutorial, container, false);
        TextView eulaContent = (TextView) view.findViewById(R.id.eula_message);
        TextView eulaLink = (TextView) view.findViewById(R.id.eula_message_link);
        eulaLink.setOnClickListener((TutorialActivity) this.getActivity());
        eulaContent.setText(Html.fromHtml(getString(R.string.tutorial_fragment_eula_message)));

        return view;
    }

    @Override
    public void onDetach() {
        super.onDetach();

    }

}