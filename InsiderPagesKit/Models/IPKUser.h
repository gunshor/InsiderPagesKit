//
//  IPKUser.h
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//
#import "IPKAbstractModel.h"

@class IPKPage;
@class IPKReview;

enum IPKUserProfileImageSize {
    IPKUserProfileImageSizeNano = 0,
    IPKUserProfileImageSizeMini = 1,
    IPKUserProfileImageSizeThumb = 2,
    IPKUserProfileImageSizeMedium = 3
};

extern NSString *const kIPKCurrentUserChangedNotificationName;

@interface IPKUser : IPKAbstractModel

@property (nonatomic, strong) NSString * fb_access_token;
@property (nonatomic, strong) NSString * fb_user_id;

@property (nonatomic, strong) NSString * about_me;
@property (nonatomic, strong) NSNumber * add_ip_to_fb;
@property (nonatomic, strong) NSNumber * admin;
@property (nonatomic, strong) NSNumber * city_id;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSNumber * gender;
@property (nonatomic, strong) NSNumber * id;
@property (nonatomic, strong) NSString * image_content_type;
@property (nonatomic, strong) NSString * image_file_name;
@property (nonatomic, strong) NSString * image_file_size;
@property (nonatomic, strong) NSString * image_profile_path;
@property (nonatomic, strong) NSNumber * image_to_show;
@property (nonatomic, strong) NSDate * image_updated_at;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSNumber * link_to_twitter;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * remoteID;
@property (nonatomic, strong) NSNumber * tos;
@property (nonatomic, strong) NSDate * updatedAt;
@property (nonatomic, strong) NSNumber * wants_email;
@property (nonatomic, strong) NSString * website;
@property (nonatomic, strong) NSString * work_email;
@property (nonatomic, strong) NSString * zip_code;
@property (nonatomic, strong) NSNumber * is_following;
@property (nonatomic, strong) NSNumber * is_collaborator;

@property (nonatomic, strong) NSSet *followedPages;
@property (nonatomic, strong) NSSet *followedUsers;
@property (nonatomic, strong) NSSet *followers;
@property (nonatomic, strong) NSSet *notifications;
@property (nonatomic, strong) NSSet *pages;
@property (nonatomic, strong) NSSet *activities;
@property (nonatomic, strong) IPKReview *reviews;

@property (nonatomic, strong) NSString *accessToken;
+ (IPKUser *)currentUser;
+ (void)setCurrentUser:(IPKUser *)user;
+ (BOOL)userHasLoggedIn;

// Helpers
- (NSString *)imageProfilePathForSize:(enum IPKUserProfileImageSize)size;
@end

@interface IPKUser (CoreDataGeneratedAccessors)

- (void)addPagesObject:(IPKPage *)value;
- (void)removePagesObject:(IPKPage *)value;
- (void)addPages:(NSSet *)values;
- (void)removePages:(NSSet *)values;

- (void)addNotificationsObject:(IPKUser *)value;
- (void)removeNotificationsObject:(IPKUser *)value;
- (void)addNotifications:(NSSet *)values;
- (void)removeNotifications:(NSSet *)values;

- (void)addFollowersObject:(IPKUser *)value;
- (void)removeFollowersObject:(IPKUser *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

- (void)addFollowedPagesObject:(IPKPage *)value;
- (void)removeFollowedPagesObject:(IPKPage *)value;
- (void)addFollowedPages:(NSSet *)values;
- (void)removeFollowedPages:(NSSet *)values;

- (void)addFollowedUsersObject:(IPKUser *)value;
- (void)removeFollowedUsersObject:(IPKUser *)value;
- (void)addFollowedUsers:(NSSet *)values;
- (void)removeFollowedUsers:(NSSet *)values;

@end
