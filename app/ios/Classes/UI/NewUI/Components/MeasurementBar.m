//
//  MeasurementBar.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 07/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "MeasurementBar.h"
#import "AppColors.h"

@interface MeasurementBar ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableArray *customConstraints;
@end

@implementation MeasurementBar{
    UIImage *_measureTopImg;
}

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
    // Initialization code
    UIView *view = nil;
    _measureTopImg = [UIImage imageNamed:@"measurebar_top"];
    [self setBackgroundColor:C_LIGHT_GRAY];
    
    /*
     NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"DashboardNavigationButton"
     owner:self
     options:nil];
     for (id object in objects) {
     if ([object isKindOfClass:[UIView class]]) {
     view = object;
     break;
     }
     }
     */
    if (view != nil) {
        _containerView = view;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        [self setNeedsUpdateConstraints];
    }
    
}

- (void)drawRect:(CGRect)rect
{
    //[super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if(_largerMeasureValue > 0){
        CGRect rectangle = [self getDrawRectangle:_largerMeasureValue];
        CGContextSetFillColor(ctx, CGColorGetComponents([_largerBarColor CGColor]));
        CGContextSetStrokeColor(ctx, CGColorGetComponents([_largerBarColor CGColor]));
        CGContextFillRect(ctx, rectangle);
    }
    if(_smallerMeasureValue > 0){
        CGRect rectangle = [self getDrawRectangle:_smallerMeasureValue];
        CGContextSetFillColor(ctx, CGColorGetComponents([_smallerBarColor CGColor]));
        CGContextSetStrokeColor(ctx, CGColorGetComponents([_smallerBarColor CGColor]));
        CGContextFillRect(ctx, rectangle);
    }
    
    if(_measureTopImg != nil){
        _measureTopImg = [UIImage imageNamed:@"measurebar_top"];
    }
    CGRect imgRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [_measureTopImg drawInRect:imgRect];
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

-(CGRect) getDrawRectangle:(CGFloat) value{
    CGFloat pros = value/99;
    CGFloat width = self.frame.size.width * pros;
    return CGRectMake(0, 0, width, self.frame.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [_measureTopImg release];
    [_largerBarColor release];
    [_smallerBarColor release];
    
    [super dealloc];
}
@end
