//
//  Notification.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKAbstractModel.h"

@class IPKUser;

@interface IPKNotification : IPKAbstractModel

@property (nonatomic, retain) NSString * action_text;
@property (nonatomic, retain) id activity_parent;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) IPKUser *user;

@end
