//
//  IPKActivity.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//

#import "IPKAbstractModel.h"

@class IPKPage, IPKUser, IPKProvider, IPKReview;

@interface IPKActivity : IPKAbstractModel

@property (nonatomic, strong) NSString * action;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSNumber * remoteID;
@property (nonatomic, strong) NSNumber * team_id;
@property (nonatomic, strong) NSNumber * trackable_id;
@property (nonatomic, strong) NSString * trackable_type;
@property (nonatomic, strong) NSDate * updatedAt;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSNumber * visibility;
@property (nonatomic, strong) IPKPage *page;
@property (nonatomic, strong) IPKProvider *provider;
@property (nonatomic, retain) IPKReview *review;
@property (nonatomic, strong) IPKUser *user;
@property (nonatomic, strong) IPKUser *user2;
@property (nonatomic, retain) NSOrderedSet *top_listings;

-(enum IPKTrackableType)trackableType;
-(enum IPKActivityType)activityType;
@end

@interface IPKActivity (CoreDataGeneratedAccessors)

- (void)insertObject:(IPKProvider *)value inTop_listingsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTop_listingsAtIndex:(NSUInteger)idx;
- (void)insertTop_listings:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTop_listingsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTop_listingsAtIndex:(NSUInteger)idx withObject:(IPKProvider *)value;
- (void)replaceTop_listingsAtIndexes:(NSIndexSet *)indexes withTop_listings:(NSArray *)values;
- (void)addTop_listingsObject:(IPKProvider *)value;
- (void)removeTop_listingsObject:(IPKProvider *)value;
- (void)addTop_listings:(NSOrderedSet *)values;
- (void)removeTop_listings:(NSOrderedSet *)values;
@end

