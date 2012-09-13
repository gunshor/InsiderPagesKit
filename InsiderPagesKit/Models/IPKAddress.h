//
//  IPKAddress.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/29/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKAbstractModel.h"

@class IPKProvider;

@interface IPKAddress : IPKAbstractModel

@property (nonatomic, strong) NSNumber * remoteID;
@property (nonatomic, strong) NSDate * updatedAt;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSNumber * provider_id;
@property (nonatomic, strong) NSNumber * city_id;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * address_1;
@property (nonatomic, strong) NSString * address_2;
@property (nonatomic, strong) NSString * zip_code;
@property (nonatomic, strong) NSNumber * prime;
@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * lng;
@property (nonatomic, strong) IPKProvider *provider;

@end
