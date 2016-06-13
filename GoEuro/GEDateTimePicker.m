//
//  DateTimePicker.m
//  GoEuro
//
//  Created by GIB on 6/12/16.
//
//

#import "GEDateTimePicker.h"
#define DateTimePickerToolbarHeight 40

@interface GEDateTimePicker()

@property (nonatomic, assign, readwrite) UIDatePicker *picker;

@property (nonatomic, assign) id doneTarget;
@property (nonatomic, assign) id cancelTarget;
@property (nonatomic, assign) SEL doneSelector;
@property (nonatomic, assign) SEL cancelSelector;

- (void)donePressed;
- (void)addToolbar;

@end


@implementation GEDateTimePicker

@synthesize picker = _picker;

@synthesize doneTarget = _doneTarget;
@synthesize cancelTarget = _cancelTarget;
@synthesize doneSelector = _doneSelector;
@synthesize cancelSelector = _cancelSelector;

- (id) initWithFrame: (CGRect) frame {
    if ((self = [super initWithFrame: frame])) {
        
        self.backgroundColor = [UIColor clearColor];
        
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame: CGRectMake(0, DateTimePickerToolbarHeight, frame.size.width, frame.size.height - DateTimePickerToolbarHeight)];
        [self addSubview: picker];
        
        [self addToolbar];
        
        self.picker = picker;
        picker.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return self;
}

- (void)addToolbar {
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:
                          CGRectMake(0, 0, CGRectGetWidth(self.frame), DateTimePickerToolbarHeight)];
    
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                   target:self action:@selector(donePressed)];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                     target:self action:@selector(cancelPressed)];
    
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    
    toolbar.items = [NSArray arrayWithObjects:cancelButton,flexibleSpace, saveButton, nil];
    
    [self addSubview:toolbar];
}

- (void) setMode: (UIDatePickerMode) mode {
    self.picker.datePickerMode = mode;
}

- (void) donePressed {
    if (self.doneTarget) {
        [self.doneTarget performSelector:self.doneSelector withObject:nil afterDelay:0];
    }
}

- (void) cancelPressed {
    if (self.cancelTarget) {
        [self.cancelTarget performSelector:self.cancelSelector withObject:nil afterDelay:0];
    }
}

- (void) addTargetForDoneButton: (id) target action: (SEL) action {
    self.doneTarget = target;
    self.doneSelector = action;
}

- (void) addTargetForCancelButton: (id) target action: (SEL) action {
    self.cancelTarget=target;
    self.cancelSelector=action;
}

@end

