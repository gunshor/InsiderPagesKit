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

NSString *const kIPKCurrentUserChangedNotificationName = @"IPCurrentUserChangedNotification";
static NSString *const kIPKUserIDKey = @"IPKUserID";
static IPKUser *__currentUser = nil;

@implementation IPKUser

@dynamic about_me;
@dynamic add_ip_to_fb;
@dynamic admin;
@dynamic city_id;
@dynamic created_at;
@dynamic email;
@dynamic first_name;
@dynamic gender;
@dynamic id;
@dynamic image_content_type;
@dynamic image_file_name;
@dynamic image_file_size;
@dynamic image_to_show;
@dynamic image_updated_at;
@dynamic last_name;
@dynamic link_to_twitter;
@dynamic name;
@dynamic tos;
@dynamic updated_at;
@dynamic wants_email;
@dynamic website;
@dynamic work_email;
@dynamic zip_code;
@dynamic fb_access_token;
@dynamic fb_user_id;
@dynamic followed_pages;
@dynamic followed_users;
@dynamic followers;
@dynamic notifications;
@dynamic pages;


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
		__currentUser.fb_access_token = accessToken;
	}
	return __currentUser;
}


+ (void)setCurrentUser:(IPKUser *)user {
	if (__currentUser) {
		[SSKeychain deletePasswordForService:kIPKKeychainServiceName account:__currentUser.remoteID.description];
	}
	
	if (!user.remoteID || !user.fb_access_token) {
		__currentUser = nil;
		return;
	}
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:user.remoteID forKey:kIPKUserIDKey];
	[userDefaults synchronize];
	
	[SSKeychain setPassword:user.fb_access_token forService:kIPKKeychainServiceName account:user.remoteID.description];
	
	__currentUser = user;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kIPKCurrentUserChangedNotificationName object:user];
}


- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];
	self.first_name = [dictionary safeObjectForKey:@"first_name"];
	self.last_name = [dictionary safeObjectForKey:@"last_name"];
	self.name = [dictionary safeObjectForKey:@"name"];
	self.email = [dictionary safeObjectForKey:@"email"];
    self.about_me = [dictionary safeObjectForKey:@"about_me"];
    self.add_ip_to_fb = [dictionary safeObjectForKey:@"add_ip_to_fb"];
    self.admin = [dictionary safeObjectForKey:@"first_name"];
    self.city_id = [dictionary safeObjectForKey:@"city_id"];
    self.created_at = [dictionary safeObjectForKey:@"created_at"];
    self.gender = [dictionary safeObjectForKey:@"gender"];
    self.id = [dictionary safeObjectForKey:@"id"];
    self.image_content_type = [dictionary safeObjectForKey:@"image_content_type"];
    self.image_file_name = [dictionary safeObjectForKey:@"image_file_name"];
    self.image_file_size = [dictionary safeObjectForKey:@"image_file_size"];
    self.image_to_show = [dictionary safeObjectForKey:@"image_to_show"];
    self.image_updated_at = [dictionary safeObjectForKey:@"image_updated_at"];
    self.link_to_twitter = [dictionary safeObjectForKey:@"link_to_twitter"];
    self.name = [dictionary safeObjectForKey:@"name"];
    self.tos = [dictionary safeObjectForKey:@"tos"];
    self.updated_at = [dictionary safeObjectForKey:@"updated_at"];
    self.wants_email = [dictionary safeObjectForKey:@"wants_email"];
    self.website = [dictionary safeObjectForKey:@"website"];
    self.work_email = [dictionary safeObjectForKey:@"work_email"];
    self.zip_code = [dictionary safeObjectForKey:@"zip_code"];
    self.followed_pages = [dictionary safeObjectForKey:@"followed_pages"];
    self.followed_users = [dictionary safeObjectForKey:@"followed_users"];
    self.followers = [dictionary safeObjectForKey:@"followers"];
    self.notifications = [dictionary safeObjectForKey:@"notifications"];
    self.pages = [dictionary safeObjectForKey:@"pages"];
}

@end
