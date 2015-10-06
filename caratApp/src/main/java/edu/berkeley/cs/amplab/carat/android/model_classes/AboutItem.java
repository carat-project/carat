package edu.berkeley.cs.amplab.carat.android.model_classes;

import java.io.Serializable;
import java.util.ArrayList;

/**
 * Created by Valto on 6.10.2015.
 */
public class AboutItem implements Serializable {

    private String aboutTitle;
    private String aboutMessage;
    private String childMessage;

    public String getAboutTitle() {
        return aboutTitle;
    }

    public void setAboutTitle(String aboutTitle) {
        this.aboutTitle = aboutTitle;
    }

    public String getAboutMessage() {
        return aboutMessage;
    }

    public void setAboutMessage(String aboutMessage) {
        this.aboutMessage = aboutMessage;
    }

    public String getChildMessage() {
        return childMessage;
    }

    public void setChildMessage(String childMessage) {
        this.childMessage = childMessage;
    }

}
