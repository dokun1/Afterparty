//
//  FSConverter.m
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 2/7/13.
//
//

#import "FSConverter.h"
#import "APVenue.h"

@implementation FSConverter

- (NSArray *)convertToObjects:(NSArray *)venues {
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:venues.count];
    for (NSDictionary *v  in venues) {
        APVenue *ann = [[APVenue alloc] init];
        ann.name = v[@"name"];
        ann.venueId = v[@"id"];
        
        if (!ann.venueId) {
            continue;
        }

        ann.location.address = v[@"location"][@"address"];
        ann.location.distance = v[@"location"][@"distance"];
        
        [ann.location setCoordinate:CLLocationCoordinate2DMake([v[@"location"][@"lat"] doubleValue],
                                                      [v[@"location"][@"lng"] doubleValue])];
        
        NSMutableString *mutablePrettyAddress = [NSMutableString string];
        if (v[@"location"][@"address"]) {
            [mutablePrettyAddress appendString:v[@"location"][@"address"]];
            [mutablePrettyAddress appendString:@", "];
        }
        if (v[@"location"][@"city"]) {
            [mutablePrettyAddress appendString:v[@"location"][@"city"]];
            [mutablePrettyAddress appendString:@", "];
        }
        if (v[@"location"][@"state"]) {
            [mutablePrettyAddress appendString:v[@"location"][@"state"]];
            [mutablePrettyAddress appendString:@", "];
        }
        if (v[@"location"][@"postalCode"]) {
            [mutablePrettyAddress appendString:v[@"location"][@"postalCode"]];
        }
        if (mutablePrettyAddress.length > 0) {
            NSString *lastChar = [mutablePrettyAddress substringFromIndex:[mutablePrettyAddress length] - 2];
            if ([lastChar isEqualToString:@", "]) {
                mutablePrettyAddress = [[mutablePrettyAddress substringToIndex:[mutablePrettyAddress length] - 2] mutableCopy];
            }
        }
        
        ann.prettyAddress = mutablePrettyAddress;
        NSArray *categories = v[@"categories"];
        NSDictionary *categoryDict = categories.firstObject;
        NSString *prefix = categoryDict[@"icon"][@"prefix"];
        ann.iconURL = [NSString stringWithFormat:@"%@64%@", prefix, categoryDict[@"icon"][@"suffix"]];
        [objects addObject:ann];
    }
    return objects;
}

@end
