//
//  TouchView.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 12/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchViewDelegate.h"

@interface TouchView : UIView {
    id <TouchViewDelegate>  delegate;
}
@property (assign) id delegate;
@end


