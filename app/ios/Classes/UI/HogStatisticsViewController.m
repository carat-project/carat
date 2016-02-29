//
//  HogStatisticsViewController.m
//  Carat
//
//  Created by Jonatan C Hamberg on 29/02/16.
//  Copyright © 2016 University of Helsinki. All rights reserved.
//

#import "HogStatisticsViewController.h"

@interface HogStatisticsViewController ()

@end

@implementation HogStatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://carat.cs.helsinki.fi/statistics-data/apps/2016-02-21-android.json"]];
    __block NSDictionary *hogsJSON;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if(data != nil){
                                   NSError *error = nil;
                                   hogsJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   if(error == nil){
                                       _debugLabel.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   }
                               }
                           }];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [_debugLabel release];
    [super dealloc];
}
@end
