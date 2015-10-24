//
//  WebInfoViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 23/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "BaseViewController.h"

@interface WebInfoViewController : BaseViewController
@property (assign, nonatomic) NSString *titleForView;
@property (assign, nonatomic) NSString *webUrl;
@property (retain, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain, nonatomic) IBOutlet UIWebView *webView;

@end
