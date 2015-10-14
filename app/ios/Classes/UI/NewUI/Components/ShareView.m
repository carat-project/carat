//
//  ShareView.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 01/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//
/*
 Creates share button that will expand to bar that fill horizontally whole view width. This bar contains share option buttons.
 */
#import "ShareView.h"

@implementation ShareView{

    bool _isBarState; //if share button has been pressed and share choises are displayed in horizontal bar
    CGFloat top;
    CGFloat buttonLeft;
    CGFloat buttonEdge;
    ShareBar* shareBar;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isBarState = false;
        top = CGRectGetMinY(frame);
        buttonLeft = CGRectGetMinX(frame);
        buttonEdge = CGRectGetMaxX(frame) - buttonLeft;
        NSLog(@"button left: %f button edge: %f", buttonLeft, buttonEdge);
        NSLog(@"button top: %f", top);
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        self.opaque = NO;
        //self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Display our percentage as a string
    [self.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)]; //clear view
    if(_isBarState){
        NSLog(@"create sharebar");
        self.frame = CGRectMake(0,  top,  UI_SCREEN_W, buttonEdge);
        shareBar = [[ShareBar alloc] initWithFrame:CGRectMake(0, 7, UI_SCREEN_W, buttonEdge-14)];
        shareBar.delegate = self;
        [self addSubview:shareBar];
    }
    else{
        [ShareBar release];
        self.frame = CGRectMake(buttonLeft,  top, buttonEdge, buttonEdge);
        UIImage *shareBtnImg = [UIImage imageNamed:@"share_btn"];
        UIImageView *shareBtn = [[UIImageView alloc] initWithImage:shareBtnImg];
        shareBtn.frame = CGRectMake(0,  0, buttonEdge, buttonEdge);

        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [shareBtn addGestureRecognizer:singleTap];
        [shareBtn setMultipleTouchEnabled:YES];
        [shareBtn setUserInteractionEnabled:YES];
        [singleTap release];
        
        [self addSubview:shareBtn];
    }
}

- (IBAction)tapDetected:(id)sender
{
     NSLog(@"single Tap on imageview");
    _isBarState = !_isBarState;
     if (_isBarState) {
        NSLog(@"show share bar");
         [self drawRect:self.frame];
     }
     else{
         NSLog(@"show share button");
         [self drawRect:self.frame];
     }
    
}

- (void)faceBookPressed{
     NSLog(@"faceBookPressed");
}
- (void)twitterPressed{
     NSLog(@"twitterPressed");
}

- (void)emailPressed{
     NSLog(@"emailPressed");
}

- (void)closePressed{
    NSLog(@"closePressed");
    [self tapDetected:nil];
}


- (void)dealloc {
    [ShareBar release];
    
    [super dealloc];
}



@end
