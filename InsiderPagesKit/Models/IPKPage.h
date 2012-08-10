//
//  Page.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKAbstractModel.h"

@class IPKUser;

@interface IPKPage : IPKAbstractModel

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * description_text;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * image_content_type;
@property (nonatomic, retain) NSString * image_file_name;
@property (nonatomic, retain) NSString * image_file_size;
@property (nonatomic, retain) NSDate * image_updated_at;
@property (nonatomic, retain) NSNumber * privacy_setting;
@property (nonatomic, retain) NSNumber * sequence;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSOrderedSet *providers;
@property (nonatomic, retain) IPKUser *owner;
@property (nonatomic, retain) NSSet *followers;

-(NSDictionary*)packToDictionary;

@end

@interface IPKPage (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inProvidersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromProvidersAtIndex:(NSUInteger)idx;
- (void)insertProviders:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeProvidersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInProvidersAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceProvidersAtIndexes:(NSIndexSet *)indexes withProviders:(NSArray *)values;
- (void)addProvidersObject:(NSManagedObject *)value;
- (void)removeProvidersObject:(NSManagedObject *)value;
- (void)addProviders:(NSOrderedSet *)values;
- (void)removeProviders:(NSOrderedSet *)values;
- (void)addFollowersObject:(IPKUser *)value;
- (void)removeFollowersObject:(IPKUser *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

@end
