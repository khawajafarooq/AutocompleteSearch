//
//  GEMainViewController.m
//  AutocompleteSearch
//
//  Created by GIB on 6/12/16.
//
//

#import "GEMainViewController.h"
#import "UIViewController+KeyboardFeature.h"
#import "NSString+Common.h"
#import "GEDateTimePicker.h"
#import "GEGeoSearchService.h"
#import "GEGeoSearchServiceRequest.h"
#import "GEGeoSearchServiceResponse.h"
#import "GEAutocompleteTextSearch.h"
#import "GEConstants.h"
#import "GEUtility.h"

@interface GEMainViewController () 
@property (strong, nonatomic) IBOutlet GEAutocompleteTextSearch *fromLocationTextField;
@property (strong, nonatomic) IBOutlet GEAutocompleteTextSearch *toLocationTextField;
@property (strong, nonatomic) IBOutlet UITextField *dateTextField;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UILabel *errorMessageLabel;
@property (strong, nonatomic) GEDateTimePicker *datePickerView;
@property (strong, nonatomic) GEGeoSearchService *searchService;
@property (strong, nonatomic) GEGeoSearchServiceRequest *searchServiceRequest;
@property (strong, nonatomic) NSArray *filteredSearch;

@property (nonatomic, getter=isDatePickerDisplayed) BOOL datePickerDisplayed;

@end

@implementation GEMainViewController

#pragma mark - lazy properties
- (GEDateTimePicker*)datePickerView {
    if (_datePickerView == nil) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat yOffset = (screenRect.size.height/2.0) - 35.0f;
        CGFloat heightOffset = (screenRect.size.height/2.0) + 35.0f;
        
        _datePickerView = [[GEDateTimePicker alloc] initWithFrame:CGRectMake(0, yOffset, screenRect.size.width, heightOffset)];
        _datePickerView.backgroundColor = [UIColor whiteColor];
    }
    return _datePickerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (IBAction)datePickerClicked:(id)sender {
    if (self.isDatePickerDisplayed == false) {
        [self showDatePicker];
    }
    
}

- (IBAction)searchClicked:(id)sender {
    [self displayError:YES];
}

#pragma mark - Helper Methods
- (void)configureView {
    // hide controls as per requirement
    [self displayError:NO];
    [self displaySearchButton:NO];
    
    // configure date picker
    [self configureDatePicker];
    [self displayDatePicker:NO];
    
    // register tap gesture for keyboard dismissal
    // TODO: adding UITapGestureRecognizer is somehow blocking tableview cell selection inside GEAutocompleteTextSearch - fix required
    //[self hideKeyboardWhenTappedAround];
}

- (void)displayError:(BOOL)flag {
    self.errorMessageLabel.hidden = !flag;
}

- (void)displaySearchButton:(BOOL)flag {
    self.searchButton.hidden = !flag;
}

- (void)validateSearch {
    // Display search button if all fields are filled
    if (![self.fromLocationTextField.text isEmpty] &&
        ![self.toLocationTextField.text isEmpty] &&
        ![self.dateTextField.text isEmpty]) {
        [self displaySearchButton:YES];
    }
    else {
        [self displayError:NO];
        [self displaySearchButton:NO];
    }
}

- (void)closeAutocompleteSearch {
    [self.fromLocationTextField closeTableView];
    [self.toLocationTextField closeTableView];
}

#pragma mark - DatePicker Methods
- (void)showDatePicker {
    CGFloat yOffsetHidden = CGRectGetHeight(self.view.frame) + CGRectGetHeight(self.datePickerView.frame);
    self.datePickerView.frame = RectSetOriginY(self.datePickerView.frame, yOffsetHidden);
    
    [self displayDatePicker:YES];
    [UIView animateWithDuration:1.0
                     animations:^{
                         
                         CGFloat yOffset = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.datePickerView.frame);
                         self.datePickerView.frame = RectSetOriginY(self.datePickerView.frame, yOffset);
                     }];
}

- (void)hideDatePicker {
    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         CGFloat yOffsetHidden = CGRectGetHeight(self.view.frame) + CGRectGetHeight(self.datePickerView.frame);
                         self.datePickerView.frame = RectSetOriginY(self.datePickerView.frame, yOffsetHidden);
                     } completion:^(BOOL finished) {
                         
                         [self displayDatePicker:NO];
                     }];
}

- (void)doneAction {
    [self pickerChanged];
    [self hideDatePicker];
    [self validateSearch];
}

-(void)pickerChanged {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    NSString *dateToDisplay = [formatter stringFromDate:[self.datePickerView.picker date]];
    
    self.dateTextField.text = dateToDisplay;
}

- (void)displayDatePicker:(BOOL)flag {
    self.datePickerView.hidden = !flag;
    self.datePickerDisplayed = flag;
}

- (void)configureDatePicker {
    [self.datePickerView addTargetForDoneButton:self action:@selector(doneAction)];
    [self.datePickerView addTargetForCancelButton:self action:@selector(hideDatePicker)];
    [self.view addSubview:self.datePickerView];
    
    self.datePickerView.picker.minimumDate = [NSDate date];
    [self.datePickerView setMode:UIDatePickerModeDate];
    [self.datePickerView.picker addTarget:self action:@selector(pickerChanged) forControlEvents:UIControlEventValueChanged];
    self.datePickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // display date picker
    if (textField == self.dateTextField) {
        if (self.isDatePickerDisplayed == false) {
            [self closeAutocompleteSearch];
            [self showDatePicker];
        }
        return NO;
    }
    else {
        
        if (textField == self.fromLocationTextField) {
            [self.toLocationTextField closeTableView];
        }
        else if(textField == self.toLocationTextField) {
            [self.fromLocationTextField closeTableView];
        }
        
        [self hideDatePicker];
        
        return YES;
    }
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [self closeAutocompleteSearch];
    [self validateSearch];
    [textField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *query;
    
    // backspace remove
    if ([string isEmpty] && ![textField.text isEmpty]) {
        query = [textField.text substringToIndex:[textField.text length]-1];
    }
    else {
        query = [textField.text stringByAppendingString:string];
    }
    
    // valid characters set
    if (![VALID_CHARECTERS_SET containsString:string] && ![string isEmpty]) {
        return NO;
    }
    else if ([query isEmpty]) {
        return YES;
    }
    
    // going to search locations
    if (textField == self.fromLocationTextField) {
        [self.fromLocationTextField searchAutocompleteEntriesWithSubstring:query];
    }
    else if (textField == self.toLocationTextField) {
        [self.toLocationTextField searchAutocompleteEntriesWithSubstring:query];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
