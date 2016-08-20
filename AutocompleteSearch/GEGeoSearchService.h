//
//  GEGeoSearchService.h
//  AutocompleteSearch
//
//  Created by GIB on 6/12/16.
//
//

#import <Foundation/Foundation.h>

@class GEGeoSearchServiceRequest;
@class GEGeoSearchServiceResponse;

@interface GEGeoSearchService : NSObject

@property (strong, nonatomic) GEGeoSearchServiceRequest* request;

- (void)executeOperationWithCompletion:(void (^)(GEGeoSearchServiceResponse *response))success
                               failure:(void (^)(NSError *error))failure;

@end
