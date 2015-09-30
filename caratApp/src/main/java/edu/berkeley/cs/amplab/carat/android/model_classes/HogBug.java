package edu.berkeley.cs.amplab.carat.android.model_classes;

import java.util.ArrayList;

/**
 * Created by Valto on 30.9.2015.
 */
public class HogBug {

    private String Name;
    private ArrayList<HogBugDetails> items;

    public String getName() {
        return Name;
    }

    public void setName(String name) {
        this.Name = name;
    }

    public ArrayList<HogBugDetails> getItems() {
        return items;
    }

    public void setItems(ArrayList<HogBugDetails> items) {
        this.items = items;
    }

}
