//
//  IPKTTPClient.m
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "IPKHTTPClient.h"
#import "IPKList.h"
#import "IPKTask.h"
#import "IPKUser.h"
#import "IPKDefines.h"
#import <Bully/Bully.h>

static BOOL __developmentMode = NO;

@interface IPKHTTPClient ()
- (void)_userChanged:(NSNotification *)notification;
@end

@implementation IPKHTTPClient {
	dispatch_queue_t _callbackQueue;
	NSString *_clientID;
	NSString *_clientSecret;
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
		
		if ([IPKUser currentUser]) {
			[self changeUser:[IPKUser currentUser]];
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userChanged:) name:kIPKCurrentUserChangedNotificationName object:nil];
		_callbackQueue = dispatch_queue_create("com.nothingmagical.cheddar.network-callback-queue", 0);
	}
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


#pragma mark - Client

- (void)setClientID:(NSString *)clientID secret:(NSString *)clientSecret {
	_clientID = clientID;
	_clientSecret = clientSecret;
}


#pragma mark - User

- (void)signInWithLogin:(NSString *)login password:(NSString *)password success:(void (^)(AFJSONRequestOperation *operation, id responseObject))success failure:(void (^)(AFJSONRequestOperation *operation, NSError *error))failure {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							login, @"username",
							password, @"password",
							@"password", @"grant_type",
							nil];
	
	[self setAuthorizationHeaderWithUsername:_clientID password:_clientSecret];
	[self postPath:@"/oauth/token" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [IPKUser mainContext];
		[context performBlockAndWait:^{
			NSDictionary *dictionary = (NSDictionary *)responseObject;
			IPKUser *user = [IPKUser objectWithDictionary:[dictionary objectForKey:@"user"]];
			user.accessToken = [dictionary objectForKey:@"access_token"];
			[user save];
			
			[self changeUser:user];
			[IPKUser setCurrentUser:user];
		}];

		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
	[self clearAuthorizationHeader];
}


