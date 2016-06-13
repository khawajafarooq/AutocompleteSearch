//
//  GEAutocompleteTextSearch.h
//  GoEuro
//
//  Created by GIB on 6/13/16.
//
//

#import <UIKit/UIKit.h>


//@protocol GEAutocompleteTextSearchDelegate <NSObject>
//
//@optional
//
//- (void)autocompleteTextFieldShouldBeginEditing:(UITextField*)textField;
//- (void)autocompleteTextFieldDidEndEditing:(UITextField*)textField;
//
//@end

@interface GEAutocompleteTextSearch : UITextField

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring;
- (void)closeTableView;

@end
