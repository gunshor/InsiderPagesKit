//
//  IPKUser.m
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "IPKHTTPClient.h"
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
@dynamic createdAt;
@dynamic email;
@dynamic fb_access_token;
@dynamic fb_user_id;
@dynamic first_name;
@dynamic gender;
@dynamic id;
@dynamic image_content_type;
@dynamic image_file_name;
@dynamic image_file_size;
@dynamic image_profile_path;
@dynamic image_to_show;
@dynamic image_updated_at;
@dynamic last_name;
@dynamic link_to_twitter;
@dynamic name;
@dynamic remoteID;
@dynamic tos;
@dynamic updatedAt;
@dynamic wants_email;
@dynamic website;
@dynamic work_email;
@dynamic zip_code;
@dynamic is_following;
@dynamic is_collaborator;

@dynamic followedPages;
@dynamic followedUsers;
@dynamic followers;
@dynamic notifications;
@dynamic pages;
@dynamic activities;

@synthesize accessToken;

+ (NSString *)entityName {
	return @"IPKUser";
}

+(BOOL)userHasLoggedIn{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *userID = [userDefaults objectForKey:kIPKUserIDKey];
    if (!userID) {
        return NO;
    }
    
    NSString *accessToken = [SSKeychain passwordForService:kIPKKeychainServiceName account:userID.description];
    if (!accessToken) {
        return NO;
    }
    return YES;
}

+ (IPKUser *)currentUser {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *userID = [userDefaults objectForKey:kIPKUserIDKey];
    if (!userID) {
        return nil;
    }
    
    NSString *accessToken = [SSKeychain passwordForService:kIPKKeychainServiceName account:userID.description];
    if (!accessToken) {
        return nil;
    }
    
    __currentUser = [self existingObjectWithRemoteID:userID context:[NSManagedObjectContext MR_defaultContext]];
    __currentUser.accessToken = accessToken;
	return __currentUser;
}

- (NSString *)imageProfilePathForSize:(enum IPKUserProfileImageSize)size{
    NSString * imageProfilePath = nil;
    //    if (self.add_ip_to_fb){
    NSString * fb_size = nil;
    switch (size) {
        case IPKUserProfileImageSizeNano:
            fb_size = @"nano";
            break;
        case IPKUserProfileImageSizeMini:
            fb_size = @"nano";
            break;
        case IPKUserProfileImageSizeThumb:
            fb_size = @"normal";
            break;
        case IPKUserProfileImageSizeMedium:
            fb_size = @"normal";
            break;
        default:
            break;
    }
    imageProfilePath = [self.image_profile_path stringByAppendingString:fb_size];
    //    }
    
    return imageProfilePath;
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
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:kIPKCurrentUserChangedNotificationName object:user];
}

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];
	self.first_name = [dictionary safeObjectForKey:@"first_name"];
	self.last_name = [dictionary safeObjectForKey:@"last_name"];
	self.name = [dictionary safeObjectForKey:@"name"];
	self.email = [dictionary safeObjectForKey:@"email"];
    self.about_me = [dictionary safeObjectForKey:@"about_me"];
    self.add_ip_to_fb = [dictionary safeObjectForKey:@"add_ip_to_fb"];
    self.admin = [dictionary safeObjectForKey:@"admin"];
    self.city_id = [dictionary safeObjectForKey:@"city_id"];
    self.gender = [dictionary safeObjectForKey:@"gender"];
    self.id = [dictionary safeObjectForKey:@"id"];
    self.image_profile_path = [dictionary safeObjectForKey:@"image_profile_path"];
    self.image_content_type = [dictionary safeObjectForKey:@"image_content_type"];
    self.image_file_name = [dictionary safeObjectForKey:@"image_file_name"];
    self.image_file_size = [dictionary safeObjectForKey:@"image_file_size"];
    self.image_to_show = [dictionary safeObjectForKey:@"image_to_show"];
    self.image_updated_at = [dictionary safeObjectForKey:@"image_updated_at"];
    self.link_to_twitter = [dictionary safeObjectForKey:@"link_to_twitter"];
    self.name = [dictionary safeObjectForKey:@"name"];
    self.tos = [dictionary safeObjectForKey:@"tos"];
    self.wants_email = [dictionary safeObjectForKey:@"wants_email"];
    self.website = [dictionary safeObjectForKey:@"website"];
    self.work_email = [dictionary safeObjectForKey:@"work_email"];
    self.zip_code = [dictionary safeObjectForKey:@"zip_code"];
    self.is_following = [dictionary safeObjectForKey:@"is_following"];
    self.is_collaborator = [dictionary safeObjectForKey:@"is_collaborator"];
    
    self.followedPages = [dictionary safeObjectForKey:@"followed_pages"];
    self.followedUsers = [dictionary safeObjectForKey:@"followed_users"];
    self.followers = [dictionary safeObjectForKey:@"followers"];
    self.notifications = [dictionary safeObjectForKey:@"notifications"];
    self.pages = [dictionary safeObjectForKey:@"pages"];
}

#pragma mark IPKRemoteManagedObject

- (void)update {
	[self updateWithSuccess:nil failure:nil];
}


- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.remoteID, @"id",
                            nil];
    
    [[IPKHTTPClient sharedClient] getPath:@"users" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        IPKUser * user = [IPKUser objectWithDictionary:responseObject[@"user"]];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        //        }];
        
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

@end
