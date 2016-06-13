//
//  GESearchModel.h
//  GoEuro
//
//  Created by GIB on 6/13/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "GELocationSearchProtocol.h"

@interface GESearchLocationManager : NSObject <GESearchLocationDelegate>


// initialize manager
- (id)initWithDelegate:(id <GESearchLocationDelegate>)delegate;

// this method will fetch locations from based on search query
- (void)startFetchingWithQuery:(NSString *)query locale:(NSString*)locale;

@end
