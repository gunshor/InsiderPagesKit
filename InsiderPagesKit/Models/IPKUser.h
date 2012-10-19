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
@class IPKTeamMembership;
@class IPKTeamFollowing;
@class IPKNotification;

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
@property (nonatomic, strong) NSString * image_content_type;
@property (nonatomic, strong) NSString * image_file_name;
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
@property (nonatomic, strong) NSSet *teamMemberships;
@property (nonatomic, strong) NSSet *teamFollowings;
@property (nonatomic, retain) NSSet *notifications_mentioned_in;

@property (nonatomic, strong) NSString *accessToken;

+ (IPKUser *)currentUserInContext:(NSManagedObjectContext*) localContext;
+ (void)setCurrentUser:(IPKUser *)user;
+ (BOOL)userHasLoggedIn;

// Helpers
- (NSString *)imageProfilePathForSize:(enum IPKUserProfileImageSize)size;
- (NSString *)sortOption;
@end

@interface IPKUser (CoreDataGeneratedAccessors)

- (void)addPagesObject:(IPKPage *)value;
- (void)removePagesObject:(IPKPage *)value;
- (void)addPages:(NSSet *)values;
- (void)removePages:(NSSet *)values;

- (void)addNotificationsObject:(IPKNotification *)value;
- (void)removeNotificationsObject:(IPKNotification *)value;
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

- (void)addTeamMembershipsObject:(IPKTeamMembership *)value;
- (void)removeTeamMembershipsObject:(IPKTeamMembership *)value;
- (void)addTeamMemberships:(NSSet *)values;
- (void)removeTeamMemberships:(NSSet *)values;

- (void)addTeamFollowingsObject:(IPKTeamFollowing *)value;
- (void)removeTeamFollowingsObject:(IPKTeamFollowing *)value;
- (void)addTeamFollowings:(NSSet *)values;
- (void)removeTeamFollowings:(NSSet *)values;

- (void)addNotifications_mentioned_inObject:(IPKNotification *)value;
- (void)removeNotifications_mentioned_inObject:(IPKNotification *)value;
- (void)addNotifications_mentioned_in:(NSSet *)values;
- (void)removeNotifications_mentioned_in:(NSSet *)values;

@end
