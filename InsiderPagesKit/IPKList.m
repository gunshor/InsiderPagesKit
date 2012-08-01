//
//  IPKList.m
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "IPKList.h"
#import "IPKTask.h"
#import "IPKUser.h"
#import "IPKHTTPClient.h"

@implementation IPKList

@dynamic archivedAt;
@dynamic position;
@dynamic title;
@dynamic slug;
@dynamic tasks;
@dynamic user;

#pragma mark - SSManagedObject

+ (NSString *)entityName {
	return @"List";
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
	self.position = [dictionary objectForKey:@"position"];
	self.title = [dictionary objectForKey:@"title"];
	self.slug = [dictionary objectForKey:@"slug"];

	if ([dictionary objectForKey:@"user"]) {
		self.user = [IPKUser objectWithDictionary:[dictionary objectForKey:@"user"] context:self.managedObjectContext];
	}
	
	for (NSDictionary *taskDictionary in [dictionary objectForKey:@"tasks"]) {
		IPKTask *task = [IPKTask objectWithDictionary:taskDictionary context:self.managedObjectContext];
		task.list = self;
	}
}


- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary {
	return YES;
}


#pragma mark - IPKRemoteManagedObject

- (void)createWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
	[[IPKHTTPClient sharedClient] createList:self success:^(AFJSONRequestOperation *operation, id responseObject) {
		if (success) {
			success();
		}
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		if (failure) {
			failure(operation, error);
		}
	}];
}


- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
	[[IPKHTTPClient sharedClient] updateList:self success:^(AFJSONRequestOperation *operation, id responseObject) {
		if (success) {
			success();
		}
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		if (failure) {
			failure(operation, error);
		}
	}];
}


+ (void)sortWithObjects:(NSArray *)objects success:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
	[[IPKHTTPClient sharedClient] sortLists:objects success:^(AFJSONRequestOperation *operation, id responseObject) {
		if (success) {
			success();
		}
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		if (failure) {
			failure(operation, error);
		}
	}];
}


#pragma mark - Sorting

- (NSInteger)highestPosition {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [IPKTask entityWithContext:self.managedObjectContext];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"list = %@", self];
	fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:NO]];
	fetchRequest.fetchLimit = 1;
	NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
	if (results.count == 0) {
		return 0;
	}
	return [[(IPKList *)[results objectAtIndex:0] position] integerValue];
}


- (NSArray *)sortedTasks {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [IPKTask entityWithContext:self.managedObjectContext];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"list = %@", self];
	fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
	return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}


- (NSArray *)sortedActiveTasks {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [IPKTask entityWithContext:self.managedObjectContext];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"list = %@ AND archivedAt = nil", self];
	fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
	return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}


- (NSArray *)sortedCompletedActiveTasks {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [IPKTask entityWithContext:self.managedObjectContext];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"list = %@ AND archivedAt = nil AND completedAt != nil", self];
	fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
	return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}


- (void)archiveAllTasks {
	NSArray *tasks = self.sortedActiveTasks;
	if (tasks.count == 0) {
		return;
	}
	
	for (IPKTask *task in tasks) {
		task.archivedAt = [NSDate date];
	}
	[self.managedObjectContext save:nil];
	
	[[IPKHTTPClient sharedClient] archiveAllTasksInList:self success:nil failure:nil];
}


- (void)archiveCompletedTasks {
	NSArray *tasks = self.sortedCompletedActiveTasks;
	if (tasks.count == 0) {
		return;
	}
	
	for (IPKTask *task in tasks) {
		task.archivedAt = [NSDate date];
	}
	[self.managedObjectContext save:nil];
	
	[[IPKHTTPClient sharedClient] archiveCompletedTasksInList:self success:nil failure:nil];
}

@end
