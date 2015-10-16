//
//  JScoreView.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 30/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "ScoreView.h"

@interface ScoreView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableArray *customConstraints;
@end

@implementation ScoreView{
    CGFloat startAngle;
    CGFloat endAngle;
    
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
    //self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    self.backgroundColor = [UIColor clearColor];

    self.opaque = NO;
    //self.backgroundColor = [UIColor whiteColor];
    
    // Determine our start and stop angles for the arc (in radians)
    startAngle = M_PI * 1.5;
    endAngle = startAngle + (M_PI * 2);
    
    UIView *view = nil;
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
    NSString* textContent = [NSString stringWithFormat:@"%ld", (long)_score];
    if(_score == 0){
        textContent = NSLocalizedString(@"NA", nil);
    }
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    // Create our arc, with the correct angles
    CGFloat radius = (rect.size.width/2.0f)-2;
    NSLog(@"radius: %f", radius);
    int textSize = radius * 0.55;
    NSLog(@"textSize: %d", textSize);
    int textSizeSmall = textSize/2.0f;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([C_WHITE CGColor]));
    CGContextFillPath(ctx);

    [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius: radius
                      startAngle:startAngle
                        endAngle:(endAngle - startAngle) * (_score / 99.0) + startAngle
                       clockwise:YES];
    
    // Set the display for the path, and stroke it
    bezierPath.lineWidth = 4;
    [C_ORANGE_LIGHT setStroke];
    [bezierPath stroke];
    
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:textSize]};
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    CGRect scoreSize = [textContent boundingRectWithSize:CGSizeMake(radius, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
    attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:textSizeSmall]};
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    CGRect labelTextSize = [_scoreTitle boundingRectWithSize:CGSizeMake(radius, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:attributes
                                                 context:nil];
    

    CGRect textRect = CGRectMake((rect.size.width / 2.0) - scoreSize.size.width/2.0, (rect.size.height / 2.0) - scoreSize.size.height/2.0, scoreSize.size.width, scoreSize.size.height);
    CGRect labelRect = CGRectMake((rect.size.width / 2.0) - labelTextSize.size.width/2.0, CGRectGetMaxY(textRect), labelTextSize.size.width, labelTextSize.size.height);
    
    [[UIColor blackColor] setFill];
// Text Drawing
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:textSize];
    
    /// Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    attributes = @{ NSFontAttributeName: font,
                    NSParagraphStyleAttributeName: paragraphStyle};
    
    [textContent drawInRect:textRect withAttributes:attributes];

    font = [UIFont fontWithName:@"HelveticaNeue" size:textSizeSmall];
    
    attributes = @{ NSFontAttributeName: font,
                    NSParagraphStyleAttributeName: paragraphStyle,
                    NSForegroundColorAttributeName: C_LIGHT_GRAY};
    [_scoreTitle drawInRect:labelRect withAttributes:attributes];
    
   
    /*
     Deprecated
     [textContent drawInRect: textRect withFont: [UIFont fontWithName: @"HelveticaNeue" size: textSize] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
     
     [C_LIGHT_GRAY setFill];

     [_title drawInRect: labelRect withFont: [UIFont fontWithName: @"HelveticaNeue" size: textSizeSmall] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
     */
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
}


-(void)setTitle:(NSString *)title
{
    _scoreTitle = title;
}
-(void)setScore:(int)score
{
    _score = score;
}

- (void)dealloc {
    [_containerView release];
    [_scoreTitle release];
    [_customConstraints release];
    
    [super dealloc];
}


@end
