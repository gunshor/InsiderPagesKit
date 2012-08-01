//
//  IPKPushController.m
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "IPKPushController.h"
#import "IPKList.h"
#import "IPKTask.h"
#import "IPKHTTPClient.h"
#import "IPKUser.h"
#import "IPKDefines.h"
#import <Bully/Bully.h>
#import "Reachability.h"

static BOOL __developmentMode = NO;

@interface IPKPushController () <BLYClientDelegate>
@property (nonatomic, strong, readwrite) BLYClient *client;
@property (nonatomic, strong, readwrite) BLYChannel *userChannel;
@property (nonatomic, strong) NSString *userID;
- (void)_userChanged:(NSNotification *)notification;
- (void)_appDidEnterBackground:(NSNotification *)notificaiton;
- (void)_appDidBecomeActive:(NSNotification *)notification;
- (void)_reachabilityChanged:(NSNotification *)notification;
@end

@implementation IPKPushController {
	Reachability *_reachability;
}

@synthesize client = _client;
@synthesize userChannel = _userChannel;
@synthesize userID = _userID;

- (void)setUserID:(NSString *)userID {
	[self.userChannel unsubscribe];
	self.userChannel = nil;
	
	_userID = userID;
	
	if (!_userID) {
		return;
	}
	
	// Subscribe to user channel
	NSString *channelName = [NSString stringWithFormat:@"private-user-%@", _userID];
	self.userChannel = [self.client subscribeToChannelWithName:channelName authenticationBlock:^(BLYChannel *channel) {
		[[IPKHTTPClient sharedClient] postPath:@"/pusher/auth" parameters:channel.authenticationParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
			[channel subscribeWithAuthentication:responseObject];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"Failed to authorize Pusher channel: %@", error);
		}];
	}];
	
	// Bind to list create
	[self.userChannel bindToEvent:@"list-create" block:^(id message) {
		IPKList *list = [IPKList objectWithDictionary:message];
		[list.managedObjectContext save:nil];
	}];
	
	// Bind to list update
	[self.userChannel bindToEvent:@"list-update" block:^(id message) {
		IPKList *list = [IPKList objectWithDictionary:message];
		[list save];

		[[NSNotificationCenter defaultCenter] postNotificationName:kIPKListDidUpdateNotificationName object:list.remoteID];
	}];
	
	// Bind to list reorder
	[self.userChannel bindToEvent:@"list-reorder" block:^(id message) {
		for (NSDictionary *dictionary in [message objectForKey:@"lists"]) {
			IPKList *list = [IPKList existingObjectWithRemoteID:[dictionary objectForKey:@"id"]];
			list.position = [dictionary objectForKey:@"position"];
		}
		[[IPKList mainContext] save:nil];
	}];

	// Bind to task create
	[self.userChannel bindToEvent:@"task-create" block:^(id message) {
		IPKList *list = [IPKList existingObjectWithRemoteID:[message objectForKey:@"list_id"]];
		if (!list) {
			return;
		}

		IPKTask *task = [IPKTask objectWithDictionary:message];
		task.list = list;
		[task save];
	}];
	
	// Bind to task update
	[self.userChannel bindToEvent:@"task-update" block:^(id message) {
		IPKList *list = [IPKList existingObjectWithRemoteID:[message objectForKey:@"list_id"]];
		if (!list) {
			return;
		}

		IPKTask *task = [IPKTask objectWithDictionary:message];
		task.list = list;
		[task save];
	}];
	
	// Bind to task reorder
	[self.userChannel bindToEvent:@"task-reorder" block:^(id message) {
		for (NSDictionary *dictionary in [message objectForKey:@"tasks"]) {
			IPKTask *task = [IPKTask existingObjectWithRemoteID:[dictionary objectForKey:@"id"]];
			task.position = [dictionary objectForKey:@"position"];
		}
		[[IPKTask mainContext] save:nil];
	}];

	// Bind to user update
	[self.userChannel bindToEvent:@"user-update" block:^(id message) {
		IPKUser *user = [IPKUser objectWithDictionary:message];
		[user save];
	}];
}


#pragma mark - Singleton

+ (IPKPushController *)sharedController {
	static IPKPushController *sharedController = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedController = [[self alloc] init];
	});
	return sharedController;
}


+ (void)setDevelopmentModeEnabled:(BOOL)enabled {
	__developmentMode = enabled;
}


#pragma mark - NSObject

- (id)init {
	if ((self = [super init])) {
		_client = [[BLYClient alloc] initWithAppKey:(__developmentMode ? kIPKDevelopmentPusherAPIKey : kIPKPusherAPIKey) delegate:self];

		self.userID = [IPKUser currentUser].remoteID.description;

		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self selector:@selector(_userChanged:) name:kIPKCurrentUserChangedNotificationName object:nil];
		
#if TARGET_OS_IPHONE
		[notificationCenter addObserver:self selector:@selector(_appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
		[notificationCenter addObserver:self selector:@selector(_appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
#endif

		_reachability = [Reachability reachabilityWithHostname:@"ws.pusherapp.com"];
		[_reachability startNotifier];
		[notificationCenter addObserver:self selector:@selector(_reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
	}
	return self;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.client disconnect];
}


#pragma mark - Private

- (void)_userChanged:(NSNotification *)notification {
	self.userID = [IPKUser currentUser].remoteID.description;
}


- (void)_appDidEnterBackground:(NSNotification *)notificaiton {
	[self.client disconnect];
}


- (void)_appDidBecomeActive:(NSNotification *)notification {
	[self.client connect];
}


- (void)_reachabilityChanged:(NSNotification *)notification {
	if ([_reachability isReachable]) {
		[self.client connect];
	} else {
		[self.client disconnect];
	}
}


#pragma mark - BLYClientDelegate

- (void)bullyClientDidConnect:(BLYClient *)client {
	[[IPKHTTPClient sharedClient] setDefaultHeader:@"X-Pusher-Socket-ID" value:client.socketID];
}


- (void)bullyClientDidDisconnect:(BLYClient *)client {
	if ([_reachability isReachable]) {
		[client connect];
	}
}

@end
