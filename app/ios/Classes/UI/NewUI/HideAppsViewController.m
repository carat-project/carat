//
//  HideAppsViewController.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 12/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "HideAppsViewController.h"

@interface HideAppsViewController ()

@end

@implementation HideAppsViewController{
    NSString *selectedValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _hideChoises = [[NSArray alloc] initWithObjects:NSLocalizedString(@"ShowAll", nil), NSLocalizedString(@"Five", nil),
                  NSLocalizedString(@"Ten", nil), NSLocalizedString(@"Twenty", nil), NSLocalizedString(@"Hour", nil), nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return _hideChoises.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return _hideChoises[row];
}


#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    selectedValue = _hideChoises[row];
    NSLog(@"hide option chosen: %@", _hideChoises[row]);
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
    [_hideChoises release];
    [super dealloc];
}
- (IBAction)selectClicked:(id)sender {
    NSLog(@"selectedValue: %@", selectedValue);
    [self.navigationController popViewControllerAnimated:YES];
}
@end
