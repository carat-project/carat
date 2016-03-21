package edu.berkeley.cs.amplab.carat.android.fragments;

import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;

import edu.berkeley.cs.amplab.carat.android.R;

/**
 * Created by Jonatan Hamberg on 21.3.2016.
 * WebView fragment with callback support.
 */
public class CallbackWebViewFragment extends Fragment {

    private WebView webView;
    private String url;
    private boolean showProgress;
    private boolean loading;
    private FrameLayout loadingScreen;
    private NavigationCallback navigationCallback;
    private static CallbackWebViewFragment instance = null;

    private final static String BRIDGE = "carat";
    private final static String EMPTY_PAGE = "about:blank";
    private final static String unloadTemplate = "javascript:"+
            "window.onunload = function(){"+
                "{bridge}.{callback}();"+
            "};";

    public static abstract class NavigationCallback {
        public abstract void onElementClicked();
    }

    public static CallbackWebViewFragment getInstance(String location){
        if(instance == null) {
            instance = new CallbackWebViewFragment();
        }
        instance.showProgress = true;
        instance.url = location;
        instance.navigationCallback = null;
        return instance;
    }

    @SuppressWarnings("unused")
    public void setShowProgress(boolean isShown){
        showProgress = isShown;
    }

    @SuppressWarnings("unused")
    public void setNavigationCallback(NavigationCallback callback){
        instance.navigationCallback = callback;
    }

    private void setWebViewLoading(boolean loading){
        this.loading = loading;
    }

    public boolean isWebViewLoading(){
        return loading;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState){
        View mainView = inflater.inflate(R.layout.fragment_callback_webview, container, false);
        webView = (WebView)mainView.findViewById(R.id.callback_webview);
        loadingScreen = (FrameLayout)mainView.findViewById(R.id.loading_screen);
        setWebViewLoading(true);
        loadingScreen.setOnTouchListener(new View.OnTouchListener() {
            public boolean onTouch(View v, MotionEvent event) {
                return isWebViewLoading();
            }
        });

        // Various performance optimizations
        if(Build.VERSION.SDK_INT >= 19){
            webView.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        }
        webView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
        webView.getSettings().setJavaScriptEnabled(true);
        webView.getSettings().setDomStorageEnabled(true);
        webView.requestFocus(View.FOCUS_DOWN);

        // Setup action intercepting
        webView.setWebViewClient(getWebViewClient());
        webView.addJavascriptInterface(this, BRIDGE);
        webView.setEnabled(false);
        webView.loadUrl((url == null) ? EMPTY_PAGE : url);
        return mainView;
    }

    private WebViewClient getWebViewClient(){
        WebViewClient client = new WebViewClient(){
            @Override
            public void onPageFinished(WebView view, String url) {
                loading = false;
                loadingScreen.setVisibility(View.GONE);
                webView.setEnabled(true);
                if (navigationCallback != null) {
                    view.loadUrl(unloadTemplate
                            .replace("{bridge}", BRIDGE)
                            .replace("{callback}", "onNavigation"));
                }
            }
        };
        return client;
    }

    @SuppressWarnings("unused")
    @android.webkit.JavascriptInterface
    public void onNavigation() {
        webView.post(new Runnable(){
            @Override
            public void run(){
                instance.navigationCallback.onElementClicked();
            }
        });
    }

    @Override
    public void onDestroy() {
        webView.removeAllViews();
        if(webView != null){
            webView.clearHistory();
            webView.clearCache(true);
            webView.loadUrl(EMPTY_PAGE);
            webView.freeMemory();
            webView.destroy();
        }
        super.onDestroy();
    }
}
