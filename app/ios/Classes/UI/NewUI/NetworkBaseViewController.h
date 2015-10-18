//
//  NetworkBaseViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 16/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"

@interface NetworkBaseViewController : BaseViewController <MBProgressHUDDelegate> {
}


- (void)loadDataWithHUD:(id)obj;
- (void)hudWasHidden:(MBProgressHUD *)hud;

- (void) updateNetworkStatus:(NSNotification *) notice;
- (BOOL) isFresh;
- (void)updateView; //use this function to update gui from data
@end
