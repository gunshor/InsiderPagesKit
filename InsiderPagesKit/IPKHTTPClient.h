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

@class IPKQueryModel

@class IPKUser;
@class IPKList;
@class IPKTask;
@class BLYChannel;


@interface IPKHTTPClient : AFHTTPClient

+ (IPKHTTPClient *)sharedClient;
+ (void)setDevelopmentModeEnabled:(BOOL)enabled;
+ (NSString *)apiVersion;

- (void)changeUser:(IPKUser *)user;

// Current User
// Registration/Auth/Login
- (void)signInWithFacebookUserID:(NSString*)fbUserId accessToken:(NSString*)fbAccessToken success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)authenticateWithFacebookUserID:(NSString*)fbUserId accessToken:(NSString*)fbAccessToken success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)registerWithFacebook:(NSString*)fbAccessToken success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)updateCurrentUserWithSuccess:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

// User Actions
- (void)followPageWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)followUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)unfollowPageWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)unfollowUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

// User Resources
- (void)teamsForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)followersForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

// Public Users
- (void)getUserInfoWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;


// Pages


// Providers


// Search
- (void)providerSearchWithQueryModel:(IPKQueryModel*)queryModel success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)insiderSearchWithQueryModel:(IPKQueryModel*)queryModel success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
- (void)pageSearchWithQueryModel:(IPKQueryModel*)queryModel success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;


// Activities


// Notifications


// Scoops


// Lists
//- (void)getListsWithSuccess:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
//- (void)createList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
//- (void)updateList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
//- (void)sortLists:(NSArray *)lists success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

// Tasks
//- (void)getTasksWithList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
//- (void)createTask:(IPKTask *)task success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
//- (void)updateTask:(IPKTask *)task success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
//- (void)sortTasks:(NSArray *)tasks inList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
//- (void)archiveAllTasksInList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;
//- (void)archiveCompletedTasksInList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

@end