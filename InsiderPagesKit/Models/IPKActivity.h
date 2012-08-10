//
//  Activity.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKAbstractModel.h"
#import "IPKDefines.h"

@class IPKPage, IPKUser;

@interface IPKActivity : IPKAbstractModel

@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * team_id;
@property (nonatomic, retain) NSNumber * trackable_id;
@property (nonatomic, retain) NSString * trackable_type;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSNumber * visibility;
@property (nonatomic, retain) IPKUser *user;
@property (nonatomic, retain) IPKPage *page;

-(enum IPKTrackableType)trackableType;
-(enum IPKActivityType)activityType;
-(NSString *)actionText;

@end
