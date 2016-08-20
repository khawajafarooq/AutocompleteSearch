//
//  GELocation.h
//  AutocompleteSearch
//
//  Created by GIB on 6/12/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GELocation : NSObject

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) CLLocation *geo_position;
@property (assign, nonatomic) CLLocationDistance distanceFactor;

@end
