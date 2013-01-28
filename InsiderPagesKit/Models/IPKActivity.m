//
//  IPKActivity.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//

#import "IPKActivity.h"
#import "IPKPage.h"
#import "IPKUser.h"
#import "IPKProvider.h"
#import "IPKReview.h"
#import "NSDictionary+InsiderPagesKit.h"
#import "IPKDefines.h"

@implementation IPKActivity

@dynamic action;
@dynamic createdAt;
@dynamic remoteID;
@dynamic team_id;
@dynamic trackable_id;
@dynamic trackable_type;
@dynamic updatedAt;
@dynamic user_id;
@dynamic visibility;
@dynamic page;
@dynamic provider;
@dynamic review;
@dynamic user;
@dynamic user2;
@dynamic top_listings;

+ (NSString *)entityName {
	return @"IPKActivity";
}

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];    
	self.action = [dictionary safeObjectForKey:@"action"];
    self.team_id = [dictionary safeObjectForKey:@"team_id"];
    if ([dictionary safeObjectForKey:@"team"]) {
        self.page = [IPKPage objectWithDictionary:[dictionary safeObjectForKey:@"team"]];
    }else if(self.team_id != nil){
        self.page = [IPKPage objectWithRemoteID:self.team_id];
    }
    self.trackable_id = [dictionary safeObjectForKey:@"trackable_id"];
    self.trackable_type = [dictionary safeObjectForKey:@"trackable_type"];
    self.user_id = [dictionary safeObjectForKey:@"user_id"];
    if ([dictionary safeObjectForKey:@"user"]) {
        self.user = [IPKUser objectWithDictionary:[dictionary safeObjectForKey:@"user"]];
    }else{
        self.user = [IPKUser objectWithRemoteID:self.user_id];
    }
    if ([dictionary safeObjectForKey:@"trackable"] && ([self.trackable_type isEqualToString:@"Provider"] || [self.trackable_type isEqualToString:@"CgListing"])) {
        self.provider = [IPKProvider objectWithDictionary:[dictionary safeObjectForKey:@"trackable"]];
    }
    else if ([dictionary safeObjectForKey:@"trackable"] && [self.trackable_type isEqualToString:@"Review"]) {
        self.review = [IPKReview objectWithDictionary:[dictionary safeObjectForKey:@"trackable"]];
    }
    else if ([dictionary safeObjectForKey:@"trackable"] && [self.trackable_type isEqualToString:@"User"]) {
        self.user2 = [IPKUser objectWithDictionary:[dictionary safeObjectForKey:@"trackable"]];
    }
    self.visibility = [dictionary safeObjectForKey:@"visibility"];
    
    if ([dictionary safeObjectForKey:@"top_listings"]){
        for (int i = 0; i < [[dictionary safeObjectForKey:@"top_listings"] count] - 1; i++ ) {
            NSDictionary * providerDictionary = [[dictionary safeObjectForKey:@"top_listings"] objectAtIndex:i];
            IPKProvider * provider = [IPKProvider objectWithDictionary:providerDictionary context:self.managedObjectContext];
            if (![self.top_listings containsObject:provider]) {
                [self insertObject:provider inTop_listingsAtIndex:i];
            }
        }
    }
}

-(enum IPKTrackableType)trackableType{
    if ([self.trackable_type isEqualToString:@"User"]) {
        return IPKTrackableTypeUser;
    }
    else if ([self.trackable_type isEqualToString:@"Provider"]){
        return IPKTrackableTypeProvider;
    }
    else if ([self.trackable_type isEqualToString:@"Review"]){
        return IPKTrackableTypeReview;
    }
    else if ([self.trackable_type isEqualToString:@"Team"]){
        return IPKTrackableTypeTeam;
    }
    else if ([self.trackable_type isEqualToString:@"CgListing"]){
        return IPKTrackableTypeCgListing;
    }
    else{
        return IPKTrackableTypeAll;
    }
}

-(enum IPKActivityType)activityType{
    if ([self.action isEqualToString:@"create"]) {
        return IPKActivityTypeCreate;
    }
    else if ([self.action isEqualToString:@"add"]){
        return IPKActivityTypeAdd;
    }
    else if ([self.action isEqualToString:@"update"]){
        return IPKActivityTypeUpdate;
    }
    else if ([self.action isEqualToString:@"team"]){
        return IPKActivityTypeTeam;
    }
    else if ([self.action isEqualToString:@"view"]){
        return IPKActivityTypeView;
    }
    else if ([self.action isEqualToString:@"follow"]){
        return IPKActivityTypeFollow;
    }
    else if ([self.action isEqualToString:@"collaborate"]){
        return IPKActivityTypeCollaborate;
    }
    else if ([self.action isEqualToString:@"favorite"]){
        return IPKActivityTypeFavorite;
    }
    else if ([self.action isEqualToString:@"rank"]){
        return IPKActivityTypeRank;
    }
    else if ([self.action isEqualToString:@"accepted"]){
        return IPKActivityTypeAccept;
    }
    else if ([self.action isEqualToString:@"disqus_create"]){
        return IPKActivityTypeComment;
    }
    else{
        return IPKActivityTypeAll;
    }
}

- (void)insertObject:(IPKProvider *)value inTop_listingsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"top_listings"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:@"top_listings"]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"top_listings"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"top_listings"];
}

@end
