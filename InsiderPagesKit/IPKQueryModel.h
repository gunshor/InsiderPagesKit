//
//  IPKQueryModel.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/1/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import <Foundation/Foundation.h>

enum IPKQueryModelFilterType {
    kIPKQueryModelFilterAll = 0,
    kIPKQueryModelFilterInsiders = 1,
    kIPKQueryModelFilterNetwork = 2
    };

@interface IPKQueryModel : NSObject

@property (nonatomic, strong) NSString* queryString;
@property (nonatomic, strong) NSString* state;
@property (nonatomic, strong) NSString* city;
@property (nonatomic, readwrite) enum IPKQueryModelFilterType filterType;
@property (nonatomic, strong) NSString * currentPage;
@property (nonatomic, strong) NSString * perPageNumber;

@end
