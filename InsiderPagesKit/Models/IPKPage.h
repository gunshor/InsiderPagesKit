//
//  Page.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKAbstractModel.h"

@class IPKUser;
@class IPKProvider;
@class IPKReview;

@interface IPKPage : IPKAbstractModel

@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSString * description_text;
@property (nonatomic, strong) NSNumber * id;
@property (nonatomic, strong) NSString * image_content_type;
@property (nonatomic, strong) NSString * image_file_name;
@property (nonatomic, strong) NSString * image_file_size;
@property (nonatomic, strong) NSDate * image_updated_at;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * privacy_setting;
@property (nonatomic, strong) NSNumber * remoteID;
@property (nonatomic, strong) NSNumber * sequence;
@property (nonatomic, strong) NSNumber * sort;
@property (nonatomic, strong) NSDate * updatedAt;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSString * section_header;
@property (nonatomic, strong) NSNumber * is_favorite;
@property (nonatomic, strong) NSNumber * is_following;
@property (nonatomic, strong) NSSet *following_users;
@property (nonatomic, strong) IPKUser *owner;
@property (nonatomic, strong) NSOrderedSet *providers;
@property (nonatomic, strong) NSSet *activities;
@property (nonatomic, strong) IPKReview *reviews;

-(NSDictionary*)packToDictionary;
-(void)updateSectionHeader;

@end

@interface IPKPage (CoreDataGeneratedAccessors)

- (void)addFollowersObject:(IPKUser *)value;
- (void)removeFollowersObject:(IPKUser *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

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

@end
