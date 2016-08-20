//
//  GELocationSearchProtocol.h
//  AutocompleteSearch
//
//  Created by GIB on 6/13/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol GESearchLocationDelegate <NSObject>


@optional
// search completed with list of location sort by nearest distance
- (void)didCompleteSearchWithSortedArray:(NSArray*)locationArray;

// search failed with error
- (void)didFailedWithError:(NSString*)error;


@end
