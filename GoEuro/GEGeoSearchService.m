//
//  GEGeoSearchService.m
//  GoEuro
//
//  Created by GIB on 6/12/16.
//
//

#import "GEGeoSearchService.h"
#import "GEGeoSearchServiceResponse.h"
#import "GEGeoSearchServiceRequest.h"
#import "NSString+Common.h"
#import "GoEuro-Swift.h"
#import "GEConstants.h"



@implementation GEGeoSearchService

@synthesize request;

- (void)executeOperationWithCompletion:(void (^)(GEGeoSearchServiceResponse *response))success
                               failure:(void (^)(NSError *error))failure {
    
    NSString *urlString = [[NSString
                            stringWithFormat:@"%@%@/%@",GET_POSITION,
                            self.request.locale, self.request.term] trimWhiteSpace];
    
    SAWebFetcher *webFetcher = [[SAWebFetcher alloc] init];
    [webFetcher setUrl:[NSURL URLWithString:urlString]];
    [webFetcher setHttpMethod:HTTPMethodGet];
    [webFetcher setDataFormat:DataFormatJSON];
    
    [webFetcher setSuccessCallback:^(NSData * responseData){
        
        // success
        GEGeoSearchServiceResponse *response = [[GEGeoSearchServiceResponse alloc] init];
        [response parserData:responseData];
        success(response);
    }];
    
    [webFetcher setFailureCallback:^(NSError * error){
        
        failure(error);
    }];
    
    [webFetcher startFetchingAsync];
}

@end
