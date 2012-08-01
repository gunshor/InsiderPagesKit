//
//  IPKPushController.h
//  InsiderPagesKit
//
//  Created by Sam Soffes on 4/9/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLYClient;
@class BLYChannel;

@interface IPKPushController : NSObject

@property (nonatomic, strong, readonly) BLYClient *client;
@property (nonatomic, strong, readonly) BLYChannel *userChannel;

+ (IPKPushController *)sharedController;
+ (void)setDevelopmentModeEnabled:(BOOL)enabled;

@end
