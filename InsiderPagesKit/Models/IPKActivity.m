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
#import "NSDictionary+InsiderPagesKit.h"

@implementation IPKActivity

@dynamic action;
@dynamic created_at;
@dynamic id;
@dynamic team_id;
@dynamic trackable_id;
@dynamic trackable_type;
@dynamic updated_at;
@dynamic user_id;
@dynamic visibility;
@dynamic user;
@dynamic page;

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
    }else{
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
            actionText = [NSString stringWithFormat:@"%@ added a ", self.user.name];
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
            actionText = [actionText stringByAppendingFormat:@"%@ with ID %@ ", [self.trackable_type lowercaseString], self.trackable_id];
            break;
        case IPKTrackableTypeReview:
            actionText = [actionText stringByAppendingFormat:@"a scoop with ID %@ ", self.trackable_id];
            break;
        case IPKTrackableTypeTeam:
            actionText = [actionText stringByAppendingFormat:@"%@ with ID %@ ", [self.trackable_type lowercaseString], self.trackable_id];
            break;
        case IPKTrackableTypeUser:
            actionText = [actionText stringByAppendingFormat:@"%@ with ID %@ ", [self.trackable_type lowercaseString], self.trackable_id];
            break;
            
        default:
            actionText = [actionText stringByAppendingFormat:@"%@ with ID %@ ", [self.trackable_type lowercaseString], self.trackable_id];
            break;
    }

    
    return actionText;
}

@end
