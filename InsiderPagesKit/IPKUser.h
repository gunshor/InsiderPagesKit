//
//  IPKUser.h
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "SSDataKit.h"

@class IPKList;
@class IPKTask;

extern NSString *const kIPKCurrentUserChangedNotificationName;

@interface IPKUser : SSRemoteManagedObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSNumber *hasPlus;
@property (nonatomic, strong) NSSet *tasks;
@property (nonatomic, strong) NSSet *lists;
@property (nonatomic, strong) NSString *accessToken;

+ (IPKUser *)currentUser;
+ (void)setCurrentUser:(IPKUser *)user;

@end


@interface IPKUser (CoreDataGeneratedAccessors)
- (void)addTasksObject:(IPKTask *)value;
- (void)removeTasksObject:(IPKTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

- (void)addListsObject:(IPKList *)value;
- (void)removeListsObject:(IPKList *)value;
- (void)addLists:(NSSet *)values;
- (void)removeLists:(NSSet *)values;
@end
