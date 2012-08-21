//
//  IPKRemoteManagedObject.m
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "IPKRemoteManagedObject.h"

@implementation IPKRemoteManagedObject

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
    NSManagedObjectContext * context = [[self class] mainContext];
	fetchRequest.entity = [[self class] entityWithContext:context];
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
    NSManagedObjectContext * context = [[self class] mainContext];
	fetchRequest.entity = [self entityWithContext:context];
    NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
	
	// If the object is not found, return nil
	if (results.count == 0) {
		return;
	}
    for (IPKRemoteManagedObject * object in results) {
        [object delete];
    }
}

+ (void)deleteAllLocal:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure{
    
}

+ (void)sortWithObjects:(NSArray *)objects {
	[self sortWithObjects:objects success:nil failure:nil];
}


+ (void)sortWithObjects:(NSArray *)objects success:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
	// Subclasses must override this method
}

@end
