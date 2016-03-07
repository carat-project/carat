package edu.berkeley.cs.amplab.carat.android.dialogs;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckedTextView;

import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;

/**
 * Created by Valto on 9.10.2015.
 */
public class PreferenceListDialog extends Dialog implements View.OnClickListener {

    private final String title;
    private final MainActivity mainActivity;

    private CheckedTextView textAll, textFive, textTen, textTwenty, textHour;

    public PreferenceListDialog(MainActivity mainActivity, String title) {
        super(mainActivity);
        this.mainActivity = mainActivity;
        this.title = title;
    }

    public void showDialog() {

        LayoutInflater inflater = getLayoutInflater();
        View dialoglayout = inflater.inflate(R.layout.pref_dialog_layout, null);

        textAll = (CheckedTextView) dialoglayout.findViewById(R.id.text1);
        textFive = (CheckedTextView) dialoglayout.findViewById(R.id.text2);
        textTen = (CheckedTextView) dialoglayout.findViewById(R.id.text3);
        textTwenty = (CheckedTextView) dialoglayout.findViewById(R.id.text4);
        textHour = (CheckedTextView) dialoglayout.findViewById(R.id.text5);

        textAll.setText(mainActivity.getString(R.string.show_all));
        textFive.setText(mainActivity.getString(R.string.five));
        textTen.setText(mainActivity.getString(R.string.ten));
        textTwenty.setText(mainActivity.getString(R.string.twenty));
        textHour.setText(mainActivity.getString(R.string.hour));

        int saved = load();

        switch (saved) {
            case 0:
                textAll.setChecked(true);
                break;
            case 5:
                textFive.setChecked(true);
                break;
            case 10:
                textTen.setChecked(true);
                break;
            case 20:
                textTwenty.setChecked(true);
                break;
            case 60:
                textHour.setChecked(true);
                break;
            default:
                break;
        }

        textAll.setOnClickListener(this);
        textFive.setOnClickListener(this);
        textTen.setOnClickListener(this);
        textTwenty.setOnClickListener(this);
        textHour.setOnClickListener(this);

        AlertDialog.Builder builder = new AlertDialog.Builder(mainActivity);

        builder.setView(dialoglayout);
        builder.setTitle(R.string.hog_thresh);

        final AlertDialog d =
                builder.setPositiveButton(mainActivity.getResources().getString(android.R.string.ok), new OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dismiss();
            }
        }).create();

        d.show();

    }

    private void save(int amount) {
        SharedPreferences p = mainActivity.getSharedPreferences(Constants.PREFERENCE_FILE_NAME, Context.MODE_PRIVATE);
        p.edit().putString(mainActivity.getString(R.string.hog_hide_threshold), String.valueOf(amount)).commit();
        mainActivity.refreshCurrentFragment();
    }

    private int load() {
        SharedPreferences p = mainActivity.getSharedPreferences(Constants.PREFERENCE_FILE_NAME, Context.MODE_PRIVATE);
        return Integer.parseInt(p.getString(mainActivity.getString(R.string.hog_hide_threshold), "0"));
    }


    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.text1:
                textAll.setChecked(true);
                textTen.setChecked(false);
                textTwenty.setChecked(false);
                textHour.setChecked(false);
                textFive.setChecked(false);
                save(0);
                break;
            case R.id.text2:
                textFive.setChecked(true);
                textAll.setChecked(false);
                textTen.setChecked(false);
                textTwenty.setChecked(false);
                textHour.setChecked(false);
                save(5);
                break;
            case R.id.text3:
                textTen.setChecked(true);
                textAll.setChecked(false);
                textTwenty.setChecked(false);
                textHour.setChecked(false);
                textFive.setChecked(false);
                save(10);
                break;
            case R.id.text4:
                textTwenty.setChecked(true);
                textAll.setChecked(false);
                textTen.setChecked(false);
                textHour.setChecked(false);
                textFive.setChecked(false);
                save(20);
                break;
            case R.id.text5:
                textHour.setChecked(true);
                textAll.setChecked(false);
                textTen.setChecked(false);
                textTwenty.setChecked(false);
                textFive.setChecked(false);
                save(60);
                break;
        }
    }
}
