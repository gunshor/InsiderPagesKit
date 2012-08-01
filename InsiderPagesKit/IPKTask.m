//
//  IPKTask.m
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "IPKTask.h"
#import "IPKUser.h"
#import "IPKList.h"
#import "IPKTag.h"
#import "IPKHTTPClient.h"
#import "NSString+InsiderPagesKit.h"

@implementation IPKTask

@dynamic archivedAt;
@dynamic text;
@dynamic displayText;
@synthesize entities;
@dynamic position;
@dynamic completedAt;
@dynamic user;
@dynamic list;
@dynamic tags;

#pragma mark - SSManagedObject

+ (NSString *)entityName {
	return @"Task";
}


+ (NSArray *)defaultSortDescriptors {
	return [NSArray arrayWithObjects:
			[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES],
			[NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES],
			nil];
}


#pragma mark - SSRemoteManagedObject

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];
	self.archivedAt = [[self class] parseDate:[dictionary objectForKey:@"archived_at"]];
	self.completedAt = [[self class] parseDate:[dictionary objectForKey:@"completed_at"]];
	self.position = [dictionary objectForKey:@"position"];
	self.text = [dictionary objectForKey:@"text"];
	self.displayText = [dictionary objectForKey:@"display_text"];
	self.entities = [dictionary objectForKey:@"entities"];

	if ([dictionary objectForKey:@"user"]) {
		self.user = [IPKUser objectWithDictionary:[dictionary objectForKey:@"user"] context:self.managedObjectContext];
	}
	
	NSNumber *listID = [dictionary objectForKey:@"list_id"];
	if (listID) {
		self.list = [IPKList objectWithRemoteID:listID context:self.managedObjectContext];
	}

	// Add tags
	NSMutableSet *tags = [[NSMutableSet alloc] init];
	for (NSDictionary *tagDictionary in [dictionary objectForKey:@"tags"]) {
		IPKTag *tag = [IPKTag objectWithDictionary:tagDictionary];
		[tags addObject:tag];
	}
	self.tags = tags;
}


- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary {
	return YES;
}


#pragma mark - IPKRemoteManagedObject

- (void)createWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *operation, NSError *error))failure {
	[[IPKHTTPClient sharedClient] createTask:self success:^(AFJSONRequestOperation *operation, id responseObject) {
		if (success) {
			success();
		}
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		if (failure) {
			failure(operation, error);
		}
	}];
}


- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *operation, NSError *error))failure {
	[[IPKHTTPClient sharedClient] updateTask:self success:^(AFJSONRequestOperation *operation, id responseObject) {
		if (success) {
			success();
		}
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		if (failure) {
			failure(operation, error);
		}
	}];
}


+ (void)sortWithObjects:(NSArray *)objects success:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *operation, NSError *error))failure {
	IPKList *list = [(IPKTask *)[objects objectAtIndex:0] list];
	[[IPKHTTPClient sharedClient] sortTasks:objects inList:list success:^(AFJSONRequestOperation *operation, id responseObject) {
		if (success) {
			success();
		}
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		if (failure) {
			failure(operation, error);
		}
	}];
}


#pragma mark - Task


- (BOOL)isCompleted {
	return self.completedAt != nil;
}


- (void)toggleCompleted {
	if (self.isCompleted) {
		self.completedAt = nil;
	} else {
		self.completedAt = [NSDate date];
	}
	[self save];
	[self update];
}


- (BOOL)hasTag:(IPKTag *)tag {
	// There has to be a better way to write this
	NSArray *names = [self.tags valueForKey:@"name"];
	NSString *tagName = [tag.name lowercaseString];
	for (NSString *name in names) {
		if ([[name lowercaseString] isEqualToString:tagName]) {
			return YES;
		}
	}
	return NO;
}


- (BOOL)hasTags:(NSArray *)tags {
	// There has to be a better way to write this
	for (IPKTag *tag in tags) {
		if (![self hasTag:tag]) {
			return NO;
		}
	}
	return YES;
}

@end
