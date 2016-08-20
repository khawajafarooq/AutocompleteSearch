//
//  DateTimePicker.h
//  AutocompleteSearch
//
//  Created by GIB on 6/12/16.
//
//

#import <UIKit/UIKit.h>

@interface GEDateTimePicker : UIView {
}

@property (nonatomic, assign, readonly) UIDatePicker *picker;

- (void) setMode: (UIDatePickerMode) mode;
- (void) addTargetForDoneButton: (id) target action: (SEL) action;
- (void) addTargetForCancelButton: (id) target action: (SEL) action;

@end
