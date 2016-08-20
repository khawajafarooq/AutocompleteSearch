//
//  NSString+Common.m
//  AutocompleteSearch
//
//  Created by GIB on 6/12/16.
//
//

#import "NSString+Common.h"

@implementation NSString(Common)

- (BOOL)isEmpty {
    if (self == nil || !self.length) {
        return YES;
    }
    return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""];
}

- (BOOL)isNull {
    return ([self isKindOfClass:[NSNull class]] || (self == nil));
}

- (NSString*)trimWhiteSpace {
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];;
}


@end
