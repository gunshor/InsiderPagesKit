//
//  Page.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKPage.h"
#import "IPKUser.h"
#import "NSDictionary+InsiderPagesKit.h"
#import "NSMutableDictionary+InsiderPagesKit.h"

@implementation IPKPage

@dynamic createdAt;
@dynamic description_text;
@dynamic id;
@dynamic image_content_type;
@dynamic image_file_name;
@dynamic image_file_size;
@dynamic image_updated_at;
@dynamic name;
@dynamic privacy_setting;
@dynamic remoteID;
@dynamic sequence;
@dynamic sort;
@dynamic updatedAt;
@dynamic user_id;
@dynamic section_header;
@dynamic is_favorite;
@dynamic is_following;
@dynamic following_users;
@dynamic owner;
@dynamic providers;
@dynamic activities;

-(NSDictionary*)packToDictionary{
    NSMutableDictionary * packedDictionary = [NSMutableDictionary dictionary];
    [packedDictionary setSafeObject:self.name forKey:@"name"];
//    [packedDictionary setSafeObject:self.description_text forKey:@"description_text"];
//    [packedDictionary setSafeObject:self.id forKey:@"id"];
    [packedDictionary setSafeObject:self.image_content_type forKey:@"image_content_type"];
    [packedDictionary setSafeObject:self.image_file_name forKey:@"image_file_name"];
    [packedDictionary setSafeObject:self.image_file_size forKey:@"image_file_size"];
    [packedDictionary setSafeObject:self.image_updated_at forKey:@"image_updated_at"];
    [packedDictionary setSafeObject:self.privacy_setting forKey:@"privacy_setting"];
    [packedDictionary setSafeObject:self.sequence forKey:@"sequence"];
    [packedDictionary setSafeObject:self.sort forKey:@"sort"];
//    [packedDictionary setSafeObject:self.user_id forKey:@"user_id"];
//    [packedDictionary setSafeObject:self.providers forKey:@"providers"];
//    [packedDictionary setSafeObject:self.owner forKey:@"owner"];
//    [packedDictionary setSafeObject:self.followers forKey:@"followers"];
    return packedDictionary;
}

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];    
	self.name = [dictionary safeObjectForKey:@"name"];
    self.description_text = [dictionary safeObjectForKey:@"description_text"];
    self.id = [dictionary safeObjectForKey:@"id"];
    self.image_content_type = [dictionary safeObjectForKey:@"image_content_type"];
    self.image_file_name = [dictionary safeObjectForKey:@"image_file_name"];
    self.image_file_size = [dictionary safeObjectForKey:@"image_file_size"];
    self.image_updated_at = [dictionary safeObjectForKey:@"image_updated_at"];
    self.privacy_setting = [dictionary safeObjectForKey:@"privacy_setting"];
    self.sequence = [dictionary safeObjectForKey:@"sequence"];
    self.sort = [dictionary safeObjectForKey:@"sort"];
    self.user_id = [dictionary safeObjectForKey:@"user_id"];
    self.providers = [dictionary safeObjectForKey:@"providers"];
    if ([dictionary safeObjectForKey:@"user_id"]) {
//        self.owner = [[IPKUser objectWithRemoteID:self.user_id] MR_inThreadContext];
    }
    self.following_users = [dictionary safeObjectForKey:@"followers"];
    if ([dictionary safeObjectForKey:@"is_favorite"]) {
        self.is_favorite = [dictionary safeObjectForKey:@"is_favorite"];
    }
    else {
        self.is_favorite = [NSNumber numberWithBool:NO];
    }
    if ([dictionary safeObjectForKey:@"is_following"]) {
        self.is_following = [dictionary safeObjectForKey:@"is_following"];
    }
    else {
        self.is_following = [NSNumber numberWithBool:NO];
    }
    
    if ([self.is_favorite boolValue]) {
        self.section_header = @"Favorite";
    }else if ([self.is_following boolValue]){
        self.section_header = @"Following";
    }else if([self.user_id isEqualToNumber: [[IPKUser currentUser] id]]){
        self.section_header = @"Mine";
    }
}

-(void)updateSectionHeader{
    if ([self.is_favorite boolValue]) {
        self.section_header = @"Favorite";
    }else if ([self.is_following boolValue]){
        self.section_header = @"Following";
    }else if([self.user_id isEqualToNumber: [[IPKUser currentUser] id]]){
        self.section_header = @"Mine";
    }
}

#pragma mark - Apple Bug NSMutableSet issue
// added this based on advice found here: http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
static NSString *const kItemsKey = @"providers";

- (void)insertObject:(IPKProvider *)value inProvidersAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)removeObjectFromProvidersAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)insertProviders:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet insertObjects:values atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)removeProvidersAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)replaceObjectInProvidersAtIndex:(NSUInteger)idx withObject:(IPKProvider *)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)replaceProvidersAtIndexes:(NSIndexSet *)indexes withProviders:(NSArray *)values {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)addProvidersObject:(IPKProvider *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
}

- (void)removeProvidersObject:(IPKProvider *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
        [tmpOrderedSet removeObject:value];
        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
    }
}

- (void)addProviders:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
        [tmpOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kItemsKey];
    }
}

- (void)removeProviders:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kItemsKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (id value in values) {
        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
        if (idx != NSNotFound) {
            [indexes addIndex:idx];
        }
    }
    if ([indexes count] > 0) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
        [tmpOrderedSet removeObjectsAtIndexes:indexes];
        [self setPrimitiveValue:tmpOrderedSet forKey:kItemsKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kItemsKey];
    }
}

@end
