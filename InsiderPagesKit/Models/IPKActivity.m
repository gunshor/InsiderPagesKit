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
#import "RHManagedObjectContextManager.h"
#import "NSDictionary+InsiderPagesKit.h"

@implementation IPKActivity

@dynamic action;
@dynamic createdAt;
@dynamic id;
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

+ (NSString *)entityName {
	return @"IPKActivity";
}

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];    
	self.action = [dictionary safeObjectForKey:@"action"];
    self.id = [dictionary safeObjectForKey:@"id"];
    self.team_id = [dictionary safeObjectForKey:@"team_id"];
    if ([dictionary safeObjectForKey:@"team"]) {
        self.page = [IPKPage objectWithDictionary:[dictionary safeObjectForKey:@"team"]];
        [self.page save];
    }else{
        self.page = [IPKPage objectWithRemoteID:self.team_id context:[[RHManagedObjectContextManager sharedInstance] managedObjectContext]];
        [self.page save];
    }
    self.trackable_id = [dictionary safeObjectForKey:@"trackable_id"];
    self.trackable_type = [dictionary safeObjectForKey:@"trackable_type"];
    self.user_id = [dictionary safeObjectForKey:@"user_id"];
    if ([dictionary safeObjectForKey:@"user"]) {
        self.user = [IPKUser objectWithDictionary:[dictionary safeObjectForKey:@"user"]];
        [self.user save];
    }else{
        self.user = [IPKUser objectWithRemoteID:self.user_id];
        [self.user save];
    }
    if ([dictionary safeObjectForKey:@"trackable"] && [self.trackable_type isEqualToString:@"Provider"]) {
        self.provider = [IPKProvider objectWithDictionary:[dictionary safeObjectForKey:@"trackable"]];
        [self.provider save];
    }
    if ([dictionary safeObjectForKey:@"trackable"] && [self.trackable_type isEqualToString:@"Review"]) {
        self.review = [IPKReview objectWithDictionary:[dictionary safeObjectForKey:@"trackable"]];
        [self.review save];
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
    else{
        return IPKTrackableTypeAll;
    }
}

-(enum IPKActivityType)activityType{
    if ([self.action isEqualToString:@"create"]) {
        return IPKActivityTypeCreate;
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
    else{
        return IPKActivityTypeAll;
    }
}

-(NSString *)actionText{
    NSString * actionText = nil;
    
    switch ([self activityType]) {
        case IPKActivityTypeCreate:
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
        case IPKTrackableTypeReview:
            actionText = [actionText stringByAppendingFormat:@"a scoop for %@ ", ((IPKProvider*)[IPKProvider objectWithRemoteID:self.review.listing_id]).full_name];
            break;
        case IPKTrackableTypeTeam:
            actionText = [actionText stringByAppendingFormat:@"%@ with ID %@ ", [self.trackable_type lowercaseString], self.trackable_id];
            break;
        case IPKTrackableTypeUser:
            actionText = [actionText stringByAppendingFormat:@"profile"];
            break;
            
        default:
            actionText = [actionText stringByAppendingFormat:@"%@ with ID %@ ", [self.trackable_type lowercaseString], self.trackable_id];
            break;
    }
    
    
    return actionText;
}

@end
