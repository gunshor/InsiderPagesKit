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

@interface IPKPage : IPKAbstractModel

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * description_text;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * image_content_type;
@property (nonatomic, retain) NSString * image_file_name;
@property (nonatomic, retain) NSString * image_file_size;
@property (nonatomic, retain) NSDate * image_updated_at;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * privacy_setting;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSNumber * sequence;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSNumber * is_favorite;
@property (nonatomic, retain) NSSet *followers;
@property (nonatomic, retain) IPKUser *owner;
@property (nonatomic, retain) NSOrderedSet *providers;

-(NSDictionary*)packToDictionary;

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
