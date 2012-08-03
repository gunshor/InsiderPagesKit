//
//  IPKTag.h
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "SSDataKit.h"

@class IPKTask;

@interface IPKTag : SSRemoteManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSSet *tasks;

+ (IPKTag *)existingTagWithName:(NSString *)name;
+ (IPKTag *)existingTagWithName:(NSString *)name context:(NSManagedObjectContext *)context;

@end


@interface IPKTag (CoreDataGeneratedAccessors)
- (void)addTasksObject:(IPKTask *)value;
- (void)removeTasksObject:(IPKTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;
@end
