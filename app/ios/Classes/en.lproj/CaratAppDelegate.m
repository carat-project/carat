//
//  CaratAppDelegate.m
//  Carat
//
//  Created by Adam Oliner on 10/6/11.
//  Copyright 2011 UC Berkeley. All rights reserved.
//

#import "CaratAppDelegate.h"
#import "UIDeviceProc.h"
#import <CoreData/CoreData.h>
#import "Flurry.h"
#import "Utilities.h"
#import "CoreDataManager.h"
#import "BugsViewController.h"
#import "Socialize/Socialize.h"
#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>

@implementation CaratAppDelegate

processor_info_array_t cpuInfo, prevCpuInfo;
mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
unsigned numCPUs;
NSTimer *updateTimer;
NSLock *CPUUsageLock;
int cpuStateCheckCount;

@synthesize window = _window;
//@synthesize tabBarController = _tabBarController;
@synthesize dashBoardViewController = _dashBoardViewController;

#pragma mark -
#pragma mark utility

void onUncaughtException(NSException *exception)
{
    [Flurry logError:@"Uncaught" message:[[exception callStackSymbols] componentsJoinedByString:@"\n"] exception:exception];
    NSLog(@"uncaught exception: %@", exception.description);
}

#pragma mark - notifications

- (void)scheduleNotificationAfterInterval:(int)interval {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if (interval <= 0) { interval = 432000; } // 5 days
    //if (interval <= 0) { interval = 10; }
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [[NSDate date] dateByAddingTimeInterval:interval];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = @"Carat may have discovered new battery-saving actions for you. Why don't you take a look?";
    localNotif.alertAction = NSLocalizedString(@"Launch Carat", nil);
    localNotif.repeatInterval = 0;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    [localNotif release];
}

#pragma mark -
#pragma mark Application lifecycle

- (id) init {
    if (self = [super init])
    {
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        self.window.clipsToBounds =YES;
        self.window.frame =  CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height-20);
    }
    
    //Core usage
    cpuStateCheckCount = 0;
    int mib[2U] = { CTL_HW, HW_NCPU };
    size_t sizeOfNumCPUs = sizeof(numCPUs);
    int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
    if(status)
        numCPUs = 1;
    
    CPUUsageLock = [[NSLock alloc] init];
    
    updateTimer = [[NSTimer scheduledTimerWithTimeInterval:3
                                                    target:self
                                                  selector:@selector(updateCoreInfo:)
                                                  userInfo:nil
                                                   repeats:YES] retain];
    //CoreUsageEnds
    //[[Globals instance] userHasConsented]; //TODO remove just skipping user consent for now
    // test for consent
    if ([[Globals instance] hasUserConsented]) return [self proceedWithConsent];
    else return [self acquireConsentWithCallbackTarget:self
                                          withSelector:@selector(proceedWithConsent)];
    
}

- (BOOL)acquireConsentWithCallbackTarget:(CaratAppDelegate *)delegate withSelector:(SEL)selector {
    // UI
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    TutorialViewController *viewController = [[TutorialViewController alloc] initWithNibName:@"TutorialViewController" bundle:nil callbackTo:delegate withSelector:selector];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    [viewController release];
    
    // to help track down where exceptions are being raised
    NSSetUncaughtExceptionHandler(&onUncaughtException);
    
    return YES;
}


// called when the user has accepted the EULA
- (BOOL)proceedWithConsent {
    DLog(@"Proceeding with consent");
    NSLog(@"%s", __PRETTY_FUNCTION__);
    //[self startStoryboard];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.dashBoardViewController = [[DashBoardViewController alloc] initWithNibName:@"DashBoardViewController" bundle:nil];
    self.window.rootViewController = self.dashBoardViewController;
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.window.rootViewController];
    self.navigationController.navigationBarHidden = YES;
    
    [self.window addSubview:self.navigationController.view];
    [self.window makeKeyAndVisible];
    // Override point for customization after application launch.
    if (locationManager == nil && [CLLocationManager significantLocationChangeMonitoringAvailable]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
    }
    
    // we do this to prompt the dialog asking for permission to share location info
    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager stopMonitoringSignificantLocationChanges];
        
    // idempotent setup of notifications; also called in willResignActive
    [self setupNotificationSubscriptions];
    [[UIApplication sharedApplication] cancelAllLocalNotifications]; // so nothing fires while we're active
    
    // Everytime the CARAT app is launched, we will send a registration message. 
    // Right at this point, we are unsure if there is network connectivity, so 
    // save the message in core data. 
    [[CoreDataManager instance] generateSaveRegistration];
    
    // set the socialize api key and secret, app registered here: http://www.getsocialize.com/apps/
    [Socialize storeConsumerKey:@"8d0ddf53-fac1-48b1-ab25-b8c819455124"];
    [Socialize storeConsumerSecret:@"a043bea4-b4c0-432d-a007-5b74207d184e"];
    [SZFacebookUtils setAppId:@"258193747569113"];
    [SZTwitterUtils setConsumerKey:@"JkGB6jsTAAfitYT6xASvxA" consumerSecret:@"crj455prhsA22L48VmxH2aEimR8Rmi0yYJgoclQpwPw"];
    
    [[CoreDataManager instance] sampleNow:@"applicationDidBecomeActive"];
    
    // to help track down where exceptions are being raised
    NSSetUncaughtExceptionHandler(&onUncaughtException);
    
    return YES;
}

