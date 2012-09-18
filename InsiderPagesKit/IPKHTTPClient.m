//
//  IPKTTPClient.m
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "IPKHTTPClient.h"
#import "IPKUser.h"
#import "IPKPage.h"
#import "IPKProvider.h"
#import "IPKQueryModel.h"
#import "IPKNotification.h"
#import "IPKActivity.h"
#import "IPKReview.h"
#import "IPKDefines.h"

static BOOL __developmentMode = NO;

@interface IPKHTTPClient ()
- (void)_userChanged:(NSNotification *)notification;
@end

@implementation IPKHTTPClient {
	dispatch_queue_t _callbackQueue;
}

#pragma mark - Singleton

+ (IPKHTTPClient *)sharedClient {
	static IPKHTTPClient *sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedClient = [[self alloc] init];
	});
	return sharedClient;
}


+ (void)setDevelopmentModeEnabled:(BOOL)enabled {
	__developmentMode = enabled;
}


+ (NSString *)apiVersion {
	return @"v1";
}


#pragma mark - NSObject

- (id)init {
	NSURL *base = nil;
	NSString *version = [[self class] apiVersion];
	if (__developmentMode) {
		base = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@/", kIPKDevelopmentAPIScheme, kIPKDevelopmentAPIHost, version]];
	} else {
		base = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@/", kIPKAPIScheme, kIPKAPIHost, version]];
	}
	
	if ((self = [super initWithBaseURL:base])) {
		// Use JSON
		[self registerHTTPOperationClass:[AFJSONRequestOperation class]];
		[self setDefaultHeader:@"Accept" value:@"application/json"];
        if ([IPKUser userHasLoggedIn]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSNumber *userID = [userDefaults objectForKey:@"IPKUserID"];
            if ([IPKUser existingObjectWithRemoteID:userID]) {
                [IPKUser setCurrentUser:[IPKUser existingObjectWithRemoteID:userID]];
            }
        }
		
		_callbackQueue = dispatch_queue_create("com.insiderpages.ios.network-callback-queue", 0);
	}
    [self setDefaultHeader:@"User-Agent" value:@"InsiderPages/1.0"];
	return self;
}


- (void)dealloc {
	IPKDispatchRelease(_callbackQueue);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - AFHTTPClient

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
	NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	return request;
}


- (void)enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
	operation.successCallbackQueue = _callbackQueue;
	operation.failureCallbackQueue = _callbackQueue;
	[super enqueueHTTPRequestOperation:operation];
}


#pragma mark - Current User
#pragma mark - Registration/Auth/Login
- (void)signInWithFacebookUserID:(NSString*)fbUserId accessToken:(NSString*)fbAccessToken facebookMeResponse:(NSDictionary *)fb_data success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            fbUserId, @"fb_user_id",
                            fbAccessToken, @"fb_access_token",
                            fb_data, @"fb_data",
                            nil];
    
    [self postPath:@"login" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __weak NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context performBlockAndWait:^{
            IPKUser *user = [IPKUser objectWithDictionary:[responseObject objectForKey:@"user"]];
            user.fb_access_token = fbAccessToken;
            NSHTTPCookie *cookie = [[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] objectAtIndex:0];
            user.accessToken = [cookie value];
            [IPKUser setCurrentUser:user];
            [context MR_save];
        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)updateCurrentUserWithSuccess:(void (^)(IPKUser*))success failure:(IPKHTTPClientFailure)failure{    
    [[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]] updateWithSuccess:^(){
        [IPKUser setCurrentUser:[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]]];
        
        if (success) {
            success([IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]]);
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                         if (failure) {
                                             failure((AFJSONRequestOperation *)operation, error);
                                         }}];
}

