//
//  IPKQueryModel.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/1/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKQueryModel.h"
#import "NSMutableDictionary+InsiderPagesKit.h"

@implementation IPKQueryModel

@dynamic created_at;
@dynamic updated_at;
@dynamic queryString;
@dynamic state;
@dynamic city;
@dynamic filterType;
@dynamic currentPage;
@dynamic perPageNumber;

-(NSDictionary*)packToDictionary{
    NSMutableDictionary * packedDictionary = [NSMutableDictionary dictionary];
    [packedDictionary setSafeObject:self.queryString forKey:@"query"];
    NSString * locationString = [NSString stringWithFormat:@"%@, %@", self.city, self.state];
    [packedDictionary setSafeObject:locationString forKey:@"location"];
    [packedDictionary setSafeObject:self.perPageNumber forKey:@"per_page"];
    [packedDictionary setSafeObject:self.currentPage forKey:@"page"];
    NSString * filterTypeString = nil;
    enum IPKQueryModelFilterType filterTypeEnum = [self.filterType intValue];
    switch (filterTypeEnum) {
        case kIPKQueryModelFilterAll:
            filterTypeString = @"all";
            break;
        case kIPKQueryModelFilterInsiders:
            filterTypeString = @"insiders";
            break;
        case kIPKQueryModelFilterNetwork:
            filterTypeString = @"network";
            break;
            
        default:
            filterTypeString = @"all";
            break;
    }
    [packedDictionary setSafeObject:filterTypeString forKey:@"filter"];
    return packedDictionary;
}

@end
