//
//  Utility.m
//  GoEuro
//
//  Created by GIB on 6/12/16.
//
//

#import "GEUtility.h"

// CGRect Utilities Methods
CGRect RectSetOriginX (CGRect rect, CGFloat x)
{
    rect.origin.x = x;
    return rect;
}

CGRect RectSetOriginY (CGRect rect, CGFloat y)
{
    rect.origin.y = y;
    return rect;
}


CGRect RectSetWidht (CGRect rect, CGFloat width)
{
    rect.size.width = width;
    return rect;
}

CGRect RectSetHeight (CGRect rect, CGFloat height)
{
    rect.size.height = height;
    return rect;
}


@implementation GEUtility

+ (void)displayAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:delegate
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

+ (NSString*)currentLocale {
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}


@end
