//
//  DashboardNavigationButton.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 04/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "DashboardNavigationButton.h"

@interface DashboardNavigationButton ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableArray *customConstraints;
@end

@implementation DashboardNavigationButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _customConstraints = [[NSMutableArray alloc] init];
    
    UIView *view = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"DashboardNavigationButton"
                                                     owner:self
                                                   options:nil];
    for (id object in objects) {
        if ([object isKindOfClass:[UIView class]]) {
            view = object;
            break;
        }
    }
    
    if (view != nil) {
        _containerView = view;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        [self setNeedsUpdateConstraints];
    }
}

- (void)updateConstraints
{
    [self removeConstraints:self.customConstraints];
    [self.customConstraints removeAllObjects];
    
    if (self.containerView != nil) {
        UIView *view = self.containerView;
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

-(void)setButtonImage:(UIImage *)image
{
    [_dashboardButtonImage setImage:image];
}

-(void)setButtonExtraInfo:(NSString *)info
{
    [_dashboardButtonExtra setText:info];
    //_dashboardButtonExtra.textAlignment = NSTextAlignmentCenter;
}

-(void)setButtonTitle:(NSString *)title
{
    [_dashboardButtonTitle setText:title];
    //_dashboardButtonTitle.textAlignment = NSTextAlignmentCenter;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [_dashboardButtonImage release];
    [_dashboardButtonExtra release];
    [_dashboardButtonTitle release];
    [_dashboardButtonImage release];
    [super dealloc];
}
@end
