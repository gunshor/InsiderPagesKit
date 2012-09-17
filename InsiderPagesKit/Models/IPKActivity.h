//
//  Activity.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
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
@property (nonatomic, strong) IPKReview *review;
@property (nonatomic, strong) IPKUser *user;
@property (nonatomic, strong) IPKUser *user2;

-(enum IPKTrackableType)trackableType;
-(enum IPKActivityType)activityType;

@end
