//
//  GECommonResponse.h
//  GoEuro
//
//  Created by GIB on 6/12/16.
//
//

#import <Foundation/Foundation.h>

@interface GECommonResponse : NSObject

@property (assign, nonatomic) BOOL isSuccess;
@property (strong, nonatomic) NSString *errorMessage;

- (void)parserData:(NSData*)responseData;
- (void)parserError:(NSError*)error;

@end
