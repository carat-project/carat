//
//  TopHogsTableView.m
//  Carat
//
//  Created by Jonatan C Hamberg on 01/03/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import "CaratConstants.h"
#import "TopHogsTableView.h"
#import "TopHogsTableViewCell.h"
#import "Utilities.h"

@implementation TopHogsTableView
@synthesize data;

// Attach an optional loading indicator
- (void)attachSpinner:(UIActivityIndicatorView *)spinner withBackground:(UIView *)spinnerBackGround
{
    self.spinner = spinner;
    self.spinnerBackground = spinnerBackGround;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Top hogs";
}

// Initialize data here because of the call order
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(data) return [data count];
    
    NSError *error = nil;
    NSString *path = [Utilities getDirectoryPath:@"stats-ios.json"];
    NSString *usersPath = [Utilities getDirectoryPath:@"stats-users"];
    NSDate *modified = [Utilities getLastModified:path];
    NSArray *cache = [NSArray arrayWithContentsOfFile:path];
    NSString *usersCache = [NSString stringWithContentsOfFile:usersPath encoding:NSUTF8StringEncoding error:&error];
    
    // Check if there is a fresh copy in cache
    NSLog(@"Days since last statistics check: %ld", [Utilities daysSince:modified]);
    if(usersCache && cache && [Utilities daysSince:modified] < 1) {
        self.users = usersCache;
        self.data = cache;
        return [data count];
    } else {
        [self loadDataFor:tableView withFallbackCache:cache];
        return 0;
    }
}

// Returns a cell for a given path/index
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"TopHogsCell";
    TopHogsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        UINib *nib = [UINib nibWithNibName:@"TopHogsTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    if(self.data == nil) {
        return cell;
    } else {
        return [self decorateCell:cell forIndexpath:indexPath];
    }
    return cell;
}

// Fills all cell fields with data for given index path
- (UITableViewCell *)decorateCell:(TopHogsTableViewCell *)cell forIndexpath:(NSIndexPath *)indexPath
{
    int row = (int)indexPath.row;
    cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    cell.clipsToBounds = YES;
    
    // Collapsed information
    cell.rowNumber.text = [[NSString stringWithFormat:@"%i", row+1] stringByAppendingString:@")"];
    cell.appName.text = [self getValueFromRow:row withKey:@"name"];
    
    // Expanded information
    NSString *benefitMinutes = [self getValueFromRow:row withKey:@"killBenefit"];
    cell.benefitText.text = [self formatBenefit:benefitMinutes];
    cell.sampleCount.text = [self getValueFromRow:row withKey:@"samples"];
    NSString *usersString = [self getValueFromRow:row withKey:@"users"];
    
    if(self.users && usersString){
        int users = [usersString intValue];
        int totalUsers = [self.users intValue];
        float usage = ((float)users / (float)totalUsers)*100;
        cell.usagePercentage.text = [NSString stringWithFormat:@"Seen in %.2f%% of all devices", usage];
    } else {
        cell.usagePercentage.text = @"Popularity currently unknown";
    }
    
    // Expanded/collapsed arrow state
    if([self.expandedPaths containsObject:indexPath]){
        cell.expandButton.image = [UIImage imageNamed:@"collapse_btn_close.png"];
    } else {
        cell.expandButton.image = [UIImage imageNamed:@"collapse_btn_open.png"];
    }
    
    return cell;
}

// Expand or collapse cells by changing the displayed height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.expandedPaths containsObject:indexPath]){
        return 129;
    }
    return 44.0; // Normal height
}

// Toggle expanded/collapsed by tapping
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.expandedPaths) {
        self.expandedPaths = [NSMutableArray new];
    }
    
    // Expand or collapse
    if([self.expandedPaths containsObject:indexPath]){
        [self.expandedPaths removeObject:indexPath];
    } else {
        [self.expandedPaths addObject:indexPath];
    }
    
    // Reload selected/deselected rows
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

// Helper function to fetch a value from NSArray row with a key
- (NSString *) getValueFromRow:(int)row withKey:(NSString *)key
{
    return [NSString stringWithFormat:@"%@", [[self.data objectAtIndex: row] objectForKey:key]];
}

// Format hours and minutes for battery impact
-(NSString *)formatBenefit:(NSString *)benefitMinutes
{
    int benefit = [benefitMinutes intValue];
    int minutes = benefit % 60;
    int hours = benefit / 60;
    if(hours > 0){
        return [NSString stringWithFormat:@"-%dh %dmin",hours, minutes];
    } else {
        return [NSString stringWithFormat:@"-%dmin", minutes];
    }
}

