//
//  Notification.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKNotification.h"
#import "IPKUser.h"
#import "NSDictionary+InsiderPagesKit.h"

@implementation IPKNotification

@dynamic action_text;
@dynamic activity_parent;
@dynamic createdAt;
@dynamic id;
@dynamic path;
@dynamic read;
@dynamic remoteID;
@dynamic updatedAt;
@dynamic user_id;
@dynamic user;

#pragma mark - SSManagedObject

+ (NSString *)entityName {
	return @"IPKNotification";
}

#pragma mark - SSRemoteManagedObject

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];
	self.action_text = [dictionary safeObjectForKey:@"action_text"];
    self.activity_parent = [dictionary safeObjectForKey:@"activity_parent"];
    self.id = [dictionary safeObjectForKey:@"id"];
    self.path = [dictionary safeObjectForKey:@"path"];
    self.read = [dictionary safeObjectForKey:@"read"];
    self.read = [dictionary safeObjectForKey:@"user_id"];
    self.user = [IPKUser objectWithRemoteID:self.user_id];
}


- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary {
	return YES;
}

@end
