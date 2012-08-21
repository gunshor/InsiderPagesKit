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

@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSNumber * team_id;
@property (nonatomic, retain) NSNumber * trackable_id;
@property (nonatomic, retain) NSString * trackable_type;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSNumber * visibility;
@property (nonatomic, retain) IPKPage *page;
@property (nonatomic, retain) IPKProvider *provider;
@property (nonatomic, retain) IPKReview *review;
@property (nonatomic, retain) IPKUser *user;

-(enum IPKTrackableType)trackableType;
-(enum IPKActivityType)activityType;
-(NSString *)actionText;

@end
