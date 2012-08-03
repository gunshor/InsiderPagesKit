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

@class IPKQueryModel;

@class IPKUser;
@class IPKPage;
@class BLYChannel;


@interface IPKHTTPClient : AFHTTPClient

+ (IPKHTTPClient *)sharedClient;
+ (void)setDevelopmentModeEnabled:(BOOL)enabled;
+ (NSString *)apiVersion;

- (void)changeUser:(IPKUser *)user;

#pragma mark - Current User
#pragma mark - Registration/Auth/Login
- (void)signInWithFacebookUserID:(NSString*)fbUserId accessToken:(NSString*)fbAccessToken success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)authenticateWithFacebookUserID:(NSString*)fbUserId accessToken:(NSString*)fbAccessToken success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)registerWithFacebookMeResponse:(NSDictionary*)fb_data success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)updateCurrentUserWithSuccess:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

#pragma mark - User Actions
- (void)followPageWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)followUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)unfollowPageWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)unfollowUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

#pragma mark - User Resources
- (void)teamsForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)followersForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)createPage:(IPKPage *)page success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;


#pragma mark - Public Users
- (void)getUserInfoWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)getFollowersForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)getFollowingForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

#pragma mark - Pages
- (void)getProvidersForPageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)getFollowersForPageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)addProvidersToPageWithId:(NSString*)pageId providerId:(NSString*)providerId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)addProvidersToPageWithId:(NSString*)pageId providerId:(NSString*)providerId scoopText:(NSString*)scoopText success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)removeProvidersFromoPageWithId:(NSString*)pageId providerId:(NSString*)providerId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

#pragma mark - Providers


#pragma mark - Search
- (void)providerSearchWithQueryModel:(IPKQueryModel*)queryModel success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)insiderSearchWithQueryModel:(IPKQueryModel*)queryModel success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)pageSearchWithQueryModel:(IPKQueryModel*)queryModel success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;


#pragma mark - Activities


#pragma mark - Notifications


#pragma mark - Scoops


#pragma mark - User



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