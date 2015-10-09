package edu.berkeley.cs.amplab.carat.android.dialogs;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.util.TypedValue;
import android.widget.ArrayAdapter;
import android.widget.Button;

import edu.berkeley.cs.amplab.carat.android.Constants;
import edu.berkeley.cs.amplab.carat.android.MainActivity;
import edu.berkeley.cs.amplab.carat.android.R;

/**
 * Created by Valto on 9.10.2015.
 */
public class PreferenceListDialog extends Dialog {

    private final String title;
    private final MainActivity mainActivity;

    public PreferenceListDialog(MainActivity mainActivity, String title) {
        super(mainActivity);
        this.mainActivity = mainActivity;
        this.title = title;
    }

    public void showDialog() {
        AlertDialog.Builder builderSingle = new AlertDialog.Builder(
                mainActivity);
        builderSingle.setTitle(R.string.hog_thresh);
        final ArrayAdapter<String> arrayAdapter = new ArrayAdapter<String>(
                mainActivity,
                R.layout.preference_list_item);
        arrayAdapter.add(mainActivity.getString(R.string.show_all));
        arrayAdapter.add(mainActivity.getString(R.string.five));
        arrayAdapter.add(mainActivity.getString(R.string.ten));
        arrayAdapter.add(mainActivity.getString(R.string.twenty));
        arrayAdapter.add(mainActivity.getString(R.string.hour));
        builderSingle.setPositiveButton(android.R.string.cancel,
                new DialogInterface.OnClickListener() {

                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });

        builderSingle.setAdapter(arrayAdapter,
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        switch (which) {
                            case R.string.show_all:
                                save(0);
                                break;
                            case R.string.five:
                                save(5);
                                break;
                            case R.string.ten:
                                save(10);
                                break;
                            case R.string.twenty:
                                save(20);
                                break;
                            case R.string.hour:
                                save(60);
                                break;
                            default:
                                break;
                        }
                        dialog.dismiss();
                    }
                });

        AlertDialog d = builderSingle.create();
        d.show();
        Button okBtn = d.getButton(DialogInterface.BUTTON_POSITIVE);
        okBtn.setTextColor(mainActivity.getResources().getColor(R.color.orange));
        okBtn.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16f);
    }

    private void save(int amount) {
        SharedPreferences p = mainActivity.getSharedPreferences(Constants.PREFERENCE_FILE_NAME, Context.MODE_PRIVATE);
        p.edit().putString(mainActivity.getString(R.string.hog_hide_threshold), String.valueOf(amount)).apply();
    }
}
