//
//  TopHogsTableView.m
//  Carat
//
//  Created by Jonatan C Hamberg on 01/03/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import "TopHogsTableView.h"

@implementation TopHogsTableView
@synthesize data;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!self.data) {
        self.data = [NSArray new];
        [self fetchData:tableView];
       return 0;
    }
    else {
      return [data count]-1;
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
        NSString * rank = [NSString stringWithFormat:@"%d) ", indexPath.row+1];
        NSString * appName = [[self.data objectAtIndex: indexPath.row] objectForKey:@"name"];
        NSString * app = [rank stringByAppendingString:appName];
        cell.textLabel.text = app;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void) fetchData:(UITableView *)tableView
{
    NSLog(@"Fetching top hogs data");
    NSString *dataURL = @"http://carat.cs.helsinki.fi/statistics-data/apps/2016-02-21-android.json";
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:dataURL]];
    __block NSArray *hogsJSON;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *receivedData, NSError *connectionError) {
         if(receivedData != nil){
             NSError *error = nil;
             hogsJSON = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&error];
             if(error == nil){
                 self.data = hogsJSON;
                 [tableView reloadData];
             }
         }
     }];
}

@end
