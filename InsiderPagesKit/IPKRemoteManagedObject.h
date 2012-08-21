//
//  IPKRemoteManagedObject.h
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "SSDataKit.h"

@class AFJSONRequestOperation;

@interface IPKRemoteManagedObject : SSRemoteManagedObject

- (void)create;
- (void)createWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure;

- (void)update;
- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure;

- (void)deleteLocalOnly;
- (void)deleteLocalOnlyWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure;

- (void)deleteRemote;
- (void)deleteRemoteWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure;

+ (void)deleteAllLocal;
+ (void)deleteAllLocal:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure;

+ (void)sortWithObjects:(NSArray *)objects;
+ (void)sortWithObjects:(NSArray *)objects success:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure;

@end
