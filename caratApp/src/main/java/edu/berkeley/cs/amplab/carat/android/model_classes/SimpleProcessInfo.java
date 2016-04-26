package edu.berkeley.cs.amplab.carat.android.model_classes;
import android.graphics.drawable.Drawable;
import java.io.Serializable;

/**
 * Created by Jonatan Hamberg on 27.4.2016.
 */
public class SimpleProcessInfo  implements Serializable, Comparable<SimpleProcessInfo> {
    private String packageName;
    private String localizedName;
    private String versionName;
    private String importance;
    private Drawable icon;

    public SimpleProcessInfo(String packageName, String localizedName, String importance,
                             String versionName, Drawable icon){
        this.packageName = packageName;
        this.localizedName = localizedName;
        this.importance = importance;
        this.versionName = versionName;
        this.icon = icon;
    }

    public String getPackageName() {
        return packageName;
    }

    public String getLocalizedName() {
        return localizedName;
    }

    public String getImportance() {
        return importance;
    }

    public String getVersionName(){
        return versionName;
    }

    public Drawable getIcon(){
        return icon;
    }

    @Override
    public int compareTo(SimpleProcessInfo another) {
        return this.localizedName.compareToIgnoreCase(another.localizedName);
    }
}
