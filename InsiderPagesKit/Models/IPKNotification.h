//
//  Notification.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SSDataKit.h"

@class IPKUser;

@interface IPKNotification : SSRemoteManagedObject

@property (nonatomic, retain) NSString * action_text;
@property (nonatomic, retain) id activity_parent;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) id path;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSNumber * updated_at;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) IPKUser *user;

@end
