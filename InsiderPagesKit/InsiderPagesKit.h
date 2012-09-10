//
//  InsiderPagesKit.h
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//

#import <InsiderPagesKit/IPKDefines.h>

// Models
#import <InsiderPagesKit/Models/IPKAbstractModel.h>
#import <InsiderPagesKit/Models/IPKUser.h>
#import <InsiderPagesKit/Models/IPKReview.h>
#import <InsiderPagesKit/Models/IPKPage.h>
#import <InsiderPagesKit/Models/IPKProvider.h>
#import <InsiderPagesKit/Models/IPKAddress.h>
#import <InsiderPagesKit/IPKQueryModel.h>
#import <InsiderPagesKit/Models/IPKActivity.h>
#import <InsiderPagesKit/Models/IPKNotification.h>

// Networking
#import <InsiderPagesKit/IPKHTTPClient.h>
//#import <InsiderPagesKit/IPKPushController.h>

// Categories
#import <InsiderPagesKit/NSDictionary+InsiderPagesKit.h>
#import <InsiderPagesKit/NSString+InsiderPagesKit.h>

// Vendor
#if TARGET_OS_IPHONE
#import <InsiderPagesKit/Vendor/SSDataKit/SSDataKit.h>
#import <InsiderPagesKit/Vendor/AFNetworking/AFNetworking/AFNetworking.h>
#import <InsiderPagesKit/Vendor/Reachability/Reachability.h>
#import <InsiderPagesKit/Vendor/MagicalRecord/MagicalRecord/CoreData+MagicalRecord.h>
#else
#import <InsiderPagesKit/SSDataKit.h>
#import <InsiderPagesKit/AFNetworking.h>
#import <InsiderPagesKit/Reachability.h>
#endif