// Download the latest app list date
-(void)loadDataFor:(UITableView *) tableView withFallbackCache:(NSArray *)cache{
    NSString *dataURL = [kStatisticsDataURI stringByAppendingString:@"data.json"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:dataURL]];
    __block NSArray *platforms;
    
    // Initialize or reset data
    self.data = [NSArray new];
    
    // Start downloading
    [self startSpinner];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *receivedData, NSError *connectionError) {
         if(receivedData != nil) {
             NSError *error = nil;
             platforms = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&error];
             if(error == nil) {
                 int users = 0;
                 NSString *date = [self filterPlatforms:platforms withTableView:tableView users:&users];
                 if(date) {
                     // Find latest
                     NSString *freshnessPath = [Utilities getDirectoryPath:@"stats-freshness"];
                     NSString *usersPath = [Utilities getDirectoryPath:@"stats-users"];
                     NSString *cachedDate = [NSString stringWithContentsOfFile:freshnessPath encoding:NSUTF8StringEncoding error:&error];
                     NSString *cachedUsers = [NSString stringWithContentsOfFile:usersPath encoding:NSUTF8StringEncoding error:&error];
                     
                     if(users){
                         NSString *usersSave = [NSString stringWithFormat:@"%i", users];
                         self.users = usersSave;
                         [usersSave writeToFile:usersPath atomically:true encoding:NSUTF8StringEncoding error:&error];
                     }
                     
                     // Avoid downloading the same data again
                     if(!cachedDate || !cachedUsers || ![cachedDate isEqualToString:date] || !cache) {
                         [self loadDataFor:tableView withDate:date withFallbackCache:cache];
                         [date writeToFile:freshnessPath atomically:true encoding:NSUTF8StringEncoding error:&error];
                         return;
                     }
                 }
             }
         }
         
         // Use cache as a fallback
         if(cache) {
             self.data = cache;
             [self stopSpinner];
             [tableView reloadData];
         }
     }];
    
}

// Download the list for a given date
-(void)loadDataFor:(UITableView *)tableView withDate:(NSString *)date withFallbackCache:(NSArray*) cache
{
    NSString *dataURL = [[kStatisticsDataURI stringByAppendingString:date] stringByAppendingString:@"-ios.json"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:dataURL]];
    __block NSArray *hogsJSON;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *receivedData, NSError *connectionError) {
         if(receivedData != nil) {
             NSError *error = nil;
             hogsJSON = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&error];
             if(!error) {
                 self.data = [self filterHogs:hogsJSON];
                 [tableView reloadData];
                 [self stopSpinner];
                 
                 // Cache the results
                 NSString *path = [Utilities getDirectoryPath:@"stats-ios.json"];
                 [self.data writeToFile:path atomically:true];
                 return;
             }
         }
         
         // Old data is better than no data
         if(cache) {
             self.data = cache;
             [self stopSpinner];
             [tableView reloadData];
         }
     }];
}

// Find the date value for iOS platform
-(NSString *)filterPlatforms: (NSArray *)platforms withTableView:(UITableView *) tableView users:(int *)users
{
    NSDictionary *platform;
    for(platform in platforms) {
        if([[platform objectForKey:@"name"] isEqualToString:@"iOS"]){
            NSArray *days = [platform objectForKey:@"days"];
            NSString *count = [platform objectForKey:@"maxUsers"];
            if(count) *users = [count intValue];
            if(days) return [days lastObject];
            break;
        }
    }
    return nil;
}

// Prune the list before showing
-(NSArray *)filterHogs:(NSArray *)hogs
{
    NSMutableArray *result = [NSMutableArray new];
    NSDictionary *hog;
    for(hog in hogs){
        // Filter out hogs with too few users
        if([[hog objectForKey:@"users"] intValue] < 1000) continue;
        [result addObject:hog];
        
        // Stop when we have enough
        if([result count] >= 20) break;
    }
    return [result copy];
}

-(void)startSpinner{
    if(self.spinnerBackground){
        [self.spinnerBackground setHidden:NO];
    }
    if(self.spinner){
        [self.spinner startAnimating];
        [self.spinner setHidden:NO];
    }
}

-(void)stopSpinner{
    if(self.spinnerBackground){
        [self.spinnerBackground setHidden:YES];
    }
    if(self.spinner){
        [self.spinner stopAnimating];
        [self.spinner setHidden:YES];
    }
}

@end
