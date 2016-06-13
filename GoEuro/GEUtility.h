//
//  Utility.h
//  GoEuro
//
//  Created by GIB on 6/12/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GEUtility : NSObject

// Geometry Utility
CGRect RectSetOriginX (CGRect rect, CGFloat x);
CGRect RectSetOriginY (CGRect rect, CGFloat y);
CGRect RectSetWidht (CGRect rect, CGFloat width);
CGRect RectSetHeight (CGRect rect, CGFloat height);

// this method will display alert with OK button
+ (void)displayAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate;

// this method will get current device locale
+ (NSString*)currentLocale;

@end
