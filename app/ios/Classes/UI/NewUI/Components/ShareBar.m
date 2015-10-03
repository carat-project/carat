//
//  ShareBar.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 01/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "ShareBar.h"

@implementation ShareBar{
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:C_ORANGE];
        //self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Display our percentage as a string
    CGFloat widht = CGRectGetWidth(rect);
    CGFloat imageTopBottomPad = 14.0f;
    CGFloat imageTopPad = imageTopBottomPad/2.0f;
    CGFloat imageEdge = CGRectGetHeight(rect)-imageTopBottomPad;//four points padding
    NSLog(@"width: %f, imageEdge: %f", widht, imageEdge);
    
    CGFloat emptySpace = (widht * 0.6f - 3.0f * imageEdge)/2.0f;
    CGFloat faceBookLeft = widht * 0.2f;
    CGFloat twitterLeft = faceBookLeft + imageEdge + emptySpace;
    CGFloat emailLeft = twitterLeft + imageEdge + emptySpace;
    
    UIImage *facebookBtnImg = [UIImage imageNamed:@"facebook_icon"];
    UIImageView *facebookBtn = [[UIImageView alloc] initWithImage:facebookBtnImg];
    facebookBtn.frame = CGRectMake(faceBookLeft,  imageTopPad, imageEdge, imageEdge);
    [self addSubview:facebookBtn];
    
    UIImage *twitterBtnImg = [UIImage imageNamed:@"twitter_icon"];
    UIImageView *twitterBtn = [[UIImageView alloc] initWithImage:twitterBtnImg];
    twitterBtn.frame = CGRectMake(twitterLeft,  imageTopPad, imageEdge, imageEdge);
    [self addSubview:twitterBtn];
    
    UIImage *emailBtnImg = [UIImage imageNamed:@"email_icon"];
    UIImageView *emailBtn = [[UIImageView alloc] initWithImage:emailBtnImg];
    emailBtn.frame = CGRectMake(emailLeft,  imageTopPad, imageEdge, imageEdge);
    [self addSubview:emailBtn];
    
    /*
     UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
     singleTap.numberOfTapsRequired = 1;
     singleTap.numberOfTouchesRequired = 1;
     [shareBtn addGestureRecognizer:singleTap];
     [shareBtn setMultipleTouchEnabled:YES];
     [shareBtn setUserInteractionEnabled:YES];
     [singleTap release];
     */

}

- (IBAction)tapDetected:(id)sender
{
    
}
@end
