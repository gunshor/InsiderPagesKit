//
//  IPKNotification.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//

#import "IPKNotification.h"
#import "IPKUser.h"
#import "NSDictionary+InsiderPagesKit.h"

@implementation IPKNotification

@dynamic action_text;
@dynamic activity_parent;
@dynamic createdAt;
@dynamic path;
@dynamic read;
@dynamic remoteID;
@dynamic updatedAt;
@dynamic user_id;
@dynamic user;
@dynamic mentioned_users;

#pragma mark - SSManagedObject

+ (NSString *)entityName {
	return @"IPKNotification";
}

#pragma mark - SSRemoteManagedObject

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];
	self.action_text = [dictionary safeObjectForKey:@"action_text"];
    self.activity_parent = [dictionary safeObjectForKey:@"activity_parent"];
    self.path = [dictionary safeObjectForKey:@"path"];
    self.read = [dictionary safeObjectForKey:@"read"];
    self.user_id = [dictionary safeObjectForKey:@"user_id"];
    self.user = [IPKUser objectWithRemoteID:self.user_id];
    
    if ([dictionary safeObjectForKey:@"users"]) {
        NSArray * mentionedUsers = [dictionary safeObjectForKey:@"users"];
        for (NSDictionary * userDictionary in mentionedUsers) {
            IPKUser * user = [IPKUser objectWithDictionary:userDictionary];
            [self addMentioned_usersObject:user];
        }
    }
}


- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary {
	return YES;
}

@end
