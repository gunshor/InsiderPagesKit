//
//  Notification.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKNotification.h"
#import "IPKUser.h"


@implementation IPKNotification

@dynamic action_text;
@dynamic activity_parent;
@dynamic created_at;
@dynamic id;
@dynamic path;
@dynamic read;
@dynamic updated_at;
@dynamic user_id;
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
//	[super unpackDictionary:dictionary];
//	self.archivedAt = [[self class] parseDate:[dictionary objectForKey:@"archived_at"]];
//	self.position = [dictionary objectForKey:@"position"];
//	self.title = [dictionary objectForKey:@"title"];
//	self.slug = [dictionary objectForKey:@"slug"];
//    
//	if ([dictionary objectForKey:@"user"]) {
//		self.user = [IPKUser objectWithDictionary:[dictionary objectForKey:@"user"] context:self.managedObjectContext];
//	}
//	
//	for (NSDictionary *taskDictionary in [dictionary objectForKey:@"tasks"]) {
//		IPKTask *task = [IPKTask objectWithDictionary:taskDictionary context:self.managedObjectContext];
//		task.list = self;
//	}
}


- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary {
	return YES;
}

@end
