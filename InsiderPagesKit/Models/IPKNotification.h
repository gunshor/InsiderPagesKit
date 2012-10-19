//
//  IPKNotification.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//

#import "IPKAbstractModel.h"

@class IPKUser;

@interface IPKNotification : IPKAbstractModel

@property (nonatomic, strong) NSString * action_text;
@property (nonatomic, strong) id activity_parent;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSString * path;
@property (nonatomic, strong) NSNumber * read;
@property (nonatomic, strong) NSNumber * remoteID;
@property (nonatomic, strong) NSDate * updatedAt;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) IPKUser *user;
@property (nonatomic, retain) NSSet *mentioned_users;

@end

@interface IPKNotification (CoreDataGeneratedAccessors)

- (void)addMentioned_usersObject:(IPKUser *)value;
- (void)removeMentioned_usersObject:(IPKUser *)value;
- (void)addMentioned_users:(NSSet *)values;
- (void)removeMentioned_users:(NSSet *)values;

@end
