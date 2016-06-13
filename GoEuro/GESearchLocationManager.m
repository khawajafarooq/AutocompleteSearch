//
//  GESearchModel.m
//  GoEuro
//
//  Created by GIB on 6/13/16.
//
//

#import "GESearchLocationManager.h"
#import "GELocation.h"
#import "GEGeoSearchService.h"
#import "GEGeoSearchServiceRequest.h"
#import "GEGeoSearchServiceResponse.h"
#import "GEUtility.h"

@interface GESearchLocationManager() <CLLocationManagerDelegate>

// calculate nearest distance mthods
- (NSArray*)calculateFactor:(NSArray*)locationArray currentLocation:(CLLocation*)currentLocation;
- (NSArray*)locationOrderByDistance:(NSArray*)locationArray;

// this method will fetch locations from end point
- (void)searchLocationByQuery:(NSString*)searchQuery locale:(NSString*)locale currentLocation:(CLLocation*)currentLocation;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak) id <GESearchLocationDelegate> delegate;
@property (strong, nonatomic) NSString *query;
@property (strong, nonatomic) NSString *locale;

@end

@implementation GESearchLocationManager

- (id)initWithDelegate:(id <GESearchLocationDelegate>)delegate {

    if (self = [super init]) {
        
        self.delegate = delegate;
        
        self.locationManager = [[CLLocationManager alloc] init];
        
    }
    return self;
}

// there are number of task will be performed here
// 1. fetch current location
// 2. on callback, fetch location from end point based on user search query
// 3. calculate the distance of each fetched location from current location
// 4. sort locations by nearest distance

- (void)startFetchingWithQuery:(NSString *)query locale:(NSString*)locale {
    
    self.query = query;
    self.locale = locale;
    
    
    if (self.locationManager.location == nil) {
        [self getCurrentLocation];
    }
    else {
        // if we already have location start fetching from end point
        [self searchLocationByQuery:self.query locale:self.locale currentLocation:self.locationManager.location];
    }
}

#pragma mark - Private Methods
- (void)getCurrentLocation {
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (NSArray*)calculateFactor:(NSMutableArray*)locationArray currentLocation:(CLLocation*)currentLocation {
    for (int i=0; i<[locationArray count]; i++) {
        GELocation *location = (GELocation*) [locationArray objectAtIndex:i];
        location.distanceFactor = [location.geo_position distanceFromLocation:currentLocation];
        [locationArray replaceObjectAtIndex:i withObject:location];
    }
    
    return locationArray;
}

- (NSArray*)locationOrderByDistance:(NSArray*)locationArray {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distanceFactor"
                                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [locationArray sortedArrayUsingDescriptors:sortDescriptors];
}

- (void)searchLocationByQuery:(NSString*)searchQuery locale:(NSString*)locale currentLocation:(CLLocation*)currentLocation {
    
    GEGeoSearchService *svcObject = [[GEGeoSearchService alloc] init];
    svcObject.request = [[GEGeoSearchServiceRequest alloc] init];
    svcObject.request.locale = locale;
    svcObject.request.term = searchQuery;
    
    [svcObject executeOperationWithCompletion:^(GEGeoSearchServiceResponse* response) {
        
        if (response.locations !=nil && [response.locations count] > 0) {
            
            if ([self.delegate respondsToSelector:@selector(didCompleteSearchWithSortedArray:)]) {
                
                // sorted array by nearest distance
                NSArray *sortedLocations = [self locationOrderByDistance:[self calculateFactor:response.locations currentLocation:currentLocation]];

                [GEUtility Log:sortedLocations];
                
                // callback to UI on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.delegate didCompleteSearchWithSortedArray:sortedLocations];
                });
            }
        }
        else {
            // no data found with error
            
            if ([self.delegate respondsToSelector:@selector(didFailedWithError:)]) {
                [self.delegate didFailedWithError:response.errorMessage];
            }
            
        }
        
    }
                                      failure:^(NSError*error) {
                                          
                                          // failed with error
                                          if ([self.delegate respondsToSelector:@selector(didFailedWithError:)]) {
                                              [self.delegate didFailedWithError:error.localizedDescription];
                                          }
                                          
                                      }];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    
    if (newLocation != nil) {
        // once the location is here start fetching from end point
        [self searchLocationByQuery:self.query locale:self.locale currentLocation:newLocation];
        
        // we dont need to track it until next time app gets started
        // TODO: stop updating location in background only do it in foreground
        [self.locationManager stopUpdatingLocation];
    }
}

@end
