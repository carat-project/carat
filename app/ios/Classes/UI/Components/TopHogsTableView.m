//
//  TopHogsTableView.m
//  Carat
//
//  Created by Jonatan C Hamberg on 01/03/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import "CaratConstants.h"
#import "TopHogsTableView.h"
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
    return @"Worst hogs";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(data) return [data count];
    
    NSString *path = [Utilities getDirectoryPath:@"stats-ios.json"];
    NSDate *modified = [Utilities getLastModified:path];
    NSArray *cache = [NSArray arrayWithContentsOfFile:path];
    
    // Check if there is a fresh copy in cache
    NSLog(@"Days since last statistics check: %ld", [Utilities daysSince:modified]);
    if(cache && [Utilities daysSince:modified] < 1) {
        self.data = cache;
        return [data count];
    } else {
        [self loadDataFor:tableView withFallbackCache:cache];
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    if(self.data == nil) {
        return cell;
    } else {
        cell.textLabel.attributedText = [self decorateCellText:(int)indexPath.row];
    }
    return cell;
}

- (NSMutableAttributedString *) decorateCellText:(int)row{
    
    // Build cell text
    NSString *appName = [[self.data objectAtIndex: row] objectForKey:@"name"];
    NSString *samples = [NSString stringWithFormat:@"%@", [[self.data objectAtIndex: row] objectForKey:@"samples"]];
    NSString *label = [NSString stringWithFormat:@"%i) %@ %@ samples", row+1, appName, samples];
    
    // Stylize text
    NSRange range = NSMakeRange([label length]-([samples length]+8), [samples length]+8);
    NSMutableAttributedString *cellText = [[NSMutableAttributedString alloc] initWithString:label];
    [cellText addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:range];
    [cellText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11.0] range:range];
    
    return cellText;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // ...
}


// Download the latest list date
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
                 NSString *date = [self filterPlatforms:platforms withTableView:tableView];
                 if(date) {
                     // Find latest
                     NSString *path = [Utilities getDirectoryPath:@"stats-freshness"];
                     NSString *cachedDate = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
                     
                     // Avoid downloading the same data again
                     if(!cachedDate || ![cachedDate isEqualToString:date] || !cache) {
                         [self loadDataFor:tableView withDate:date withFallbackCache:cache];
                         [date writeToFile:path atomically:true encoding:NSUTF8StringEncoding error:&error];
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
-(NSString *)filterPlatforms: (NSArray *)platforms withTableView:(UITableView *) tableView;
{
    NSDictionary *platform;
    for(platform in platforms) {
        if([[platform objectForKey:@"name"] isEqualToString:@"iOS"]){
            NSArray *days = [platform objectForKey:@"days"];
            if(days) return [days lastObject];
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
