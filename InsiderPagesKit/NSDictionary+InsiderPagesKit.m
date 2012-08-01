//
//  NSDictionary+InsiderPagesKit.m
//  InsiderPagesKit
//
//  Created by Sam Soffes on 6/4/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "NSDictionary+InsiderPagesKit.h"

@implementation NSDictionary (InsiderPagesKit)


- (id)safeObjectForKey:(id)key {
	id value = [self valueForKey:key];
	if (value == [NSNull null]) {
		return nil;
	}
	return value;
}

@end
