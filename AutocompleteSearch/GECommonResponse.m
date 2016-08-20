//
//  GECommonResponse.m
//  AutocompleteSearch
//
//  Created by GIB on 6/12/16.
//
//

#import "GECommonResponse.h"

@implementation GECommonResponse

@synthesize isSuccess;
@synthesize errorMessage;

- (void)parserData:(NSData*)responseData {
    if(NSClassFromString(@"NSJSONSerialization"))
    {
        NSError *error = nil;
        NSArray *object = [NSJSONSerialization
                     JSONObjectWithData:responseData
                     options:0
                     error:&error];
        
        if(error) {
            self.errorMessage = error.localizedDescription;
            self.isSuccess = NO;
        }
        else {
            
            if (object == nil || [object count] == 0) {
                self.errorMessage = @"No data found from service.";
            }
            else {
                self.errorMessage = @"";
            }
            
            self.isSuccess = YES;
            [self parse:object];
        }
    }
}

- (void)parserError:(NSError*)error {
    if(error) {
        self.errorMessage = error.localizedDescription;
        self.isSuccess = NO;
    }
}

- (void)parse:(NSArray*)responseDictonary {

    // child class will override
}


@end
