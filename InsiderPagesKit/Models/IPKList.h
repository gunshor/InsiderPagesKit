//
//  IPKList.h
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "IPKRemoteManagedObject.h"

@class IPKTask;

@interface IPKList : IPKRemoteManagedObject

@property (nonatomic, strong) NSDate *archivedAt;
@property (nonatomic, strong) NSNumber *position;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSSet *tasks;
@property (nonatomic, strong) NSManagedObject *user;

- (NSInteger)highestPosition;
- (NSArray *)sortedTasks;
- (NSArray *)sortedActiveTasks;
- (NSArray *)sortedCompletedActiveTasks;

- (void)archiveAllTasks;
- (void)archiveCompletedTasks;

@end


@interface IPKList (CoreDataGeneratedAccessors)
- (void)addTasksObject:(IPKTask *)value;
- (void)removeTasksObject:(IPKTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;
@end
