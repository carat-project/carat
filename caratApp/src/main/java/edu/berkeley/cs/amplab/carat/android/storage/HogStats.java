package edu.berkeley.cs.amplab.carat.android.storage;

import java.io.Serializable;

/**
 * Created by Jonatan Hamberg on 28.4.2016.
 */
public class HogStats implements Serializable, Comparable<HogStats> {

    /**
     * Auto-generated UID for serialization
     */
    private static final long serialVersionUID = -7501985396874679871L;

    private int index;
    private String appName;
    private long killBenefit;
    private long users;
    private long samples;
    private String packageName;

    public HogStats(String appName, long killBenefit, long users,
                    long samples, String packageName){
        this.index = -1;
        this.appName = appName;
        this.killBenefit = killBenefit;
        this.users = users;
        this.samples = samples;
        this.packageName = packageName;
    }

    public void assignIndex(int index){
        this.index = index;
    }

    public int getIndex(){
        return index;
    }

    public String getPackageName() {
        return packageName;
    }

    public String getAppName() {
        return appName;
    }

    public long getKillBenefit() {
        return killBenefit;
    }

    public long getUsers() {
        return users;
    }

    public long getSamples() {
        return samples;
    }

    @Override
    public int compareTo(HogStats another) {
        Long a = killBenefit;
        Long b = another.killBenefit;
        return b.compareTo(a);
    }
}
