package edu.berkeley.cs.amplab.carat.android.dialogs;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.View;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;

import edu.berkeley.cs.amplab.carat.android.R;
import edu.berkeley.cs.amplab.carat.android.views.LocalizedWebView;

/**
 * Created by Valto on 6.10.2015.
 */
public class BaseDialog extends Dialog {

    private final String title;
    private final String message;
    private final Context context;
    private final String webViewUrl;

    public BaseDialog(Context context, String title, String message, String webViewUrl) {
        super(context);
        this.context = context;
        this.title = title;
        this.message = message;
        this.webViewUrl = webViewUrl;
    }

    public void showDialog() {

        if (webViewUrl != null) {
            LocalizedWebView w = new LocalizedWebView(context);
            w.loadUrl("file:///android_asset/" + webViewUrl + ".html");

            w.setWebViewClient(new WebViewClient() {
                @Override
                public boolean shouldOverrideUrlLoading(WebView view, String url) {
                    view.loadUrl(url);
                    return true;
                }
            });

            AlertDialog.Builder b = new android.app.AlertDialog.Builder(context)
                    .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            dialog.dismiss();
                        }
                    });
            AlertDialog d = b.create();
            d.setView(w);
            d.show();
            Button okBtn = d.getButton(DialogInterface.BUTTON_POSITIVE);
            okBtn.setTextColor(context.getResources().getColor(R.color.orange));

        } else {
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
}
