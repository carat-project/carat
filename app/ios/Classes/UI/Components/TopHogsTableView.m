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

- (void)attachSpinner:(UIActivityIndicatorView *)spinner withBackground:(UIView *)spinnerBackGround
{
    self.spinner = spinner;
    self.spinnerBackground = spinnerBackGround;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!self.data) {
        NSString *path = [Utilities getDirectoryPath:@"android.jasdson"];
        NSArray *cached = [NSArray arrayWithContentsOfFile:path];
        if(!cached) {
            self.data = [NSArray new];
            
            // Start spinner if attached
            if(self.spinner){
               [self.spinner startAnimating];
            }
            
            // Begin loading data asynchronously
            [self loadDataFor:tableView];
            return 0;
        }
    }
    return [data count];
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
        NSString * rank = [NSString stringWithFormat:@"%d) ", indexPath.row+1];
        NSString * appName = [[self.data objectAtIndex: indexPath.row] objectForKey:@"name"];
        NSString * app = [rank stringByAppendingString:appName];
        cell.textLabel.text = app;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // ...
}



-(void) loadDataFor:(UITableView *) tableView{
    NSString *dataURL = [kStatisticsDataURI stringByAppendingString:@"data.json"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:dataURL]];
    __block NSArray *platforms;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *receivedData, NSError *connectionError) {
         if(receivedData != nil) {
             NSError *error = nil;
             platforms = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&error];
             if(error == nil) {
                 NSString *date = [self filterPlatforms:platforms withTableView:tableView];
                 if(date) {
                     [self loadDataFor:tableView withDate:date];
                 }
             }
         }
     }];
}

-(void)loadDataFor:(UITableView *)tableView withDate:(NSString *)date
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
                 
                 // Stop spinner if attached
                 if(self.spinner) {
                     [self.spinnerBackground setHidden:YES];
                     [self.spinner stopAnimating];
                     [self.spinner setHidden:YES];
                 }
                 
                 // Cache the results
                 NSString *path = [Utilities getDirectoryPath:@"android.json"];
                 [self.data writeToFile:path atomically:true];
             }
         }
     }];
}

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

-(NSArray *)filterHogs:(NSArray *)hogs
{
    NSMutableArray *result = [NSMutableArray new];
    NSDictionary *hog;
    for(hog in hogs){
        // Filter out hogs with too few users
        if([[hog objectForKey:@"users"] intValue] < 5000) continue;
        [result addObject:hog];
        
        // Stop when we have enough
        if([result count] >= 10) break;
    }
    
    // Use copy for optimizations
    return [result copy];
}

@end