#pragma mark - User Actions
- (void)followPageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID, @"follow_id",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/followers", pageId];
    [self postPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [[RHManagedObjectContextManager sharedInstance] managedObjectContext];
        IPKPage * pageToFollow = [IPKPage objectWithRemoteID:@([pageId integerValue])];
        [[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]] addFollowedPagesObject:pageToFollow];
        [pageToFollow setIs_following:[NSNumber numberWithBool:YES]];
        [pageToFollow updateSectionHeader];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)followUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userId, @"follow_id",
                            nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * urlString = [NSString stringWithFormat:@"users/%@/following", [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID ? [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID : [userDefaults objectForKey:@"IPKUserID"]];
    [self postPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        if (operation.response.statusCode != 403) {
            IPKUser * userToFollow = [IPKUser objectWithRemoteID:@([userId integerValue])];
            [[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]] addFollowedUsersObject:userToFollow];
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        }
        
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)unfollowPageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID, @"follow_id",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/followers", pageId];
    [self deletePath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        IPKPage * pageToFollow = [IPKPage objectWithRemoteID:@([pageId integerValue])];
        //force fault
        [pageToFollow name];
        [[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]] removeFollowedPagesObject:pageToFollow];
        [pageToFollow setIs_following:[NSNumber numberWithBool:NO]];
        [pageToFollow updateSectionHeader];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)unfollowUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userId, @"follow_id",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"users/%@/following", [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID];
    [self deletePath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        IPKUser * userToUnfollow = [IPKUser objectWithRemoteID:@([userId integerValue])];
        [[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]] removeFollowedUsersObject:userToUnfollow];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

