//
//  IPKUser.m
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "IPKUser.h"
#import "IPKList.h"
#import "IPKTask.h"
#import "SSKeychain.h"
#import "NSDictionary+InsiderPagesKit.h"
#import "IPKDefines.h"

NSString *const kIPKCurrentUserChangedNotificationName = @"CHCurrentUserChangedNotification";
static NSString *const kIPKUserIDKey = @"IPKUserID";
static IPKUser *__currentUser = nil;

@implementation IPKUser

@dynamic firstName;
@dynamic lastName;
@dynamic username;
@dynamic email;
@dynamic tasks;
@dynamic lists;
@dynamic hasPlus;
@synthesize accessToken = _accessToken;


+ (NSString *)entityName {
	return @"User";
}


+ (IPKUser *)currentUser {
	if (!__currentUser) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSNumber *userID = [userDefaults objectForKey:kIPKUserIDKey];
		if (!userID) {
			return nil;
		}
		
		NSString *accessToken = [SSKeychain passwordForService:kIPKKeychainServiceName account:userID.description];
		if (!accessToken) {
			return nil;
		}

		__currentUser = [self existingObjectWithRemoteID:userID];
		__currentUser.accessToken = accessToken;
	}
	return __currentUser;
}


+ (void)setCurrentUser:(IPKUser *)user {
	if (__currentUser) {
		[SSKeychain deletePasswordForService:kIPKKeychainServiceName account:__currentUser.remoteID.description];
	}
	
	if (!user.remoteID || !user.accessToken) {
		__currentUser = nil;
		return;
	}
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:user.remoteID forKey:kIPKUserIDKey];
	[userDefaults synchronize];
	
	[SSKeychain setPassword:user.accessToken forService:kIPKKeychainServiceName account:user.remoteID.description];
	
	__currentUser = user;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kIPKCurrentUserChangedNotificationName object:user];
}


- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];
	self.firstName = [dictionary safeObjectForKey:@"first_name"];
	self.lastName = [dictionary safeObjectForKey:@"last_name"];
	self.username = [dictionary safeObjectForKey:@"username"];
	self.email = [dictionary safeObjectForKey:@"email"];
	self.hasPlus = [dictionary safeObjectForKey:@"has_plus"];
}

@end
