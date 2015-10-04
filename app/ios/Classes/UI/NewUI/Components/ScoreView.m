//
//  JScoreView.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 30/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "ScoreView.h"

@implementation ScoreView{
    int _score;
    NSString *_title;
    
    CGFloat startAngle;
    CGFloat endAngle;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        self.opaque = NO;
        //self.backgroundColor = [UIColor whiteColor];
        
        // Determine our start and stop angles for the arc (in radians)
        startAngle = M_PI * 1.5;
        endAngle = startAngle + (M_PI * 2);
        _title = @"";
        _score = 0;
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Display our percentage as a string
    NSString* textContent = [NSString stringWithFormat:@"%d", _score];
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    // Create our arc, with the correct angles
    CGFloat radius = (rect.size.width/2.0f)-2;
    NSLog(@"radius: %f", radius);
    int textSize = radius * 0.75;
    NSLog(@"textSize: %d", textSize);
    int textSizeSmall = textSize/3.0f;
    
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
    CGRect labelTextSize = [_title boundingRectWithSize:CGSizeMake(radius, CGFLOAT_MAX)
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
    [_title drawInRect:labelRect withAttributes:attributes];
    
   
    /*
     Deprecated
     [textContent drawInRect: textRect withFont: [UIFont fontWithName: @"HelveticaNeue" size: textSize] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
     
     [C_LIGHT_GRAY setFill];

     [_title drawInRect: labelRect withFont: [UIFont fontWithName: @"HelveticaNeue" size: textSizeSmall] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
     */
}


-(void)setTitle:(NSString *)title
{
    _title = title;
}
-(void)setScore:(int)score
{
    _score = score;
}

@end
