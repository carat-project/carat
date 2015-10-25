//
//  ProgressUpdateView.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 25/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "ProgressUpdateView.h"
@interface ProgressUpdateView ()
@property (nonatomic, strong) NSMutableArray *customConstraints;
@end
@implementation ProgressUpdateView
-(void)awakeFromNib {
    //Note That You Must Change @”BNYSharedView’ With Whatever Your Nib Is Named
    
    [self commonInit];
}

- (void)commonInit
{
    _customConstraints = [[NSMutableArray alloc] init];
    //ProgressStatusView NSStringFromClass([self class])
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview: self.contentView];
    [self setNeedsUpdateConstraints];
    
}

- (void)updateConstraints
{
    [self removeConstraints:self.customConstraints];
    [self.customConstraints removeAllObjects];
    
    if (self.contentView != nil) {
        UIView *view = self.contentView;
        NSDictionary *views = NSDictionaryOfVariableBindings(view);
        
        [self.customConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:
          @"H:|[view]|" options:0 metrics:nil views:views]];
        [self.customConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:
          @"V:|[view]|" options:0 metrics:nil views:views]];
        
        [self addConstraints:self.customConstraints];
    }
    
    [super updateConstraints];
}



- (void)dealloc {
    [_contentView release];
    [_label release];
    [_actIndicator release];
    [super dealloc];
}
@end
