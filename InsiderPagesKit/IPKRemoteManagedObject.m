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


+ (void)sortWithObjects:(NSArray *)objects {
	[self sortWithObjects:objects success:nil failure:nil];
}


+ (void)sortWithObjects:(NSArray *)objects success:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
	// Subclasses must override this method
}

@end
