//
//  IPKQueryModel.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/1/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSManagedObject.h"

enum IPKQueryModelFilterType {
    kIPKQueryModelFilterAll = 0,
    kIPKQueryModelFilterInsiders = 1,
    kIPKQueryModelFilterNetwork = 2
    };

@interface IPKQueryModel : SSManagedObject

@property (nonatomic, strong) NSDate* created_at;
@property (nonatomic, strong) NSDate* updated_at;
@property (nonatomic, strong) NSString* queryString;
@property (nonatomic, strong) NSString* state;
@property (nonatomic, strong) NSString* city;
@property (nonatomic, strong) NSNumber * filterType;
@property (nonatomic, strong) NSString * currentPage;
@property (nonatomic, strong) NSString * perPageNumber;

-(NSDictionary*)packToDictionary;

@end
