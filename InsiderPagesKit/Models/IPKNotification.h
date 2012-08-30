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

@property (nonatomic, strong) NSString * action_text;
@property (nonatomic, strong) id activity_parent;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSNumber * id;
@property (nonatomic, strong) NSString * path;
@property (nonatomic, strong) NSNumber * read;
@property (nonatomic, strong) NSNumber * remoteID;
@property (nonatomic, strong) NSDate * updatedAt;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) IPKUser *user;

@end
