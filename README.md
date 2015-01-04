#### For building the Android app, (in adition to the main project) import the following library projects into your IDE:

1. **Support library**: official library by Google for providing new Android features (such as action bar, navigation drawer, etc) to older APIs (API > 7)
  * Directory path: app/support-appcompat
 

2. **Holograph**: a seamless native library for creating charts and graphs
  * Directory path: app/libs/HoloGraphLibrary

 
3. **FragmentPreference**: a backport of FragmentPreference class. Provides the fragment preference for Android < 3.0 (A FragmentPreference is the recommended way for implementing a fragment for adjusting settings or user preferences. See the comments in CaratSettingsFragment.java)
  * Directory path: app/libs/android-support-v4-preferencefragment

 
4. **Switch Widget Backport**: provides the switch widget (toggle button) for Android < 3.0
  * Directory path: app/libs/android-switch-backport


If you use Eclipse, follow these stpes to import a library project:

1. Select File > *Import*.
2. From the *Android* category, select *Existing Android Code Into Workspace* and click Next.
3. Select the library project's directory, click OK, and then click finish to complete the import process. Now you should see the imported library project in your project navigatation pane, in the left side.


For more details, visit http://carat.cs.berkeley.edu/