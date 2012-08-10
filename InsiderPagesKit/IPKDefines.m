//
//  IPKDefines.m
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//

#import "IPKDefines.h"

#pragma mark - API

NSString *const kIPKAPIScheme = @"https";
NSString *const kIPKAPIHost = @"insiderpages.com/api";
NSString *const kIPKAPIVersion = @"v1";
NSString *const kIPKPusherAPIKey = @"675f10a650f18b4eb0a8";

NSString *const kIPKDevelopmentAPIScheme = @"http";
NSString *const kIPKDevelopmentAPIHost = @"local.insiderpages.com/api";
NSString *const kIPKDevelopmentAPIVersion = @"v1";
NSString *const kIPKDevelopmentPusherAPIKey = @"a02cb793e9d5fb919023";


#pragma mark - User Defaults Keys

NSString *const kIPKCurrentUserIDKey = @"IPCurrentUserID";
NSString *const kIPKCurrentUsernameKey = @"IPCurrentUsername";


#pragma mark - Misc

NSString *const kIPKKeychainServiceName = @"InsiderPages";


#pragma mark - Notifications

NSString *const kIPKListDidUpdateNotificationName = @"IPListDidUpdateNotification";
NSString *const kIPKPlusDidChangeNotificationName = @"IPPlusDidChangeNotification";

#pragma mark - Enum defs

enum IPKTrackableType {
    IPKTrackableTypeAll = 0,
    IPKTrackableTypeProvider = 1,
    IPKTrackableTypeReview = 2,
    IPKTrackableTypeUser = 3,
    IPKTrackableTypeTeam = 4
};

enum IPKActivityType {
    IPKActivityTypeAll = 0,
    IPKActivityTypeCreate = 1,
    IPKActivityTypeView = 2,
    IPKActivityTypeUpdate = 3,
    IPKActivityTypeTeam = 4
};
