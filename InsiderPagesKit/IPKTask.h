//
//  IPKTask.h
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/1/12.
//  Inspired by Sam Soffes' CheddarKit.
//

#import "IPKRemoteManagedObject.h"

@class IPKUser;
@class IPKList;
@class IPKTag;
@class NSAttributedString;
@class NSMutableAttributedString;

@interface IPKTask : IPKRemoteManagedObject

@property (nonatomic, strong) NSDate *archivedAt;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *displayText;
@property (nonatomic, strong) NSDictionary *entities;
@property (nonatomic, strong) NSNumber *position;
@property (nonatomic, strong) NSDate *completedAt;
@property (nonatomic, strong) IPKUser *user;
@property (nonatomic, strong) IPKList *list;
@property (nonatomic, strong) NSSet *tags;

- (BOOL)isCompleted;
- (void)toggleCompleted;
- (BOOL)hasTag:(IPKTag *)tag;
- (BOOL)hasTags:(NSArray *)tags;

@end


@interface IPKTask (CoreDataGeneratedAccessors)
- (void)addTagsObject:(IPKTag *)value;
- (void)removeTagsObject:(IPKTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;
@end
