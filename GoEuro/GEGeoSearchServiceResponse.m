//
//  GEGeoSearchServiceResponse.m
//  GoEuro
//
//  Created by GIB on 6/12/16.
//
//

#import "GEGeoSearchServiceResponse.h"
#import "GELocation.h"

@implementation GEGeoSearchServiceResponse

@synthesize locations;

- (void)parse:(NSArray*)responseDictonary {
    
    if (responseDictonary != nil && [responseDictonary count]>0) {
        
        self.locations = [[NSArray array] mutableCopy];
        
        for (NSDictionary *location in responseDictonary) {
            
            GELocation *loc = [[GELocation alloc] init];
            loc.key = [location valueForKey:@"key"];
            loc.name = [location valueForKey:@"name"];
            
            NSDictionary *posDictionary = [location valueForKey:@"geo_position"];
            
            if (posDictionary != nil && ![posDictionary isKindOfClass:[NSNull class]]) {
                
                CLLocationDegrees latitude = [[posDictionary valueForKey:@"latitude"] doubleValue];
                CLLocationDegrees longitude = [[posDictionary valueForKey:@"longitude"] doubleValue];
                loc.geo_position = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            }
            
            [self.locations addObject:loc];
        }
    }
}


@end
