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
    MBProgressHUD *HUD;
}


- (void)loadDataWithHUD:(id)obj;
- (void)initHUD:(NSString *) hudLabel selector: (SEL)selector;


@end
