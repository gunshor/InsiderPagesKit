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
#import "IPKTeamFollowing.h"
#import "IPKTeamMembership.h"
#import "IPKDefines.h"

static NSString* __baseAPIHost = @"";

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


+ (void)setBaseAPIHost:(NSString *)baseAPIHost {
	__baseAPIHost = baseAPIHost;
}


+ (NSString *)apiVersion {
	return @"v1";
}


#pragma mark - NSObject

- (id)init {
	NSURL *base = nil;
	NSString *version = [[self class] apiVersion];
		base = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@/", kIPKDevelopmentAPIScheme, __baseAPIHost, version]];
	
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
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        IPKUser *user = [IPKUser objectWithDictionary:[responseObject objectForKey:@"user"] context:context];
        user.fb_access_token = fbAccessToken;
        NSHTTPCookie *cookie = [[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] objectAtIndex:0];
        user.accessToken = [cookie value];
        [context MR_save];
        [IPKUser setCurrentUser:user];

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
        IPKPage * pageToFollow = [IPKPage objectWithRemoteID:@([pageId longLongValue])];
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
        if (operation.response.statusCode != 403) {
            IPKUser * userToFollow = [IPKUser objectWithRemoteID:@([userId longLongValue])];
            [[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]] addFollowedUsersObject:userToFollow];
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

- (void)unfollowPageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID, @"follow_id",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/followers", pageId];
    [self deletePath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IPKPage * pageToFollow = [IPKPage objectWithRemoteID:@([pageId longLongValue])];
        //force fault
        [pageToFollow name];
        [[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]] removeFollowedPagesObject:pageToFollow];
        [pageToFollow setIs_following:[NSNumber numberWithBool:NO]];
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

- (void)unfollowUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userId, @"follow_id",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"users/%@/following", [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID];
    [self deletePath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IPKUser * userToUnfollow = [IPKUser objectWithRemoteID:@([userId longLongValue])];
        [[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]] removeFollowedUsersObject:userToUnfollow];
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

#pragma mark - User Resources
- (void)getPagesForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString *url = [NSString stringWithFormat:@"users/%@/teams", userId];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @100, @"per_page",
                            @1, @"page",
                            nil];
    
    [self getPath:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"teams"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary* pageDictionary in [responseObject objectForKey:@"teams"]) {
                if ([pageDictionary isKindOfClass:[NSDictionary class]]) {
                    IPKPage * page = nil;
                    page = [IPKPage objectWithDictionary:pageDictionary];
                }
            }
        }else{
            [IPKPage objectWithDictionary:[responseObject objectForKey:@"teams"]];
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

- (void)getFavoritePagesForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString *url = [NSString stringWithFormat:@"users/%@/favorite_teams", userId];
    
    [self getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        for (NSDictionary* pageDictionary in [responseObject objectForKey:@"teams"]) {
            IPKPage * page = nil;
            page = [IPKPage objectWithDictionary:pageDictionary];
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

- (void)getFollowingPagesForUserWithId:(NSString*)userId withCurrentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            perPage, @"per_page",
                            currentPage, @"page",
                            nil];
    NSString *url = [NSString stringWithFormat:@"users/%@/following_teams", userId];
    
    [self getPath:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        for (NSDictionary* pageDictionary in [responseObject objectForKey:@"teams"]) {
            IPKPage * page = nil;
            page = [IPKPage objectWithDictionary:pageDictionary];
            IPKUser * user = [IPKUser objectWithRemoteID:@([userId longLongValue])];
            [page addFollowing_usersObject:user];
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

- (void)createPage:(IPKPage *)page success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSMutableDictionary * pageDictionary = [[page packToDictionary] mutableCopy];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:pageDictionary
                            , @"team",
                            nil];
    [self postPath:@"teams" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [page unpackDictionary:[responseObject objectForKey:@"team"]];
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

- (void)deletePageWithId:(NSString *)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString * urlString = [NSString stringWithFormat:@"teams/%@", pageId];
    [self deletePath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IPKPage * page = [IPKPage existingObjectWithRemoteID:@([pageId longLongValue])];
        [page MR_deleteInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        
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
        [IPKUser objectWithDictionary:responseObject];
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

- (void)getFollowersForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString *url = [NSString stringWithFormat:@"users/%@/followers", userId];
    
    [self getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"followers"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary* userDictionary in [responseObject objectForKey:@"followers"]) {
                if ([userDictionary isKindOfClass:[NSArray class]]) {
                    for (NSDictionary* innerUserDictionary in userDictionary){
                        IPKUser * user = [IPKUser objectWithDictionary:innerUserDictionary];
                        IPKUser * requestedUser = [IPKUser objectWithRemoteID:@([userId longLongValue])];
                        [requestedUser addFollowersObject:user];
                        [user addFollowedUsersObject:requestedUser];
                    }
                } else {
                    IPKUser * user = [IPKUser objectWithDictionary:userDictionary];
                    IPKUser * requestedUser = [IPKUser objectWithRemoteID:@([userId longLongValue])];
                    [requestedUser addFollowersObject:user];
                    [user addFollowedUsersObject:requestedUser];
                }
            }
        }else{
            IPKUser * user = [IPKUser objectWithDictionary:[responseObject objectForKey:@"followers"]];
            IPKUser * requestedUser = [IPKUser objectWithRemoteID:@([userId longLongValue])];
            [requestedUser addFollowersObject:user];
            [user addFollowedUsersObject:requestedUser];
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

- (void)getFollowingForUserWithId:(NSString*)userId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString *url = [NSString stringWithFormat:@"users/%@/following", userId];
    
    [self getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"following"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary* userDictionary in [responseObject objectForKey:@"following"]) {
                IPKUser * user = nil;
                user = [IPKUser objectWithDictionary:userDictionary];
            }
        }else{
            [IPKUser objectWithDictionary:[responseObject objectForKey:@"following"]];
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

#pragma mark - Pages
- (void)getProvidersForPageWithId:(NSString*)pageId sortUser:(IPKUser*)sortUser success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString *url = [NSString stringWithFormat:@"teams/%@/providers", pageId];
    NSDictionary * params = @{};
    if (sortUser) {
        params = @{@"sort_option" : [sortUser sortOption]};
    }else{
        params = @{@"sort_option" : @"pollaverage"};
    }
    
    [self getPath:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSMutableArray * providers = [NSMutableArray array];
            NSMutableArray * providerDictionariesArray = [responseObject objectForKey:@"providers"];
            for (int i = 0; i < providerDictionariesArray.count; i++) {
                NSDictionary * providerDictionary  = [providerDictionariesArray objectAtIndex:i];
                IPKProvider * provider = [IPKProvider objectWithDictionary:providerDictionary];
                [providers addObject:provider];
                IPKPage * page = [IPKPage objectWithRemoteID:@([pageId longLongValue])];
                IPKTeamMembership * teamMembership = [IPKTeamMembership createMembershipForUserID:sortUser.remoteID teamID:page.remoteID listingID:provider.remoteID];
                [teamMembership setPosition:[NSNumber numberWithInt:i+1]];
                if (sortUser == nil) {
                    [teamMembership setPollaverage:@(YES)];
                }
            }
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
            
            if (sortUser == nil) {
                NSArray * teamMemberships = [IPKTeamMembership MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"team_id == %@ && pollaverage == 1", @([pageId longLongValue])] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
                for (IPKTeamMembership * tm  in teamMemberships) {
                    BOOL isStillValid = NO;
                    for (IPKProvider * provider in providers) {
                        if ([tm.listing.remoteID isEqualToNumber:provider.remoteID]) {
                            isStillValid = YES;
                            break;
                        }
                    }
                    if (!isStillValid) {
                        [tm MR_deleteInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
                    }
                }
            }else if (sortUser != nil){
                NSArray * teamMemberships = [IPKTeamMembership MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"team_id == %@ && owner_id == %@", @([pageId longLongValue]), sortUser.remoteID] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
                for (IPKTeamMembership * tm  in teamMemberships) {
                    BOOL isStillValid = NO;
                    for (IPKProvider * provider in providers) {
                        if ([tm.listing.remoteID isEqualToNumber:provider.remoteID]) {
                            isStillValid = YES;
                            break;
                        }
                    }
                    if (!isStillValid) {
                        [tm MR_deleteInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
                    }
                }
            }
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        });
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
        
        if ([[responseObject objectForKey:@"followers"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary* userDictionary in [responseObject objectForKey:@"followers"]) {
                IPKUser * user = nil;
                user = [IPKUser objectWithDictionary:userDictionary];
            }
        }else{
            [IPKUser objectWithDictionary:[responseObject objectForKey:@"followers"]];
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

- (void)addProvidersToPageWithId:(NSString*)pageId provider:(IPKProvider*)provider success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [provider listing_id], @"provider_id",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/providers", pageId];
    [self postPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IPKUser * currentUser = [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        IPKPage * page = [IPKPage existingObjectWithRemoteID:@([pageId longLongValue])];
        IPKProvider * providerToAdd = provider;
        IPKTeamMembership * teamMembership = [IPKTeamMembership createMembershipForUserID:currentUser.remoteID teamID:page.remoteID listingID:providerToAdd.remoteID];
        teamMembership.position = @(1);
        teamMembership.pollaverage = @(0);
        NSArray * teamMemberships = [IPKTeamMembership MR_findAllSortedBy:@"position" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"owner_id == %@ && team_id == %@ && listing_id != %@",currentUser.remoteID, @([pageId longLongValue]), provider.remoteID] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        for (int i = 0; i < teamMemberships.count; i++) {
            IPKTeamMembership * tm = [teamMemberships objectAtIndex:i];
            tm.position = @(tm.position.intValue + 1);
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

- (void)addProvidersToPageWithId:(NSString*)pageId provider:(IPKProvider*)provider scoopText:(NSString*)scoopText success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [provider listing_id], @"provider_id",
                            scoopText, @"scoop",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/providers", pageId];
    [self postPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IPKUser * currentUser = [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        IPKPage * page = [IPKPage existingObjectWithRemoteID:@([pageId longLongValue])];
        IPKTeamMembership * teamMembership = [IPKTeamMembership createMembershipForUserID:currentUser.remoteID teamID:page.remoteID listingID:provider.remoteID];
        teamMembership.position = @(1);
        teamMembership.pollaverage = @(NO);
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        NSMutableArray * teamMemberships = [[IPKTeamMembership MR_findAllSortedBy:@"position" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"owner_id == %@ && team_id == %@ && listing_id != %@",currentUser.remoteID, @([pageId longLongValue]), provider.remoteID] inContext:[NSManagedObjectContext MR_contextForCurrentThread]] mutableCopy];
        for (int i = 0; i < teamMemberships.count; i++) {
            IPKTeamMembership * tm = [teamMemberships objectAtIndex:i];
            tm.position = @(tm.position.intValue + 1);
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveNestedContexts];
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

- (void)removeProvidersFromPageWithId:(NSString*)pageId provider:(IPKProvider*)provider success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [provider listing_id], @"provider_id",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/providers", pageId];
    [self deletePath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            IPKUser * currentUser = [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            IPKPage * page = [IPKPage existingObjectWithRemoteID:@([pageId longLongValue])];
            IPKProvider * providerToRemove = provider;
            IPKTeamMembership * teamMembership = [IPKTeamMembership teamMembershipForUserID:currentUser.remoteID teamID:page.remoteID listingID:providerToRemove.remoteID];
            NSArray * teamMemberships = [IPKTeamMembership MR_findByAttribute:@"owner_id" withValue:currentUser.remoteID inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            for (int i = 0; i < teamMemberships.count; i++) {
                IPKTeamMembership * tm = [teamMemberships objectAtIndex:i];
                if (tm.position.intValue > teamMembership.position.intValue) {
                    
                    ((IPKTeamMembership*)[tm MR_inThreadContext]).position = @(tm.position.intValue - 1);
                    [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
                }
            }
            [teamMembership MR_deleteInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveNestedContexts];
        });
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)createCollaboratorRankingForPageWithId:(NSString*)pageId userId:(NSString*)userId newOrder:(NSArray*)newOrder success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    IPKPage * page = [IPKPage existingObjectWithRemoteID:@([pageId longLongValue])];
    NSMutableArray * stringOrderArray = [NSMutableArray array];
    for (NSNumber * num in newOrder) {
        [stringOrderArray addObject:[@(num.intValue - 1) stringValue]];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner_id == %@ && team_id == %@", @([userId longLongValue]), @([pageId longLongValue])];
    NSArray *membershipArray = [IPKTeamMembership MR_findAllSortedBy:@"position" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    if (membershipArray.count == 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pollaverage == 1 && team_id == %@", @([pageId longLongValue])];
        membershipArray = [IPKTeamMembership MR_findAllSortedBy:@"position" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    }
    
    NSMutableArray * currentListings = [NSMutableArray array];
    
    for (IPKTeamMembership * teamMembership in membershipArray) {
        IPKProvider * provider = teamMembership.listing;
        [currentListings addObject:[provider listing_id]];
    }
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            stringOrderArray, @"new_listings",
                            [currentListings componentsJoinedByString:@","], @"listings",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/reorder_providers", pageId];
    [self postPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner_id == %@ && team_id == %@", @([userId longLongValue]), @([pageId longLongValue])];
        NSArray *membershipArray = [IPKTeamMembership MR_findAllSortedBy:@"position" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        if (membershipArray.count == 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pollaverage == 1 && team_id == %@", @([pageId longLongValue])];
            membershipArray = [IPKTeamMembership MR_findAllSortedBy:@"position" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        for (int i = 0; i < membershipArray.count; i++) {
            for (NSString * listingString in currentListings) {
                IPKTeamMembership * teamMembership = [membershipArray objectAtIndex:i];
                if ([listingString isEqualToString:[[teamMembership listing ] listing_id]]) {
                    teamMembership.position = [newOrder objectAtIndex:i];
                }
            }
        }
        page.is_collaborator = @(YES);
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveNestedContexts];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)reorderProvidersForPageWithId:(NSString*)pageId newOrder:(NSArray*)newOrder success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSMutableArray * stringOrderArray = [NSMutableArray array];
    for (NSNumber * num in newOrder) {
        [stringOrderArray addObject:[@(num.intValue - 1) stringValue]];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner_id == %@ && team_id == %@", [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID, @([pageId longLongValue])];
    NSArray *membershipArray = [IPKTeamMembership MR_findAllSortedBy:@"position" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    NSMutableArray * currentListings = [NSMutableArray array];
    
    for (IPKTeamMembership * teamMembership in membershipArray) {
        IPKProvider * provider = teamMembership.listing;
        [currentListings addObject:[provider listing_id]];
    }
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            stringOrderArray, @"new_listings",
                            [currentListings componentsJoinedByString:@","], @"listings",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/reorder_providers", pageId];
    [self postPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner_id == %@ && team_id == %@", [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID, @([pageId longLongValue])];
        NSArray *membershipArray = [IPKTeamMembership MR_findAllSortedBy:@"position" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        for (int i = 0; i < membershipArray.count; i++) {
            for (NSString * listingString in currentListings) {
                IPKTeamMembership * teamMembership = [membershipArray objectAtIndex:i];
                if ([listingString isEqualToString:[[teamMembership listing ] listing_id]]) {
                    teamMembership.position = [newOrder objectAtIndex:i];
                }
            }
        }
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveNestedContexts];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

- (void)getCollaboratorsForPageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/collaborators", pageId];
    [self getPath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"collaborators"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary* userDictionary in [responseObject objectForKey:@"collaborators"]) {
                IPKUser * user = [IPKUser objectWithDictionary:userDictionary];
                IPKTeamFollowing * teamFollowing = [IPKTeamFollowing createFollowingForUserID:user.remoteID andTeamID:@([pageId longLongValue]) privilege:@(1)];
                IPKPage * page = [IPKPage objectWithRemoteID:@([pageId longLongValue])];
                [page addFollowing_usersObject:user];
            }
        }else if ([[responseObject objectForKey:@"collaborators"] isKindOfClass:[NSDictionary class]]) {
            IPKUser * user = [IPKUser objectWithDictionary:[responseObject objectForKey:@"collaborators"]];
            IPKTeamFollowing * teamFollowing = [IPKTeamFollowing createFollowingForUserID:user.remoteID andTeamID:@([pageId longLongValue]) privilege:@(1)];
            IPKPage * page = [IPKPage objectWithRemoteID:@([pageId longLongValue])];
            [page addFollowing_usersObject:user];
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

- (void)addCollaboratorsToPageWithId:(NSString*)pageId userID:(NSString*)userID success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userID, @"collaborator_id",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/collaborators", pageId];
    [self postPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //only invite do not accept and create team following
        //        IPKPage * page = [IPKPage existingObjectWithRemoteID:@([pageId longLongValue])];
        //        IPKTeamFollowing * teamFollowing = [IPKTeamFollowing createFollowingForUserID:[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID andTeamID:@([pageId longLongValue]) privilege:@(1)];
        //        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        
        if (success) {
            success((AFJSONRequestOperation *)operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
    
}

- (void)removeCollaboratorsFromPageWithId:(NSString*)pageId userID:(NSString*)userID success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userID, @"collaborator_id",
                            nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/collaborators", pageId];
    [self deletePath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IPKTeamFollowing * teamFollowing = [IPKTeamFollowing teamFollowingForUserID:[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID andTeamID:@([pageId longLongValue])];
        [teamFollowing MR_deleteInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        
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

- (void)favoritePageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure  {  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:pageId, @"id", nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/favorite", pageId];
    [self postPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IPKPage * page = [IPKPage existingObjectWithRemoteID:@([pageId longLongValue])];
        [page setIs_favorite:[NSNumber numberWithBool:YES]];
        [page updateSectionHeader];
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


- (void)unfavoritePageWithId:(NSString*)pageId success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:pageId, @"id",nil];
    NSString * urlString = [NSString stringWithFormat:@"teams/%@/unfavorite", pageId];
    [self postPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        IPKPage * page = [IPKPage existingObjectWithRemoteID:@([pageId longLongValue])];
        [page setIs_favorite:[NSNumber numberWithBool:NO]];
        [page updateSectionHeader];
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


#pragma mark - Providers
- (void)getPagesForProviderWithId:(NSString*)providerId withCurrentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSString * urlString = [NSString stringWithFormat:@"providers/%@/pages", providerId];
    NSString * provider_type = ((IPKProvider*)[IPKProvider objectWithRemoteID:@([providerId longLongValue])]).listing_type;
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:provider_type, @"provider_type", nil];
    [self getPath:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"pages"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary * pageDictionary in [responseObject objectForKey:@"pages"]) {
                IPKPage * page = [IPKPage objectWithDictionary:pageDictionary];
                [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
                IPKProvider * provider = [IPKProvider objectWithRemoteID:@([providerId longLongValue])];
                [page addProvidersObject:provider];
            }
        }else{
            IPKPage * page = [IPKPage objectWithDictionary:[responseObject objectForKey:@"pages"]];
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
            IPKProvider * provider = [IPKProvider objectWithRemoteID:@([providerId longLongValue])];
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
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        for (NSDictionary * providerDictionary in [responseObject objectForKey:@"results"]) {
            [IPKProvider objectWithDictionary:providerDictionary];
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

- (void)insiderSearchWithQueryModel:(IPKQueryModel*)queryModel success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    [self postPath:@"insider_search" parameters:[queryModel packToDictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        for (NSDictionary * insiderDictionary in [responseObject objectForKey:@"results"]) {
            [IPKUser objectWithDictionary:insiderDictionary];
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

- (void)pageSearchWithQueryModel:(IPKQueryModel*)queryModel success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    [self postPath:@"page_search" parameters:[queryModel packToDictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        if ([[responseObject objectForKey:@"results"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary * pageDictionary in [responseObject objectForKey:@"results"]) {
                [IPKPage objectWithDictionary:pageDictionary];
            }
        }else{
            [IPKPage objectWithDictionary:[responseObject objectForKey:@"results"]];
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


#pragma mark - Activities
- (void)getActivititesOfType:(enum IPKTrackableType)type includeFollowing:(BOOL)shouldIncludeFollowing currentPage:(NSNumber*)currentPage perPage:(NSNumber*)perPage success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @(type), @"type",
                            @(shouldIncludeFollowing), @"following",
                            perPage, @"per_page",
                            currentPage, @"page",
                            nil];
    
    [self getPath:@"activities" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        for (NSDictionary* activityDictionary in [responseObject objectForKey:@"activities"]) {
            [IPKActivity objectWithDictionary:activityDictionary context:[NSManagedObjectContext MR_contextForCurrentThread]];
        }
        [context MR_save];
        
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
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            perPage, @"per_page",
                            currentPage, @"page",
                            nil];
    
    [self getPath:@"activities/pages" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        for (NSDictionary* activityDictionary in [responseObject objectForKey:@"activities"]) {
            [IPKActivity objectWithDictionary:activityDictionary];
        }
        [context MR_save];
        
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

        if ([[responseObject objectForKey:@"notifications"] isKindOfClass:[NSArray class]]) {
            IPKUser * currentUser = [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            for (NSDictionary* notificationDictionary in [responseObject objectForKey:@"notifications"]) {
                IPKNotification * n = [IPKNotification objectWithDictionary:notificationDictionary];
                if (![currentUser.notifications containsObject:n]) {
                    [currentUser addNotificationsObject:n];
                }
            }
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

- (void)markNotificationsReadWithSuccess:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{

    [self getPath:@"mark_notifications_read" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"success"]) {
            IPKUser * currentUser = [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
            NSArray * unreadNotificationsArray = [[currentUser.notifications filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"read == NO"]] allObjects];
            for (IPKNotification * n  in unreadNotificationsArray) {
                n.read = @(YES);
            }
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

- (void)registerForNotificationsWithToken:(NSString*)token uuid:(NSString*)uuidString success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            token, @"apn_token",
                            uuidString, @"uuid",
                            nil];
    [self postPath:@"register_notifications" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
