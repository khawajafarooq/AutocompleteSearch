//
//  ViewController+KeyboardFeature.m
//  AutocompleteSearch
//
//  Created by GIB on 6/12/16.
//
//

#import "UIViewController+KeyboardFeature.h"

@implementation UIViewController(KeyboardFeature)

- (void)hideKeyboardWhenTappedAround {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}


@end
