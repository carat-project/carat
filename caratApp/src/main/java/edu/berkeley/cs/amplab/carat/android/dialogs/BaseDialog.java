package edu.berkeley.cs.amplab.carat.android.dialogs;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.widget.Button;

import edu.berkeley.cs.amplab.carat.android.R;

/**
 * Created by Valto on 6.10.2015.
 */
public class BaseDialog extends Dialog {

    private final String title;
    private final String message;
    private final Context context;

    public BaseDialog(Context context, String title, String message) {
        super(context);
        this.context = context;
        this.title = title;
        this.message = message;
    }

    public void showDialog() {
        AlertDialog.Builder b = new android.app.AlertDialog.Builder(context)
                .setTitle(title)
                .setMessage(message)
                .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });
        AlertDialog d = b.create();
        d.show();
        Button okBtn = d.getButton(DialogInterface.BUTTON_POSITIVE);
        okBtn.setTextColor(context.getResources().getColor(R.color.orange));
    }
}
