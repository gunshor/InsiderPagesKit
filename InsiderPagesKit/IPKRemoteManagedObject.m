//
//  IPKRemoteManagedObject.m
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "IPKRemoteManagedObject.h"

@implementation IPKRemoteManagedObject

@dynamic remoteID;
@dynamic createdAt;
@dynamic updatedAt;

- (void)create {
	[self createWithSuccess:nil failure:nil];
}


- (void)createWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
	// Subclasses must override this method
}


- (void)update {
	[self updateWithSuccess:nil failure:nil];
}


- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
	// Subclasses must override this method
}

- (void)deleteLocalOnly{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
	fetchRequest.entity = [[self class] MR_entityDescriptionInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"remoteID = %@", self.remoteID];
	fetchRequest.fetchLimit = 1;
    NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
	
	// If the object is not found, return nil
	if (results.count == 0) {
		return;
	}
    for (IPKRemoteManagedObject * object in results) {
        [context deleteObject:object];
    }
}

- (void)deleteLocalOnlyWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure{
    
}

- (void)deleteRemote{
    
}

- (void)deleteRemoteWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure{
    
}

+ (void)deleteAllLocal{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
	[fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread]]];
	[fetchRequest setIncludesPendingChanges:YES];
	[fetchRequest setReturnsObjectsAsFaults:YES];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
    
	// If the object is not found, return nil
	if (results.count == 0) {
		return;
	}
    for (IPKRemoteManagedObject * object in results) {
        [object MR_deleteEntity];
    }
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
}

+ (void)deleteAllLocal:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure{
    
}

+ (void)sortWithObjects:(NSArray *)objects {
	[self sortWithObjects:objects success:nil failure:nil];
}


+ (void)sortWithObjects:(NSArray *)objects success:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
	// Subclasses must override this method
}

#pragma mark -

+ (id)objectWithRemoteID:(NSNumber *)remoteID {
	return [self objectWithRemoteID:remoteID context:nil];
}


+ (id)objectWithRemoteID:(NSNumber *)remoteID context:(NSManagedObjectContext *)context {
	// Look up the object
	IPKRemoteManagedObject *object = [self existingObjectWithRemoteID:remoteID context:context];
	
	// If the object doesn't exist, create it
	if (!object) {
		object = [self MR_createInContext:context];
		object.remoteID = remoteID;
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
	}
	
	// Return the fetched or new object
	return object;
}


+ (id)existingObjectWithRemoteID:(NSNumber *)remoteID {
	return [self existingObjectWithRemoteID:remoteID context:nil];
}


+ (id)existingObjectWithRemoteID:(NSNumber *)remoteID context:(NSManagedObjectContext *)context {
	// Default to the main context
	if (!context) {
		context = [NSManagedObjectContext MR_contextForCurrentThread];
	}
	
	// Create the fetch request for the ID
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [self MR_entityDescriptionInContext:context];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"remoteID = %@", remoteID];
    fetchRequest.includesPendingChanges = YES;
	fetchRequest.fetchLimit = 1;
	
	// Execute the fetch request
	NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
	
	// If the object is not found, return nil
	if (results.count == 0) {
		return nil;
	}
	
	// Return the object
	return [results objectAtIndex:0];
}


+ (id)objectWithDictionary:(NSDictionary *)dictionary {
	return [self objectWithDictionary:dictionary context:nil];
}


+ (id)objectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context {
	// If there isn't a dictionary, we won't find the object. Return nil.
	if (!dictionary) {
		return nil;
	}
	
	// Extract the remoteID from the dictionary
	NSNumber *remoteID = [dictionary objectForKey:@"id"];
	
	// If there isn't a remoteID, we won't find the object. Return nil.
	if (!remoteID || remoteID.integerValue == 0) {
		return nil;
	}
	
	// Default to the main context
	if (!context) {
		context = [NSManagedObjectContext MR_contextForCurrentThread];
	}
	
	// Find or create the object
	IPKRemoteManagedObject *object = [[self class] objectWithRemoteID:remoteID context:context];
	
	// Only unpack if necessary
	if ([object shouldUnpackDictionary:dictionary]) {
		[object unpackDictionary:dictionary];
	}
	// Return the new or updated object
	return object;
}


+ (id)existingObjectWithDictionary:(NSDictionary *)dictionary {
	return [self existingObjectWithDictionary:dictionary context:nil];
}


+ (id)existingObjectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context {
	// If there isn't a dictionary, we won't find the object. Return nil.
	if (!dictionary) {
		return nil;
	}
	
	// Extract the remoteID from the dictionary
	NSNumber *remoteID = [dictionary objectForKey:@"id"];
	
	// If there isn't a remoteID, we won't find the object. Return nil.
	if (!remoteID || remoteID.integerValue == 0) {
		return nil;
	}
	
	// Default to the main context
	if (!context) {
		context = [NSManagedObjectContext MR_contextForCurrentThread];
	}
	
	// Lookup the object
	IPKRemoteManagedObject *object = [[self class] existingObjectWithRemoteID:remoteID context:context];
	if (!object) {
		return nil;
	}
	
	// Only unpack if necessary
	if ([object shouldUnpackDictionary:dictionary]) {
		[object unpackDictionary:dictionary];
	}
	
	// Return the new or updated object
	return object;
}


- (void)unpackDictionary:(NSDictionary *)dictionary {
	if (!self.isRemote) {
		self.remoteID = [dictionary objectForKey:@"id"];
	}
	
	self.createdAt = [[self class] parseDate:[dictionary objectForKey:@"created_at"]];
	self.updatedAt = [[self class] parseDate:[dictionary objectForKey:@"updated_at"]];
}


- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary {
	return self.updatedAt == nil || [self.updatedAt isEqualToDate:[[self class] parseDate:[dictionary objectForKey:@"updated_at"]]] == NO;
}


- (BOOL)isRemote {
	return self.remoteID.integerValue > 0;
}


+ (NSDate *)parseDate:(id)dateStringOrDateNumber {
	// Return nil if nil is given
	if (!dateStringOrDateNumber || dateStringOrDateNumber == [NSNull null]) {
		return nil;
	}
	
	// Parse number
	if ([dateStringOrDateNumber isKindOfClass:[NSNumber class]]) {
		return [NSDate dateWithTimeIntervalSince1970:[dateStringOrDateNumber doubleValue]];
	}
	
	// Parse string
	else if ([dateStringOrDateNumber isKindOfClass:[NSString class]]) {
        // Have to remove : from time zone as specified here http://stackoverflow.com/questions/3094730/iphone-nsdateformatter-timezone-conversion
        dateStringOrDateNumber = [dateStringOrDateNumber stringByReplacingOccurrencesOfString:@":" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange([dateStringOrDateNumber length]-4, 4)];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        NSDate * date = [formatter dateFromString:dateStringOrDateNumber];
        return date;
	}
	
	NSAssert1(NO, @"[SSRemoteManagedObject] Failed to parse date: %@", dateStringOrDateNumber);	
	return nil;
}

@end