#pragma mark Core Usage
- (void)updateCoreInfo:(NSTimer *)timer
{
    if(cpuStateCheckCount > 20){
        [updateTimer invalidate];
        return;
    }
    cpuStateCheckCount++;
    natural_t numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
    if(err == KERN_SUCCESS) {
        [CPUUsageLock lock];
        float allCoresUsage=0.0f;
        float allCoresTotal=0.0f;
        for(unsigned i = 0U; i < numCPUs; ++i) {
            float inUse, total;
            if(prevCpuInfo) {
                inUse = (
                         (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                         );
                total = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                total = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            allCoresUsage += inUse;
            allCoresTotal += total;
            
            //NSLog(@"Core: %u Usage: %f",i,inUse / total);
            [[CoreDataManager instance] setCPUData: allCoresUsage total: allCoresUsage];
        }
        [CPUUsageLock unlock];
        
        if(prevCpuInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
        }
        
        prevCpuInfo = cpuInfo;
        numPrevCpuInfo = numCpuInfo;
        
        cpuInfo = NULL;
        numCpuInfo = 0U;
    } else {
        NSLog(@"Error!");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    if ([[Globals instance] hasUserConsented]) {
        [self setupNotificationSubscriptions];
        [self scheduleNotificationAfterInterval:-1]; // uses default of 5 days
    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    if ([[Globals instance] hasUserConsented]) [locationManager startMonitoringSignificantLocationChanges];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    if ([[Globals instance] hasUserConsented]) [locationManager stopMonitoringSignificantLocationChanges];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Facebook Connect methods

- (BOOL)application:(UIApplication *)application 
            openURL:(NSURL *)url 
  sourceApplication:(NSString *)sourceApplication 
         annotation:(id)annotation 
{
    return [Socialize handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application 
      handleOpenURL:(NSURL *)url 
{
    return [Socialize handleOpenURL:url];
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

#pragma mark -
#pragma mark application logic methods

- (void)setupNotificationSubscriptions {
    // check settings to determine if location-change service is allowed
    // setup notifications for battery, location, etc.
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(batteryLevelChanged:) 
                                                 name:UIDeviceBatteryLevelDidChangeNotification 
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(batteryStateChanged:) 
                                                 name:UIDeviceBatteryStateDidChangeNotification 
                                               object:nil];
}

- (void)batteryLevelChanged:(NSNotification *)notification {
    [[CoreDataManager instance] sampleNow:@"batteryLevelChanged"];
}

- (void)batteryStateChanged:(NSNotification *)notification {
    [[CoreDataManager instance] sampleNow:@"batteryStateChanged"];
}

- (void)application:(UIApplication *)application 
didReceiveLocalNotification:(UILocalNotification *)notification {
    [[CoreDataManager instance] sampleNow:@"didReceiveLocalNotification"];
}

#pragma mark -
#pragma mark location awareness

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation
{
    [Flurry setLatitude:newLocation.coordinate.latitude 
                       longitude:newLocation.coordinate.longitude 
              horizontalAccuracy:newLocation.horizontalAccuracy            
                verticalAccuracy:newLocation.verticalAccuracy]; 
    
    // Do any prep work before sampling. Note that we may be in the background, so nothing heavy.
    [(Globals *)[Globals instance] setDistanceTraveled:[newLocation distanceFromLocation:oldLocation]];
    [[CoreDataManager instance] sampleNow:@"didUpdateToLocation"];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DLog(@"%@", [NSString stringWithFormat:@"%@",[error localizedDescription]]);
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end

