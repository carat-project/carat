//
//  StatisticsViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 06/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "StatisticsViewController.h"
#import "HogStatisticsViewController.h"

@interface StatisticsViewController ()
@end

@implementation StatisticsViewController {
}

UIAlertView *alert;
bool popModelLoaded;
bool genStatLoaded;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_spinner startAnimating];
    _wellBehivedLabel.text = NSLocalizedString(@"WellBehaved", nil);
    _navbarTitle.title = [NSLocalizedString(@"GlobalStatistics", nil) uppercaseString];
    
    popModelLoaded = false;
    genStatLoaded = false;
    
    [self setupStatsButton];
    
    //ios 9 doesnt allow this had to make info.plist file some changes (AllowArbitaryDownloads)
    //to get this to work needs that file from https url
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://carat.cs.helsinki.fi/statistics-data/stats.json"]];
    __block NSDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if(data != nil){
                                   NSLog(@"%s applyGeneralStatJSONDataToView:\n", __PRETTY_FUNCTION__);
                                   NSError *error = nil;
                                   json = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:&error];
                                   if(error == nil){
                                       [self writeToFile:data fileName:@"stats.json"];
                                       [self applyGeneralStatJSONDataToView: json];
                                       genStatLoaded = true;
                                       if(popModelLoaded && genStatLoaded){
                                           [_spinnerBackGround setHidden:YES];
                                           [_spinner stopAnimating];
                                           [_spinner setHidden:YES];
                                       }
                                       //NSLog(@"%s Read from file:\n%@", __PRETTY_FUNCTION__, [self readFile:@"stats.json"]);
                                       //NSLog(@"Async JSON: %@", json);

                                   }
                                   else{
                                       [self setGeneralStatsFromFile];
                                       
                                   }
                                   
                               }
                               else{
                                   [self setGeneralStatsFromFile];
                               }
                           }];
    
    NSURLRequest *request2 = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://carat.cs.helsinki.fi/statistics-data/shares.json"]];
    __block NSDictionary *json2;
    [NSURLConnection sendAsynchronousRequest:request2
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if(data != nil){
                                   NSError *error = nil;
                                   json2 = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:0
                                                                            error:&error];
                                   if(error == nil){
                                       [self writeToFile:data fileName:@"shares.json"];
                                       [self applyPopularDevicesJSONDataToView: json2];
                                       popModelLoaded = true;
                                       if(popModelLoaded && genStatLoaded){
                                           [_spinnerBackGround setHidden:YES];
                                           [_spinner stopAnimating];
                                           [_spinner setHidden:YES];
                                       }
                                       //NSLog(@"%s Read from file:\n%@", __PRETTY_FUNCTION__, [self readFile:@"shares.json"]);
                                                                             //NSLog(@"Async JSON: %@", json2);
                                   }
                                   else{
                                       [self setPopularDeviceModelsFromFile];
                                   }
                                   
                               }
                               else{
                                   [self setPopularDeviceModelsFromFile];
                               }
                           }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupStatsButton {
    NSString *localizedPart = NSLocalizedString(@"ShowHogStats", nil);
    NSString *text = [localizedPart stringByAppendingString:@"〉"];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    UIFont *font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
    int len = [localizedPart length];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, len)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(len, 1)];
    [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, len)];
    [_hogStatsButton addTarget:self action:@selector(showHogStats:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)showHogStats:(id)sender {
    HogStatisticsViewController *controller = [[HogStatisticsViewController alloc]initWithNibName:@"HogStatisticsViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}

- (int)stringAtIndex:(NSMutableArray *) array text:(NSString *)text{
    int count = (int)array.count;
    for(int i=0; i<count; i++){
        NSString *arrayText = ((PopularModel *)[array objectAtIndex:i]).deviceName;
        if([arrayText isEqualToString:text]){
            return i;
        }
    }
    return -1;
}

-(void)hideDownloadProgress
{
    [_spinnerBackGround setHidden:YES];
    [_spinner stopAnimating];
    [_spinner setHidden:YES];
}

-(void)setGeneralStatsFromFile
{
    NSData *content = [self readFile:@"stats.json"];
    if(content == nil){
        if(alert == nil){
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoNetwork", nil)
                                               message:NSLocalizedString(@"NoGlobalData", nil)
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                     otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        [self hideDownloadProgress];
        return;
    }
    NSDictionary *json = [self convertToDict:content];
    [self applyGeneralStatJSONDataToView: json];
    genStatLoaded = true;
    if(popModelLoaded && genStatLoaded){
        [self hideDownloadProgress];
    }
}

-(void)setPopularDeviceModelsFromFile
{
    NSData *content = [self readFile:@"shares.json"];
    if(content == nil){
        if(alert == nil){
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoNetwork", nil)
                                               message:NSLocalizedString(@"NoGlobalData", nil)
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                     otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        [self hideDownloadProgress];
        return;
    }
    NSDictionary *json = [self convertToDict:content];
    [self applyPopularDevicesJSONDataToView: json];
    popModelLoaded = true;
    if(popModelLoaded && genStatLoaded){
        [self hideDownloadProgress];
    }
}

-(void)writeToFile:(NSData *) content fileName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    [content  writeToFile:path atomically:YES];
}

-(NSData *)readFile:(NSString *) fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSData* content = [NSData dataWithContentsOfFile:path];
    return content;
}

-(NSDictionary *)convertToDict:(NSData *) content
{
    return [NSJSONSerialization JSONObjectWithData:content
                                    options:0
                                      error:nil];
    //[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}




- (void)applyPopularDevicesJSONDataToView:(NSDictionary *)json
{
    NSDictionary *allData = [json valueForKey:@"All"];
    NSDictionary *androidData = [allData valueForKey:@"Android"];
    NSString *androidText = [self getPopularDeviceModelString:androidData];
    
    NSDictionary *iOSData = [allData valueForKey:@"iOS"];
    NSString *iPhoneText = [self getPopularDeviceModelString:iOSData];

    _iosPopularModelsLabel.text = iPhoneText;
    _androidPopularModelLabel.text = androidText;
}

-(NSString *) getPopularDeviceModelString: (NSDictionary *)modelDict
{
    NSMutableArray *popularModels = [[NSMutableArray alloc]init];
    NSArray *versions = [modelDict allValues];
    for(NSDictionary *version in versions){
        NSArray *deviceNames = [version allKeys];
        NSArray *usedSum = [version allValues];
        int index = 0;
        for(NSString* deviceName in deviceNames){
            int deviceStringInd = [self stringAtIndex:popularModels text:deviceName];
            if(deviceStringInd != -1) {
                PopularModel *popModel = (PopularModel *)[popularModels objectAtIndex:deviceStringInd];
                long newSum = [(NSNumber *)[usedSum objectAtIndex:index] longValue];
                popModel.inUseCount += newSum;
                //popModel.inUseCount = [NSNumber numberWithLong:(newSum + old)];
            }
            else {
                PopularModel *popModel = [[PopularModel alloc] init];
                popModel.deviceName = deviceName;
                popModel.inUseCount = [(NSNumber *)[usedSum objectAtIndex:index] longValue];
                [popularModels addObject:popModel];
                [popModel release];
            }
            index++;
            
        }
    }
    
    //TODO to have this result to be accurate all models that arent in top 8 should go to other inUsedCount value.
    //show only 8 devices
    NSArray *sortedArray = [popularModels sortedArrayUsingSelector:@selector(compare:)];
    [popularModels release];
    
    NSMutableString *androidText = [[NSMutableString alloc] init];
    long sumAll = 0;
    for(int i=0; i<8; i++){
        PopularModel *m = (PopularModel *)[sortedArray objectAtIndex:i];
        sumAll += (NSInteger)m.inUseCount;
    }
    
    for(int i=0; i<8; i++){
        PopularModel *m = (PopularModel *)[sortedArray objectAtIndex:i];
        float rat = (m.inUseCount/(float)sumAll)*100.0f;
        [androidText appendString:m.deviceName];
        [androidText appendString:[NSString stringWithFormat:@" : %.01f%%\n", rat]];
    }
    NSLog(@"%@", androidText);
    NSString *immutableString = [NSString stringWithString:androidText];
    [androidText release];
    return immutableString;
}

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
    [_spinnerBackGround release];
    alert = nil;
    [_navbarTitle release];
    [_hogStatsButton release];
    [super dealloc];
}
- (IBAction)showWellBehivedInfo:(id)sender {
    NSLog(@"showWellBehavedInfo");
     [self showInfoView:@"WellBehaved" message:@"WellBehavedDesc"];
}

- (IBAction)showBugsInfo:(id)sender {
        NSLog(@"showPersonalInfo");
     [self showInfoView:@"Bugs" message:@"PersonalDesc"];
}

- (IBAction)showHogsInfo:(id)sender {
        NSLog(@"showHogsInfo");
     [self showInfoView:@"Hogs" message:@"HogsDesc"];
}
@end
