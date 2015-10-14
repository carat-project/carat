//
//  InfoViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 13/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()
@end

@implementation InfoViewController{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _navigationItemRef.title = NSLocalizedString(_titleForView, nil);
    _labelRef.text = NSLocalizedString(_messageForView, nil);
    
    CGFloat labelMargin = 12.0f;
    //CGFloat naviBottom = _navigationBar.frame.origin.y + _navigationBar.frame.size.height;
    CGFloat textHeight = [self getLabelTextHeight];
    CGFloat labelMargins = (labelMargin * 2.0f);
    CGFloat height = textHeight + labelMargins;
    _contentHeightConstraint.constant = height;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)getLabelTextHeight
{
    NSDictionary *attributes = @{NSFontAttributeName: _labelRef.font};
    CGFloat textMaxWidth = UI_SCREEN_W - (12.0f * 2.0);
    CGRect textSize = [_labelRef.text boundingRectWithSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    return textSize.size.height;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_labelRef release];
    [_navigationItemRef release];
    [_contentView release];
    [_navigationBar release];
    [_contentHeightConstraint release];
    [super dealloc];
}
@end
