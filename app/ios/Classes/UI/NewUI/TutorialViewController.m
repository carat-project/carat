//
//  TutorialViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 04/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "TutorialViewController.h"
#import "DashBoardViewController.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pagePos = 0;
    _pageCount = 3;
    [_pageIndicatorView setPageCount:_pageCount];
    
    [self createTutorialData];
    [self setPage:_pagePos];
    NSLog(@"******TutorialViewController viewDidLoad******");
    
    // Do any additional setup after loading the view.
     /*
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [recognizer setNumberOfTouchesRequired:1];
    [_ImageView addGestureRecognizer:recognizer];
    
   
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [_ImageView addGestureRecognizer:swipeLeft];
    [_ImageView addGestureRecognizer:swipeRight];
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)acceptPressed{
    NSLog(@"****** acceptPressed *******");
    DashBoardViewController *controler = [[DashBoardViewController alloc]initWithNibName:@"DashBoardViewController" bundle:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)rightSwipe{
     NSLog(@"Right Swipe");
    if(_pagePos -1 >= 0){
        [self setPage:(_pagePos-1)];
    }
}

-(IBAction)leftSwipe{
    NSLog(@"Left Swipe");
    if(_pagePos+1 < _pageCount){
        [self setPage:(_pagePos+1)];
    }
}

- (void)createTutorialData
{
    NSLog(@"****** createTutorialData ********");
    TutorialPageContent *main = [TutorialPageContent new];
    TutorialPageContent *bugs = [TutorialPageContent new];
    TutorialPageContent *hogs = [TutorialPageContent new];

    main.title = NSLocalizedString(@"MainTitle", nil);
    bugs.title = NSLocalizedString(@"Bugs", nil);
    hogs.title = NSLocalizedString(@"Hogs", nil);
    
    main.text = NSLocalizedString(@"MainDesc", nil);
    bugs.text = NSLocalizedString(@"BugsDesc", nil);
    hogs.text = NSLocalizedString(@"HogsDesc", nil);
    
    main.imageName = @"tutorial_01";
    bugs.imageName = @"tutorial_02";
    hogs.imageName = @"tutorial_03";
    
    _pageDataContent = [[NSArray alloc] initWithObjects:main, bugs, hogs, nil];

     NSLog(@"****** Check created data title ******** %@", ((TutorialPageContent*)_pageDataContent[1]).title);
    
}

-(void)setPage:(int) pageNumber
{
     NSLog(@"****** setPage pageNumber: ******** %d", pageNumber);
    _pagePos = pageNumber;
    TutorialPageContent* pageCont = _pageDataContent[pageNumber];
     NSLog(@"****** setPage title ******** %@", pageCont.title);
    [_ImageView setImage:[UIImage imageNamed:pageCont.imageName]];
    [_tutorialPageTitle setText:pageCont.title];
    [_tutorialPageDescription setText:pageCont.text];
    [_pageIndicatorView setPagePositionAs:pageNumber];
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
    [_ImageView release];
    [_pageIndicatorView release];
    [_acceptButton release];
    [_tutorialPageTitle release];
    [_tutorialPageDescription release];
    [_pageDataContent release];
    [super dealloc];
}

@end
