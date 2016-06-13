//
//  GEGeoSearchServiceResponse.h
//  GoEuro
//
//  Created by GIB on 6/12/16.
//
//

#import <Foundation/Foundation.h>
#import "GECommonResponse.h"

@interface GEGeoSearchServiceResponse : GECommonResponse

@property (strong, nonatomic) NSMutableArray *locations;

@end
