//
//  IPKUser.h
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "SSDataKit.h"
#import "IPKRemoteManagedObject.h"

@class IPKList;
@class IPKTask;
@class IPKPage;

extern NSString *const kIPKCurrentUserChangedNotificationName;

@interface IPKUser : IPKRemoteManagedObject

@property (nonatomic, retain) NSString * fb_access_token;
@property (nonatomic, retain) NSString * fb_user_id;

@property (nonatomic, retain) NSString * about_me;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * add_ip_to_fb;
@property (nonatomic, retain) NSNumber * admin;
@property (nonatomic, retain) NSString * city_id;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * image_content_type;
@property (nonatomic, retain) NSString * image_file_name;
@property (nonatomic, retain) NSString * image_file_size;
@property (nonatomic, retain) NSNumber * image_to_show;
@property (nonatomic, retain) NSDate * image_updated_at;
@property (nonatomic, retain) NSNumber * link_to_twitter;
@property (nonatomic, retain) NSNumber * tos;
@property (nonatomic, retain) NSNumber * wants_email;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * work_email;
@property (nonatomic, retain) NSNumber * zip_code;
@property (nonatomic, retain) NSSet *pages;
@property (nonatomic, retain) NSSet *notifications;
@property (nonatomic, retain) NSSet *followers;
@property (nonatomic, retain) IPKPage *followedPages;
@property (nonatomic, retain) IPKUser *followedUsers;

+ (IPKUser *)currentUser;
+ (void)setCurrentUser:(IPKUser *)user;

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