#pragma mark - User Resources
- (void)getPagesForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString *url = [NSString stringWithFormat:@"users/%@/teams", userId];
    
    [self getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        for (NSDictionary* pageDictionary in [responseObject objectForKey:@"teams"]) {
            IPKPage * page = nil;
            page = [IPKPage objectWithDictionary:pageDictionary];
        }
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)getFavoritePagesForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString *url = [NSString stringWithFormat:@"users/%@/favorite_teams", userId];
    
    [self getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        for (NSDictionary* pageDictionary in [responseObject objectForKey:@"teams"]) {
            IPKPage * page = nil;
            page = [IPKPage objectWithDictionary:pageDictionary];
        }
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)getFollowingPagesForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString *url = [NSString stringWithFormat:@"users/%@/following_teams", userId];
    
    [self getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        for (NSDictionary* pageDictionary in [responseObject objectForKey:@"teams"]) {
            IPKPage * page = nil;
            page = [IPKPage objectWithDictionary:pageDictionary];
        }
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)createPage:(IPKPage *)page success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSMutableDictionary * pageDictionary = [[page packToDictionary] mutableCopy];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:pageDictionary
                            , @"team",
                            nil];
    [self postPath:@"teams" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        [IPKPage objectWithDictionary:responseObject];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)deletePageWithId:(NSString *)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString * urlString = [NSString stringWithFormat:@"teams/%@", pageId];
    [self deletePath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        IPKPage * page = [IPKPage existingObjectWithRemoteID:@([pageId intValue])];
        [page MR_deleteInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

#pragma mark - Public Users
- (void)getUserInfoWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userId, @"id",
                            nil];
    
    [[IPKHTTPClient sharedClient] getPath:@"users" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        [IPKUser objectWithDictionary:responseObject];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)getFollowersForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString *url = [NSString stringWithFormat:@"users/%@/followers", userId];
    
    [self getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        for (NSDictionary* userDictionary in [responseObject objectForKey:@"followers"]) {
            IPKUser * user = nil;
            user = [IPKUser objectWithDictionary:userDictionary];
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        }
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)getFollowingForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString *url = [NSString stringWithFormat:@"users/%@/following", userId];
    
    [self getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        for (NSDictionary* userDictionary in [responseObject objectForKey:@"following"]) {
            IPKUser * user = nil;
            user = [IPKUser objectWithDictionary:userDictionary];
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        }
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

#pragma mark - Pages
- (void)getProvidersForPageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString *url = [NSString stringWithFormat:@"teams/%@/providers", pageId];
    [self getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        for (NSDictionary * providerDictionary in [responseObject objectForKey:@"providers"]) {
            IPKProvider * provider = [IPKProvider objectWithDictionary:providerDictionary];
            [provider addPagesObject:[IPKPage objectWithRemoteID:@([pageId integerValue])]];
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        }
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)getFollowersForPageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString *url = [NSString stringWithFormat:@"teams/%@/followers", pageId];
    [self getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        for (NSDictionary* userDictionary in [responseObject objectForKey:@"followers"]) {
            IPKUser * user = nil;
            user = [IPKUser objectWithDictionary:userDictionary];
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        }
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)addProvidersToPageWithId:(NSString*)pageId providerId:(NSString*)providerId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            providerId, @"provider_id",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/providers", pageId];
    [self postPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        IPKPage * page = [IPKPage objectWithRemoteID:@([pageId intValue])];
        IPKProvider * providerToAdd = [IPKProvider objectWithRemoteID:@([providerId intValue])];
        [page addProvidersObject:providerToAdd];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)addProvidersToPageWithId:(NSString*)pageId providerId:(NSString*)providerId scoopText:(NSString*)scoopText success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            providerId, @"provider_id",scoopText, @"scoop",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/providers", pageId];
    [self deletePath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        IPKPage * page = [IPKPage existingObjectWithRemoteID:@([pageId intValue])];
        IPKProvider * providerToAdd = [IPKProvider existingObjectWithRemoteID:@([providerId intValue])];
        [page addProvidersObject:providerToAdd];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)removeProvidersFromPageWithId:(NSString*)pageId providerId:(NSString*)providerId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            providerId, @"provider_id",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/providers", pageId];
    [self postPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        IPKPage * page = [IPKPage existingObjectWithRemoteID:@([pageId intValue])];
        IPKProvider * providerToRemove = [IPKProvider existingObjectWithRemoteID:@([providerId intValue])];
        [page removeProvidersObject:providerToRemove];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)favoritePageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure  {  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:pageId, @"id", nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/favorite", pageId];
    [self postPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        IPKPage * page = [IPKPage existingObjectWithRemoteID:@([pageId intValue])];
        [page setIs_favorite:[NSNumber numberWithBool:YES]];
        [page updateSectionHeader];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}


- (void)unfavoritePageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:pageId, @"id",nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/unfavorite", pageId];
    [self postPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        IPKPage * page = [IPKPage existingObjectWithRemoteID:@([pageId intValue])];
        [page setIs_favorite:[NSNumber numberWithBool:NO]];
        [page updateSectionHeader];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}


#pragma mark - Providers
- (void)getPagesForProviderWithId:(NSString*)providerId withCurrentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString * urlString = [NSString stringWithFormat:@"providers/%@/pages", providerId];
    NSString * provider_type = ((IPKProvider*)[IPKProvider objectWithRemoteID:@([providerId intValue])]).cg_listing_id ? @"Provider" : @"CgListing";
    NSLog(@"%@", [IPKProvider objectWithRemoteID:@([providerId intValue])]);
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:provider_type, @"provider_type", nil];
    [self getPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        for (NSDictionary * pageDictionary in [responseObject objectForKey:@"pages"]) {
            IPKPage * page = [IPKPage objectWithDictionary:pageDictionary];
            IPKProvider * provider = [IPKProvider objectWithRemoteID:@([providerId intValue])];
            [page addProvidersObject:provider];
        }
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

#pragma mark - Search
- (void)providerSearchWithQueryModel:(IPKQueryModel*)queryModel success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    [self postPath:@"provider_search" parameters:[queryModel packToDictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __weak NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context performBlock:^{
            for (NSDictionary * providerDictionary in [responseObject objectForKey:@"results"]) {
                [IPKProvider objectWithDictionary:providerDictionary];
                
            }
        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)insiderSearchWithQueryModel:(IPKQueryModel*)queryModel success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    [self postPath:@"insider_search" parameters:[queryModel packToDictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __weak NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context performBlock:^{
            for (NSDictionary * insiderDictionary in [responseObject objectForKey:@"results"]) {
                [IPKUser objectWithDictionary:insiderDictionary];
                [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
            }
        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)pageSearchWithQueryModel:(IPKQueryModel*)queryModel success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    [self postPath:@"page_search" parameters:[queryModel packToDictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __weak NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context performBlock:^{
            for (NSDictionary * pageDictionary in [responseObject objectForKey:@"results"]) {
                [IPKPage objectWithDictionary:pageDictionary];
            }
        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}


#pragma mark - Activities
- (void)getActivititesOfType:(enum IPKTrackableType)type includeFollowing:(BOOL)shouldIncludeFollowing currentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @(type), @"type",
                            @(shouldIncludeFollowing), @"following",
                            perPage, @"per_page",
                            currentPage, @"page",
                            nil];
    
    [self getPath:@"activities" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __weak NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context performBlockAndWait:^{
            for (NSDictionary* activityDictionary in [responseObject objectForKey:@"activities"]) {
                [IPKActivity objectWithDictionary:activityDictionary context:[NSManagedObjectContext MR_contextForCurrentThread]];
            }
            [context MR_save];
        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)getPageActivititesWithCurrentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    
    if ([currentPage isEqualToNumber:@1]) {
        [IPKActivity deleteAllLocal];
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            perPage, @"per_page",
                            currentPage, @"page",
                            nil];
    
    [self getPath:@"activities/pages" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __weak NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context performBlockAndWait:^{
            for (NSDictionary* activityDictionary in [responseObject objectForKey:@"activities"]) {
                [IPKActivity objectWithDictionary:activityDictionary];
            }
            [context MR_save];
        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

#pragma mark - Notifications
- (void)getNotificationsWithCurrentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            perPage, @"per_page",
                            currentPage, @"page",
                            nil];
    [self getPath:@"notifications" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        __weak NSManagedObjectContext *context = [IPKUser mainContext];
        //        [context performBlock:^{
        if ([[responseObject objectForKey:@"notifications"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary* notificationDictionary in [responseObject objectForKey:@"notifications"]) {
                [IPKNotification objectWithDictionary:notificationDictionary];
                [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
            }
        }
        //        }];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

#pragma mark - Scoops

- (void)getScoopsForUserWithId:(NSString*)userId withCurrentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userId, @"user_id",
                            perPage, @"per_page",
                            currentPage, @"page",
                            nil];
    [self _getScoopsWithParams:params success:success failure:failure];
}

- (void)getScoopsForProviderWithId:(NSString*)providerId withCurrentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            providerId, @"provider_id",
                            perPage, @"per_page",
                            currentPage, @"page",
                            nil];
    [self _getScoopsWithParams:params success:success failure:failure];
}

- (void)getScoopsForPageWithId:(NSString*)pageId withCurrentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            pageId, @"team_id",
                            perPage, @"per_page",
                            currentPage, @"page",
                            nil];
    [self _getScoopsWithParams:params success:success failure:failure];
}

- (void)_getScoopsWithParams:(NSDictionary*)params success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    
    [self getPath:@"scoops" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        for (NSDictionary * scoopDictionary in [responseObject objectForKey:@"scoops"]) {
            [IPKReview objectWithDictionary:scoopDictionary];
        }
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

//#pragma mark - Lists
//
//- (void)getListsWithSuccess:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
//	[self getPath:@"teams/1" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@", responseObject);
//		__weak NSManagedObjectContext *context = [IPKList mainContext];
//		[context performBlockAndWait:^{
//			for (NSDictionary *dictionary in responseObject) {
//				[IPKList objectWithDictionary:dictionary];
//			}
//			[context save:nil];
//		}];
//		
//		if (success) {
//			success((AFJSONRequestOperation *)operation, responseObject);
//		}
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		if (failure) {
//			failure((AFJSONRequestOperation *)operation, error);
//		}
//	}];
//}
//
//
//- (void)createList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
//	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
//							list.title, @"list[title]",
//							nil];
//	
//	__weak NSManagedObjectContext *context = [IPKList mainContext];
//	[self postPath:@"lists" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		[context performBlockAndWait:^{
//			[list unpackDictionary:responseObject];
//			[list save];
//		}];
//		
//		if (success) {
//			success((AFJSONRequestOperation *)operation, responseObject);
//		}
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		[context performBlockAndWait:^{
//			[list delete];
//		}];
//		
//		if (failure) {
//			failure((AFJSONRequestOperation *)operation, error);
//		}
//	}];
//}
//
//
//- (void)updateList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
//	NSString *path = [NSString stringWithFormat:@"lists/%@", list.remoteID];
//	id archivedAt = list.archivedAt ? list.archivedAt : @"null";
//	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
//							list.title, @"list[title]",
//							archivedAt, @"list[archived_at]",
//							nil];
//	
//	[self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		__weak NSManagedObjectContext *context = [IPKList mainContext];
//		[context performBlockAndWait:^{
//			[list unpackDictionary:responseObject];
//			[list save];
//		}];
//		
//		if (success) {
//			success((AFJSONRequestOperation *)operation, responseObject);
//		}
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		if (failure) {
//			failure((AFJSONRequestOperation *)operation, error);
//		}
//	}];
//}
//
//
//- (void)sortLists:(NSArray *)lists success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
//	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"lists/sort" parameters:nil];
//	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//	
//	// Build the array of indexs
//	NSMutableArray *components = [[NSMutableArray alloc] init];
//	for (IPKList *list in lists) {
//		[components addObject:[NSString stringWithFormat:@"list[]=%@", list.remoteID]];
//	}
//	request.HTTPBody = [[components componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
//	
//	AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
//	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//		if (success) {
//			success((AFJSONRequestOperation *)operation, responseObject);
//		}
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		if (failure) {
//			failure((AFJSONRequestOperation *)operation, error);
//		}
//	}];
//	[self enqueueHTTPRequestOperation:operation];
//}
//
//
//#pragma mark - Tasks
//
//- (void)getTasksWithList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
//	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks?all=true", list.remoteID];
//	[self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		__weak NSManagedObjectContext *context = [IPKTask mainContext];
//		[context performBlockAndWait:^{		
//			for (NSDictionary *taskDictionary in responseObject) {
//				IPKTask *task = [IPKTask objectWithDictionary:taskDictionary];
//				task.list = list;
//			}
//			[context save:nil];
//		}];
//		
//		if (success) {
//			success((AFJSONRequestOperation *)operation, responseObject);
//		}
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		if (failure) {
//			failure((AFJSONRequestOperation *)operation, error);
//		}
//	}];
//}
//
//
//- (void)createTask:(IPKTask *)task success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
//	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks", task.list.remoteID];
//	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
//							task.text, @"task[text]",
//							nil];
//	
//	__weak NSManagedObjectContext *context = [IPKTask mainContext];
//	[self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		[context performBlockAndWait:^{
//			[task unpackDictionary:responseObject];
//			[task save];
//		}];
//		
//		if (success) {
//			success((AFJSONRequestOperation *)operation, responseObject);
//		}
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		[context performBlockAndWait:^{
//			[task delete];
//		}];
//		
//		if (failure) {
//			failure((AFJSONRequestOperation *)operation, error);
//		}
//	}];
//}
//
//
//- (void)updateTask:(IPKTask *)task success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
//	NSString *path = [NSString stringWithFormat:@"tasks/%@", task.remoteID];
//	id completedAt = task.completedAt ? task.completedAt : @"null";
//	id archivedAt = task.archivedAt ? task.archivedAt : @"null";
//	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
//							task.text, @"task[text]",
//							completedAt, @"task[completed_at]",
//							archivedAt, @"task[archived_at]",
//							nil];
//	
//	[self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		__weak NSManagedObjectContext *context = [IPKTask mainContext];
//		[context performBlockAndWait:^{
//			[task unpackDictionary:responseObject];
//			[task save];
//		}];
//		
//		if (success) {
//			success((AFJSONRequestOperation *)operation, responseObject);
//		}
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		if (failure) {
//			failure((AFJSONRequestOperation *)operation, error);
//		}
//	}];
//}
//
//
//- (void)sortTasks:(NSArray *)tasks inList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
//	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks/sort", list.remoteID];
//	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:nil];
//	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//	
//	// Build the array of indexs
//	NSMutableArray *components = [[NSMutableArray alloc] init];
//	for (IPKTask *task in tasks) {
//		[components addObject:[NSString stringWithFormat:@"task[]=%@", task.remoteID]];
//	}
//	request.HTTPBody = [[components componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
//	
//	AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
//	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//		if (success) {
//			success((AFJSONRequestOperation *)operation, responseObject);
//		}
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		if (failure) {
//			failure((AFJSONRequestOperation *)operation, error);
//		}
//	}];
//	[self enqueueHTTPRequestOperation:operation];
//}
//
//
//- (void)archiveAllTasksInList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
//	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks/archive_all", list.remoteID];
//	[self postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		if (success) {
//			success((AFJSONRequestOperation *)operation, responseObject);
//		}
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		if (failure) {
//			failure((AFJSONRequestOperation *)operation, error);
//		}
//	}];
//}
//
//
//- (void)archiveCompletedTasksInList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
//	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks/archive_completed", list.remoteID];
//	[self postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		if (success) {
//			success((AFJSONRequestOperation *)operation, responseObject);
//		}
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		if (failure) {
//			failure((AFJSONRequestOperation *)operation, error);
//		}
//	}];
//}

@end
