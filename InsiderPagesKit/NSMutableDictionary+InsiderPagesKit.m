//
//  NSMutableDictionary+InsiderPagesKit.m
//  InsiderPagesKit
//
//  Created by Christopher Truman on 8/6/12.
//

#import "NSMutableDictionary+InsiderPagesKit.h"

@implementation NSMutableDictionary (InsiderPagesKit)

- (void)setSafeObject:(id)object forKey:(id)key {
	if (object == [NSNull null] || object == nil) {
		return;
	}
    else{
        [self setObject:object forKey:key];
    }
}
@end
