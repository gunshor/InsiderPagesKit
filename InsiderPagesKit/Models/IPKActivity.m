//
//  Activity.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
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
    else{
        return IPKActivityTypeAll;
    }
}

-(NSString *)actionText{
    NSString * actionText = nil;
    
    switch ([self activityType]) {
        case IPKActivityTypeCreate:
            actionText = [NSString stringWithFormat:@"%@ created ", self.user.name];
            break;
        case IPKActivityTypeAdd:
            actionText = [NSString stringWithFormat:@"%@ added ", self.user.name];
            break;
        case IPKActivityTypeUpdate:
            actionText = [NSString stringWithFormat:@"%@ updated ", self.user.name];
            break;
        case IPKActivityTypeTeam:
            actionText = [NSString stringWithFormat:@"%@ posted ", self.user.name];
            break;
        case IPKActivityTypeView:
            actionText = [NSString stringWithFormat:@"%@ viewed ", self.user.name];
            break;
        case IPKActivityTypeFollow:
            actionText = [NSString stringWithFormat:@"%@ followed ", self.user.name];
            break;
        case IPKActivityTypeCollaborate:
            actionText = [NSString stringWithFormat:@"%@ ", self.user.name];
            break;
        case IPKActivityTypeFavorite:
            actionText = [NSString stringWithFormat:@"%@ favorited ", self.user.name];
            break;
        case IPKActivityTypeRank:
            actionText = [NSString stringWithFormat:@"%@ reranked ", self.user.name];
            break;
        case IPKActivityTypeAll:
            actionText = [NSString stringWithFormat:@"%@ activity ", self.user.name];
            break;
            
        default:
            actionText = [NSString stringWithFormat:@"%@ activity ", self.user.name];
            break;
    }
    
    switch ([self trackableType]) {
        case IPKTrackableTypeProvider:
            actionText = [actionText stringByAppendingFormat:@"%@", self.provider.full_name];
            break;
        case IPKTrackableTypeCgListing:
            actionText = [actionText stringByAppendingFormat:@"%@", self.provider.full_name];
            break;
        case IPKTrackableTypeReview:
            actionText = [actionText stringByAppendingFormat:@"a scoop for %@", ((IPKProvider*)[IPKProvider objectWithRemoteID:self.review.listing_id]).full_name];
            break;
        case IPKTrackableTypeTeam:
            actionText = [actionText stringByAppendingFormat:@"%@ with ID %@", [self.trackable_type lowercaseString], self.trackable_id];
            break;
        case IPKTrackableTypeUser:
            actionText = [actionText stringByAppendingFormat:@"invited %@", self.user2.name];
            break;
            
        default:
            actionText = [actionText stringByAppendingFormat:@"%@ with ID %@", [self.trackable_type lowercaseString], self.trackable_id];
            break;
    }
    
    
    return actionText;
}

@end
