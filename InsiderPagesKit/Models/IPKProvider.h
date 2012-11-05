//
//  IPKProvider.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//

#import "IPKAbstractModel.h"

@class IPKPage;
@class IPKReview;
@class IPKAddress;
@class IPKTeamMembership;

@interface IPKProvider : IPKAbstractModel

@property (nonatomic, strong) NSString * attribution_url;
@property (nonatomic, strong) NSString * business_name;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * cg_listing_id;
@property (nonatomic, strong) NSNumber * created_by_id;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSString * description_text;
@property (nonatomic, strong) NSString * email_address;
@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSNumber * last_updated_by_id;
@property (nonatomic, strong) NSNumber * remoteID;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSDate * updated_from_ip_at;
@property (nonatomic, strong) NSDate * updatedAt;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSString * cached_slug;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSString * listing_type;
@property (nonatomic, strong) NSSet *pages;
@property (nonatomic, strong) IPKReview *reviews;
@property (nonatomic, strong) NSSet *activities;
@property (nonatomic, strong) IPKAddress * address;
@property (nonatomic, retain) NSSet *teamMemberships;
@property (nonatomic, retain) NSSet *rank_activities;

-(NSDictionary*)packToDictionary;
-(NSString*)full_name;
-(NSString*)listing_id;

@end

@interface IPKProvider (CoreDataGeneratedAccessors)

- (void)addActivitiesObject:(IPKActivity *)value;
- (void)removeActivitiesObject:(IPKActivity *)value;
- (void)addActivities:(NSSet *)values;
- (void)removeActivities:(NSSet *)values;

- (void)addPagesObject:(IPKPage *)value;
- (void)removePagesObject:(IPKPage *)value;
- (void)addPages:(NSSet *)values;
- (void)removePages:(NSSet *)values;

- (void)addTeamMembershipsObject:(IPKTeamMembership *)value;
- (void)removeTeamMembershipsObject:(IPKTeamMembership *)value;
- (void)addTeamMemberships:(NSSet *)values;
- (void)removeTeamMemberships:(NSSet *)values;

- (void)addRank_activitiesObject:(IPKActivity *)value;
- (void)removeRank_activitiesObject:(IPKActivity *)value;
- (void)addRank_activities:(NSSet *)values;
- (void)removeRank_activities:(NSSet *)values;

@end