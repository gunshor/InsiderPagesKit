//
//  IPKDefines.h
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12
//

#import <Foundation/Foundation.h>

#ifndef IPDEFINES
#define IPDEFINES

// IPKDispatchRelease
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 || MAC_OS_X_VERSION_MIN_REQUIRED >= 1080
	#define IPKDispatchRelease(queue)
#else
	#define IPKDispatchRelease(queue) dispatch_release(queue)
#endif

// Always use development on the simulator or Mac app (for now)
#if !TARGET_IPHONE_SIMULATOR && !TARGET_OS_MAC
	#define INSIDER_PAGES_PRODUCTION_MODE 1
#endif

#pragma mark - API

extern NSString *const kIPKAPIScheme;
extern NSString *const kIPKAPIHost;
extern NSString *const kIPKPusherAPIKey;

extern NSString *const kIPKDevelopmentAPIScheme;
extern NSString *const kIPKDevelopmentAPIHost;
extern NSString *const kIPKDevelopmentPusherAPIKey;


#pragma mark - User Defaults Keys

extern NSString *const kIPKCurrentUserIDKey;
extern NSString *const kIPKCurrentUsernameKey;


#pragma mark - Misc

extern NSString *const kIPKKeychainServiceName;

#pragma mark - Notifications

extern NSString *const kIPKListDidUpdateNotificationName;
extern NSString *const kIPKPlusDidChangeNotificationName;

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
    IPKActivityTypeTeam = 4,
    IPKActivityTypeFollow = 5,
    IPKActivityTypeAdd = 6,
};

#endif
