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
    float selectedValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _hideChoises = [[NSArray alloc] initWithObjects:NSLocalizedString(@"ShowAll", nil), NSLocalizedString(@"Five", nil),
                  NSLocalizedString(@"Ten", nil), NSLocalizedString(@"Twenty", nil), NSLocalizedString(@"Hour", nil), nil];
    float limit = [[Globals instance] getHideConsumptionLimit];
    int selectedRow;
    if(limit == 0.0f){
        selectedRow = 0;
    }
    else if(limit == 300.0f){
        selectedRow = 1;
    }
    else if(limit == 600.0f){
        selectedRow = 2;
    }
    else if(limit == 1200.0f){
        selectedRow = 3;
    }
    else if(limit == 3600.0f){
        selectedRow = 4;
    }
    [_pickerView selectRow:selectedRow inComponent:0 animated:YES];

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
    switch (row) {
        case 0:
            selectedValue = 0.0f;
            break;
        case 1:
            selectedValue = 5.0f*60.0f;
            break;
        case 2:
            selectedValue = 10.0f*60.0f;
            break;
        case 3:
            selectedValue = 20.0f*60.0f;
            break;
        case 4:
            selectedValue = 60.0f*60.0f;
            break;
            
        default:
            break;
    }
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
    [_pickerView release];
    [super dealloc];
}
- (IBAction)selectClicked:(id)sender {
    NSLog(@"selectedValue: %f", selectedValue);
    [[Globals instance] setHideConsumptionLimit: selectedValue];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
