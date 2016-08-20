//
//  NSString+Common.h
//  AutocompleteSearch
//
//  Created by GIB on 6/12/16.
//
//

#import <Foundation/Foundation.h>

@interface NSString(Common)

// this method will check if string is empty
- (BOOL)isEmpty;

// this method will check if string is nil
- (BOOL)isNull;

// this method will trip white spaces from string
- (NSString*)trimWhiteSpace;
@end
