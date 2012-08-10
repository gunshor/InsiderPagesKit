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
	self.action = [dictionary safeObjectForKey:@"name"];
    self.id = [dictionary safeObjectForKey:@"id"];
    self.team_id = [dictionary safeObjectForKey:@"team_id"];
    self.page = [IPKPage objectWithRemoteID:self.team_id];
    self.trackable_id = [dictionary safeObjectForKey:@"trackable_id"];
    self.trackable_type = [dictionary safeObjectForKey:@"trackable_type"];
    self.user_id = [dictionary safeObjectForKey:@"user_id"];
    self.user = [IPKUser objectWithRemoteID:self.user_id];
    self.visibility = [dictionary safeObjectForKey:@"visibility"];
}

-(enum IPKActivityType)activityType{
    if ([self.trackable_type isEqualToString:@"User"]) {
        return IPKActivityTypeUser;
    }
    else if ([self.trackable_type isEqualToString:@"Provider"]){
        return IPKActivityTypeProvider;
    }
    else if ([self.trackable_type isEqualToString:@"Review"]){
        return IPKActivityTypeReview;
    }
    else{
        return IPKActivityTypeAll;
    }
}

@end