- (void)signInWithAuthorizationCode:(NSString *)code success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							code, @"code",
							@"authorization_code", @"grant_type",
							nil];
	
	[self setAuthorizationHeaderWithUsername:_clientID password:_clientSecret];
	[self postPath:@"/oauth/token" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [IPKUser mainContext];
		[context performBlockAndWait:^{
			NSDictionary *dictionary = (NSDictionary *)responseObject;
			IPKUser *user = [IPKUser objectWithDictionary:[dictionary objectForKey:@"user"]];
			user.accessToken = [dictionary objectForKey:@"access_token"];
			[user save];
			
			[self changeUser:user];
			[IPKUser setCurrentUser:user];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
	[self clearAuthorizationHeader];
}


- (void)signUpWithUsername:(NSString *)username email:(NSString *)email password:(NSString *)password success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							username, @"user[username]",
							email, @"user[email]",
							password, @"user[password]",
							nil];
	
	[self setAuthorizationHeaderWithUsername:_clientID password:_clientSecret];
	[self postPath:@"users" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [IPKUser mainContext];
		[context performBlockAndWait:^{
			NSDictionary *dictionary = (NSDictionary *)responseObject;
			IPKUser *user = [IPKUser objectWithDictionary:dictionary];
			user.accessToken = [[dictionary objectForKey:@"access_token"] objectForKey:@"access_token"];
			[self changeUser:user];
			[IPKUser setCurrentUser:user];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
	[self clearAuthorizationHeader];
}


- (void)updateCurrentUserWithSuccess:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
	[self getPath:@"me" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [IPKUser mainContext];
		[context performBlockAndWait:^{
			IPKUser *currentUser = [IPKUser currentUser];
			[currentUser unpackDictionary:responseObject];
			[currentUser save];
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


#pragma mark - Lists

- (void)getListsWithSuccess:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
	[self getPath:@"lists" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [IPKList mainContext];
		[context performBlockAndWait:^{
			for (NSDictionary *dictionary in responseObject) {
				[IPKList objectWithDictionary:dictionary];
			}
			[context save:nil];
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


- (void)createList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							list.title, @"list[title]",
							nil];
	
	__weak NSManagedObjectContext *context = [IPKList mainContext];
	[self postPath:@"lists" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		[context performBlockAndWait:^{
			[list unpackDictionary:responseObject];
			[list save];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[context performBlockAndWait:^{
			[list delete];
		}];
		
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}


- (void)updateList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
	NSString *path = [NSString stringWithFormat:@"lists/%@", list.remoteID];
	id archivedAt = list.archivedAt ? list.archivedAt : @"null";
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							list.title, @"list[title]",
							archivedAt, @"list[archived_at]",
							nil];
	
	[self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [IPKList mainContext];
		[context performBlockAndWait:^{
			[list unpackDictionary:responseObject];
			[list save];
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


- (void)sortLists:(NSArray *)lists success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"lists/sort" parameters:nil];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	// Build the array of indexs
	NSMutableArray *components = [[NSMutableArray alloc] init];
	for (IPKList *list in lists) {
		[components addObject:[NSString stringWithFormat:@"list[]=%@", list.remoteID]];
	}
	request.HTTPBody = [[components componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
	
	AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
	[self enqueueHTTPRequestOperation:operation];
}


#pragma mark - Tasks

- (void)getTasksWithList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks?all=true", list.remoteID];
	[self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [IPKTask mainContext];
		[context performBlockAndWait:^{		
			for (NSDictionary *taskDictionary in responseObject) {
				IPKTask *task = [IPKTask objectWithDictionary:taskDictionary];
				task.list = list;
			}
			[context save:nil];
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


- (void)createTask:(IPKTask *)task success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks", task.list.remoteID];
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							task.text, @"task[text]",
							nil];
	
	__weak NSManagedObjectContext *context = [IPKTask mainContext];
	[self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		[context performBlockAndWait:^{
			[task unpackDictionary:responseObject];
			[task save];
		}];
		
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[context performBlockAndWait:^{
			[task delete];
		}];
		
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}


- (void)updateTask:(IPKTask *)task success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
	NSString *path = [NSString stringWithFormat:@"tasks/%@", task.remoteID];
	id completedAt = task.completedAt ? task.completedAt : @"null";
	id archivedAt = task.archivedAt ? task.archivedAt : @"null";
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							task.text, @"task[text]",
							completedAt, @"task[completed_at]",
							archivedAt, @"task[archived_at]",
							nil];
	
	[self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__weak NSManagedObjectContext *context = [IPKTask mainContext];
		[context performBlockAndWait:^{
			[task unpackDictionary:responseObject];
			[task save];
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


- (void)sortTasks:(NSArray *)tasks inList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks/sort", list.remoteID];
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:nil];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	// Build the array of indexs
	NSMutableArray *components = [[NSMutableArray alloc] init];
	for (IPKTask *task in tasks) {
		[components addObject:[NSString stringWithFormat:@"task[]=%@", task.remoteID]];
	}
	request.HTTPBody = [[components componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
	
	AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
	[self enqueueHTTPRequestOperation:operation];
}


- (void)archiveAllTasksInList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks/archive_all", list.remoteID];
	[self postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}


- (void)archiveCompletedTasksInList:(IPKList *)list success:(IPKHTTPClientSuccess)success failure:(IPKHTTPClientFailure)failure {
	NSString *path = [NSString stringWithFormat:@"lists/%@/tasks/archive_completed", list.remoteID];
	[self postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if (success) {
			success((AFJSONRequestOperation *)operation, responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure((AFJSONRequestOperation *)operation, error);
		}
	}];
}


#pragma mark - Authentication

- (void)_userChanged:(NSNotification *)notification {
	[self changeUser:[IPKUser currentUser]];
}


- (void)changeUser:(IPKUser *)user {
	if (user.accessToken) {
		[self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", user.accessToken]];
		return;
	}
	
	[self clearAuthorizationHeader];
}

@end
