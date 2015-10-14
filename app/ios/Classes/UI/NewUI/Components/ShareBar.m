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
@synthesize delegate;


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
    CGFloat width = CGRectGetWidth(rect);
    CGFloat imageTopBottomPad = 14.0f;
    CGFloat imageTopPad = imageTopBottomPad/2.0f;
    CGFloat imageEdge = CGRectGetHeight(rect)-imageTopBottomPad;//four points padding
    CGFloat closeEdge = imageEdge;
    NSLog(@"width: %f, imageEdge: %f", width, imageEdge);
    
    CGFloat emptySpace = ((width-closeEdge-15) * 0.6f - 3.0f * imageEdge)/2.0f;
    CGFloat faceBookLeft = (width-closeEdge-15) * 0.2f;
    CGFloat twitterLeft = faceBookLeft + imageEdge + emptySpace;
    CGFloat emailLeft = twitterLeft + imageEdge + emptySpace;
    
    UIImage *facebookBtnImg = [UIImage imageNamed:@"facebook_icon"];
    UIImageView *facebookBtn = [[UIImageView alloc] initWithImage:facebookBtnImg];
    facebookBtn.frame = CGRectMake(faceBookLeft,  imageTopPad, imageEdge, imageEdge);
    
    UITapGestureRecognizer *facebookTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(facebookTapped)];
    facebookTap.numberOfTapsRequired = 1;
    facebookTap.numberOfTouchesRequired = 1;
    [facebookBtn setUserInteractionEnabled:YES];
    [facebookBtn setMultipleTouchEnabled:YES];
    [facebookBtn addGestureRecognizer:facebookTap];
    
    [self addSubview:facebookBtn];
    
    UIImage *twitterBtnImg = [UIImage imageNamed:@"twitter_icon"];
    UIImageView *twitterBtn = [[UIImageView alloc] initWithImage:twitterBtnImg];
    twitterBtn.frame = CGRectMake(twitterLeft,  imageTopPad, imageEdge, imageEdge);
    
    UITapGestureRecognizer *twitterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twitterTapped)];
    twitterTap.numberOfTapsRequired = 1;
    twitterTap.numberOfTouchesRequired = 1;
    [twitterBtn setUserInteractionEnabled:YES];
    [twitterBtn setMultipleTouchEnabled:YES];
    [twitterBtn addGestureRecognizer:twitterTap];
    
    [self addSubview:twitterBtn];
    
    UIImage *emailBtnImg = [UIImage imageNamed:@"email_icon"];
    UIImageView *emailBtn = [[UIImageView alloc] initWithImage:emailBtnImg];
    emailBtn.frame = CGRectMake(emailLeft,  imageTopPad, imageEdge, imageEdge);
    
    UITapGestureRecognizer *emailTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emailTapped)];
    emailTap.numberOfTapsRequired = 1;
    emailTap.numberOfTouchesRequired = 1;
    [emailBtn setUserInteractionEnabled:YES];
    [emailBtn setMultipleTouchEnabled:YES];
    [emailBtn addGestureRecognizer:emailTap];
    
    [self addSubview:emailBtn];
    
    
    CGFloat closeLeft = width - (closeEdge + 15);
    UIImage *closeBtnImg = [UIImage imageNamed:@"close_icon"];
    UIImageView *closeBtn = [[UIImageView alloc] initWithImage:closeBtnImg];
    closeBtn.frame = CGRectMake(closeLeft,  imageTopPad, closeEdge, closeEdge);
    
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTapped)];
    closeTap.numberOfTapsRequired = 1;
    closeTap.numberOfTouchesRequired = 1;
    [closeBtn setUserInteractionEnabled:YES];
    [closeBtn setMultipleTouchEnabled:YES];
    [closeBtn addGestureRecognizer:closeTap];
    
    [self addSubview:closeBtn];
    
    
    
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

-(void)setDelegate:(id)aDelegate
{
    delegate = aDelegate;
}
-(void)closeTapped
{
    NSLog(@"closeTapped");
    [delegate closePressed];
}
-(void)emailTapped
{
    NSLog(@"emailTapped");
    [delegate emailPressed];
}
-(void)twitterTapped
{
    NSLog(@"twitterTapped");
    [delegate twitterPressed];
}
-(void)facebookTapped
{
    NSLog(@"facebookTapped");
    [delegate faceBookPressed];
}

- (void)dealloc {
    [super dealloc];
}

@end
