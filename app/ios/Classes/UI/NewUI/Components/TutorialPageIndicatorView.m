//
//  TutorialPageIndicatorView.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 05/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "TutorialPageIndicatorView.h"

@interface TutorialPageIndicatorView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableArray *customConstraints;
@end

@implementation TutorialPageIndicatorView{

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
    _pageCount = 3;
    _pagePosition = 0; //first page
    
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

- (void)drawRect:(CGRect)rect
{
    // Display our percentage as a string
    CGFloat ballEdge = self.frame.size.height;
    CGFloat left = 0;
    for(int i=0; i<_pageCount; i++){
        if(i != 0){
            left += ballEdge;
            CGFloat padding = ballEdge*0.3f;
            left += padding;
        }
        
        CGRect ballFrame = CGRectMake(left, 0, ballEdge, ballEdge);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextAddEllipseInRect(ctx, ballFrame);
        if(i == _pagePosition){
            CGContextSetFillColor(ctx, CGColorGetComponents([C_ORANGE CGColor]));
        }
        else{
            CGContextSetFillColor(ctx, CGColorGetComponents([C_LIGHT_GRAY CGColor]));
        }
        CGContextFillPath(ctx);
    }
}

-(void)setPageCount:(int) pageCount{
    NSLog(@"setPageCount");
    _pageCount = pageCount;
    CGFloat ballEdge = self.frame.size.height;
    CGFloat viewNewWidth = ballEdge * pageCount +  (ballEdge*0.3f)*(pageCount-1);
    CGRect frameRect = self.frame;
    frameRect.size.width = viewNewWidth;
    self.frame = frameRect;
    [self setNeedsDisplay] ;
}

-(void)setPagePositionAs:(int) pagePosition{
    NSLog(@"set Page position");
    _pagePosition = pagePosition;
    [self setNeedsDisplay];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)dealloc {
    [_containerView release];
    [_customConstraints release];
    [super dealloc];
    
}
@end
