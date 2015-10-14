//
//  TouchView.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 12/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "TouchView.h"

@implementation TouchView

@synthesize delegate;

-(id) initWithFrame:(CGRect)frame
{
    self.userInteractionEnabled = YES;
    return [super initWithFrame:frame];
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
    self.userInteractionEnabled = YES;
    return [super initWithCoder:aDecoder];
}
-(void) awakeFromNib
{
    self.userInteractionEnabled = YES;
    [super awakeFromNib];
}
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [delegate touchDown:self];
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [delegate touchUp:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
