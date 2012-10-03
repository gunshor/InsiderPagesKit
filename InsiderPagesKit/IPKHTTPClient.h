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
enum IPKTrackableType;
@class IPKQueryModel;

@class IPKUser;
@class IPKPage;
@class BLYChannel;

@interface IPKHTTPClient : AFHTTPClient

+ (IPKHTTPClient *)sharedClient;
+ (void)setDevelopmentModeEnabled:(BOOL)enabled;
+ (NSString *)apiVersion;


#pragma mark - Current User
#pragma mark - Registration/Auth/Login
- (void)signInWithFacebookUserID:(NSString*)fbUserId accessToken:(NSString*)fbAccessToken facebookMeResponse:(NSDictionary *)fb_data success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)updateCurrentUserWithSuccess:(void (^)(IPKUser*))success failure:(IPKHTTPClientFailure)failure;

#pragma mark - User Resources

- (void)createPage:(IPKPage *)page success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)deletePageWithId:(NSString *)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)getPagesForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)getFavoritePagesForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)getFollowingPagesForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

#pragma mark - User Actions
- (void)followPageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)followUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)unfollowPageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)unfollowUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

#pragma mark - Public Users
- (void)getUserInfoWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)getFollowersForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)getFollowingForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

#pragma mark - Pages
- (void)getProvidersForPageWithId:(NSString*)pageId sortUser:(IPKUser*)sortUser success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)getFollowersForPageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)addProvidersToPageWithId:(NSString*)pageId providerId:(NSString*)providerId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)addProvidersToPageWithId:(NSString*)pageId providerId:(NSString*)providerId scoopText:(NSString*)scoopText success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)removeProvidersFromPageWithId:(NSString*)pageId providerId:(NSString*)providerId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)reorderProvidersForPageWithId:(NSString*)pageId newOrder:(NSArray*)newOrder success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)getCollaboratorsForPageWithId:(NSString*)pageId sortUser:(IPKUser*)sortUser success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)addCollaboratorsToPageWithId:(NSString*)pageId userID:(NSString*)userID success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)removeCollaboratorsFromPageWithId:(NSString*)pageId userID:(NSString*)userID success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)favoritePageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)unfavoritePageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

#pragma mark - Providers
- (void)getPagesForProviderWithId:(NSString*)providerId withCurrentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

#pragma mark - Search
- (void)providerSearchWithQueryModel:(IPKQueryModel*)queryModel success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)insiderSearchWithQueryModel:(IPKQueryModel*)queryModel success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)pageSearchWithQueryModel:(IPKQueryModel*)queryModel success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;


#pragma mark - Activities
- (void)getActivititesOfType:(enum IPKTrackableType)type includeFollowing:(BOOL)shouldIncludeFollowing currentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)getPageActivititesWithCurrentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

#pragma mark - Notifications
- (void)getNotificationsWithCurrentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;


#pragma mark - Scoops
- (void)getScoopsForUserWithId:(NSString*)userId withCurrentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)getScoopsForProviderWithId:(NSString*)providerId withCurrentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

- (void)getScoopsForPageWithId:(NSString*)pageId withCurrentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure;

//#pragma mark - User



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