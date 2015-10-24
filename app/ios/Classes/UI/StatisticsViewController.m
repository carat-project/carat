//
//  StatisticsViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "StatisticsViewController.h"

@interface StatisticsViewController ()

@end

@implementation StatisticsViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //ios 9 doesnt allow this had to make info.plist file some changes (AllowArbitaryDownloads)
    //to get this to work needs that file from https url
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://carat.cs.helsinki.fi/statistics-data/stats.json"]];
    
    __block NSDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if(data){
                                   json = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:nil];
                                   [self applyGeneralStatJSONDataToView: json];
                                   NSLog(@"Async JSON: %@", json);
                               }
                           }];
    _iosPopularModelsLabel.text = NSLocalizedString(@"IOSModelDesc", nil);
    _androidPopularModelLabel.text = NSLocalizedString(@"AndroidModelDesc", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}
/*
 
 */
- (void)applyGeneralStatJSONDataToView:(NSDictionary *)json
{
    [self applyGenStatisticDataToViews: json key:@"apps" stringID:@"GenAllMessage" label:_genIntensiveDescLabel bar:_genIntensiveBar];
    [self applyGenStatisticDataToViews: json key:@"android-apps" stringID:@"GenAndroidMessage" label:_androidIntensiveLabel bar:_androidIntensiveBar];
    [self applyGenStatisticDataToViews: json key:@"ios-apps" stringID:@"GenIOSMessage" label:_iOSIntensiveDescLabel bar:_iOSIntensiveBar];
    
    
    NSArray *dataSet = [json valueForKey:@"users"];
    
    NSDictionary *dict = [dataSet objectAtIndex:0];
    NSNumber* hasBug = [dict valueForKey:@"value"];
    dict = [dataSet objectAtIndex:1];
    NSNumber* noBugs = [dict valueForKey:@"value"];
    
    long sum = [hasBug longLongValue] + [noBugs longLongValue];
    float hasBugRatio = ([hasBug floatValue] / sum)*100.0f;
    
    _allUsersIntensiveBar.largerBarColor = C_RED;
    _allUsersIntensiveBar.largerMeasureValue = hasBugRatio;
    _allUsersIntensiveBar.smallerBarColor = C_ORANGE;
    _allUsersIntensiveBar.smallerMeasureValue = 0;
    [_allUsersIntensiveBar setNeedsDisplay];
    
    _allUsersIntensiveDescLabel.text = [NSString stringWithFormat:NSLocalizedString(@"GenUsersMessage", nil), sum, lroundf(hasBugRatio)];
    //[self applyGenStatisticDataToViews: json key:@"apps" stringID:@"GenAllMessage" label:_genIntensiveDescLabel bar:_genIntensiveBar];
    
    //"GenAllMessage"="Out of %@ installed applications, %@% are energy-intensive (Hogs in the Carat App) and %@% are energy anomalies (Bugs)."

}

- (void) applyGenStatisticDataToViews:(NSDictionary *)json key:(NSString *)key stringID:(NSString *)stringID label:(UILabel *)label bar:(MeasurementBar *) bar
{
    
    NSLog(@"%@", json);
    NSArray *dataSet = [json valueForKey:key];
    
    NSDictionary *dict = [dataSet objectAtIndex:0];
    NSNumber* wellBehived = [dict valueForKey:@"value"];
    dict = [dataSet objectAtIndex:1];
    NSNumber* hogs = [dict valueForKey:@"value"];
    dict = [dataSet objectAtIndex:2];
    NSNumber* bugs = [dict valueForKey:@"value"];
    //NSArray *wellBehivedArr = [dataSet valueForKey:@"well-behaved"];
    //NSArray *hogsArr = [dataSet valueForKey:@"hogs"];
    //NSArray *bugsArr = [dataSet valueForKey:@"bugs"];
    
    long sum = [wellBehived longLongValue] + [hogs longLongValue]  + [bugs longLongValue] ;
    float hogsRatio = ([hogs floatValue] / sum)*100.0f;
    float bugsRatio = ([bugs floatValue] / sum)*100.0f;
    
    bar.largerBarColor = C_ORANGE;
    bar.largerMeasureValue = hogsRatio + bugsRatio;
    bar.smallerBarColor = C_RED;
    bar.smallerMeasureValue = bugsRatio;
    [bar setNeedsDisplay];
    
    label.text = [NSString stringWithFormat:NSLocalizedString(stringID, nil), sum, lroundf(hogsRatio), lroundf(bugsRatio)];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_genIntensiveDescLabel release];
    [_androidIntensiveLabel release];
    [_genIntensiveBar release];
    [_androidIntensiveBar release];
    [_iOSIntensiveDescLabel release];
    [_iOSIntensiveBar release];
    [_allUsersIntensiveDescLabel release];
    [_allUsersIntensiveBar release];
    [_popularDeviceModelsDescLabel release];
    [_wellBehivedBar release];
    [_wellBehivedLabel release];
    [_bugBar release];
    [_bugsLabel release];
    [_hogsLabel release];
    [_hogsBar release];
    [_iosPopularModelsLabel release];
    [_androidPopularModelLabel release];
    [super dealloc];
}
- (IBAction)showWellBehivedInfo:(id)sender {
    NSLog(@"showWellBehivedInfo");
     [self showInfoView:@"WellBehived" message:@"WellBehivedDesc"];
}

- (IBAction)showBugsInfo:(id)sender {
        NSLog(@"showBugsInfo");
     [self showInfoView:@"Bugs" message:@"BugsDesc"];
}

- (IBAction)showHogsInfo:(id)sender {
        NSLog(@"showHogsInfo");
     [self showInfoView:@"Hogs" message:@"HogsDesc"];
}
@end
