//
//  User.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IPKPage, User;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * about_me;
@property (nonatomic, retain) NSNumber * add_ip_to_fb;
@property (nonatomic, retain) NSNumber * admin;
@property (nonatomic, retain) NSString * city_id;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * image_content_type;
@property (nonatomic, retain) NSString * image_file_name;
@property (nonatomic, retain) NSString * image_file_size;
@property (nonatomic, retain) NSNumber * image_to_show;
@property (nonatomic, retain) NSDate * image_updated_at;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSNumber * link_to_twitter;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * tos;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSNumber * wants_email;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * work_email;
@property (nonatomic, retain) NSNumber * zip_code;
@property (nonatomic, retain) NSString * fb_access_token;
@property (nonatomic, retain) NSString * fb_user_id;
@property (nonatomic, retain) IPKPage *followed_pages;
@property (nonatomic, retain) User *followed_users;
@property (nonatomic, retain) NSSet *followers;
@property (nonatomic, retain) NSSet *notifications;
@property (nonatomic, retain) NSSet *pages;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addFollowersObject:(User *)value;
- (void)removeFollowersObject:(User *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

- (void)addNotificationsObject:(User *)value;
- (void)removeNotificationsObject:(User *)value;
- (void)addNotifications:(NSSet *)values;
- (void)removeNotifications:(NSSet *)values;

- (void)addPagesObject:(IPKPage *)value;
- (void)removePagesObject:(IPKPage *)value;
- (void)addPages:(NSSet *)values;
- (void)removePages:(NSSet *)values;

@end
