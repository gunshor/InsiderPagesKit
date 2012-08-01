//
//  IPKHTTPClient.h
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "AFNetworking.h"

typedef void (^IPKHTTPClientSuccess)(AFJSONRequestOperation *operation, id responseObject);
typedef void (^IPKHTTPClientFailure)(AFJSONRequestOperation *operation, NSError *error);

@class IPKUser;
@class IPKList;
@class IPKTask;
@class BLYChannel;

@interface IPKHTTPClient : AFHTTPClient

+ (IPKHTTPClient *)sharedClient;
+ (void)setDevelopmentModeEnabled:(BOOL)enabled;
+ (NSString *)apiVersion;
- (void)setClientID:(NSString *)clientID secret:(NSString *)clientSecret;

- (void)changeUser:(IPKUser *)user;

// User
- (void)signInWithLogin:(NSString *)login password:(NSString *)password success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)signInWithAuthorizationCode:(NSString *)code success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)signUpWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)updateCurrentUserWithSuccess:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

// Lists
- (void)getListsWithSuccess:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)createList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)updateList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)sortLists:(NSArray *)lists success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

// Tasks
- (void)getTasksWithList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)createTask:(IPKTask *)task success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)updateTask:(IPKTask *)task success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)sortTasks:(NSArray *)tasks inList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)archiveAllTasksInList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)archiveCompletedTasksInList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

@end