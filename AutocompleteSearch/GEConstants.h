//
//  GEConstants.h
//  AutocompleteSearch
//
//  Created by GIB on 6/12/16.
//
//

#ifndef GEConstants_h
#define GEConstants_h

// web api url
#define SERVICE_BASE_URL    @"http://api.goeuro.com/api/v2/"

// api methods
#define GET_POSITION        [NSString stringWithFormat:@"%@position/suggest/",SERVICE_BASE_URL]

// vaid character set for alphabetic search feature
#define VALID_CHARECTERS_SET @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

#endif /* GEConstants_h */
