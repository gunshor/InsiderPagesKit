//
//  IPKQueryModel.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/1/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPKRemoteManagedObject.h"

enum IPKQueryModelFilterType {
    kIPKQueryModelFilterAll = 0,
    kIPKQueryModelFilterInsiders = 1,
    kIPKQueryModelFilterNetwork = 2
    };

@interface IPKQueryModel : IPKRemoteManagedObject

@property (nonatomic, strong) NSString* queryString;
@property (nonatomic, strong) NSString* state;
@property (nonatomic, strong) NSString* city;
@property (nonatomic, strong) NSNumber * filterType;
@property (nonatomic, strong) NSString * currentPage;
@property (nonatomic, strong) NSString * perPageNumber;

-(NSDictionary*)packToDictionary;

@end
