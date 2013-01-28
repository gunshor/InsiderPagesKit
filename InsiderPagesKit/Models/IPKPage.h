//
//  IPKPage.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//

#import "IPKAbstractModel.h"

@class IPKUser;
@class IPKProvider;
@class IPKReview;
@class IPKTeamMembership;
@class IPKTeamFollowing;
@class IPKActivity;

@interface IPKPage : IPKAbstractModel

@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSString * description_text;
@property (nonatomic, strong) NSString * image_content_type;
@property (nonatomic, strong) NSString * image_file_name;
@property (nonatomic, strong) NSDate * image_updated_at;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * privacy_setting;
@property (nonatomic, strong) NSNumber * remoteID;
@property (nonatomic, strong) NSNumber * sequence;
@property (nonatomic, strong) NSNumber * sort;
@property (nonatomic, strong) NSDate * updatedAt;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * is_favorite;
@property (nonatomic, strong) NSNumber * is_following;
@property (nonatomic, strong) NSNumber * is_collaborator;
@property (nonatomic, strong) NSNumber * collaborator_count;
@property (nonatomic, strong) NSNumber * business_count;
@property (nonatomic, strong) NSNumber * comment_count;
@property (nonatomic, strong) NSSet *following_users;
@property (nonatomic, strong) IPKUser *owner;
@property (nonatomic, strong) NSOrderedSet *providers;
@property (nonatomic, strong) NSSet *activities;
@property (nonatomic, strong) IPKReview *reviews;
@property (nonatomic, retain) NSSet *teamMemberships;
@property (nonatomic, retain) NSSet *teamFollowings;

-(NSDictionary*)packToDictionary;

@end

@interface IPKPage (CoreDataGeneratedAccessors)

- (void)addActivitiesObject:(IPKActivity *)value;
- (void)removeActivitiesObject:(IPKActivity *)value;
- (void)addActivities:(NSSet *)values;
- (void)removeActivities:(NSSet *)values;

- (void)addFollowing_usersObject:(IPKUser *)value;
- (void)removeFollowing_usersObject:(IPKUser *)value;
- (void)addFollowing_users:(NSSet *)values;
- (void)removeFollowing_users:(NSSet *)values;

- (void)insertObject:(IPKProvider *)value inProvidersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromProvidersAtIndex:(NSUInteger)idx;
- (void)insertProviders:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeProvidersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInProvidersAtIndex:(NSUInteger)idx withObject:(IPKProvider *)value;
- (void)replaceProvidersAtIndexes:(NSIndexSet *)indexes withProviders:(NSArray *)values;
- (void)addProvidersObject:(IPKProvider *)value;
- (void)removeProvidersObject:(IPKProvider *)value;
- (void)addProviders:(NSOrderedSet *)values;
- (void)removeProviders:(NSOrderedSet *)values;
- (void)addTeamFollowingsObject:(IPKTeamFollowing *)value;
- (void)removeTeamFollowingsObject:(IPKTeamFollowing *)value;
- (void)addTeamFollowings:(NSSet *)values;
- (void)removeTeamFollowings:(NSSet *)values;

- (void)addTeamMembershipsObject:(IPKTeamMembership *)value;
- (void)removeTeamMembershipsObject:(IPKTeamMembership *)value;
- (void)addTeamMemberships:(NSSet *)values;
- (void)removeTeamMemberships:(NSSet *)values;

@end
