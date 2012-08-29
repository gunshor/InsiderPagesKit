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

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * provider_id;
@property (nonatomic, retain) NSNumber * city_id;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * address_1;
@property (nonatomic, retain) NSString * address_2;
@property (nonatomic, retain) NSString * zip_code;
@property (nonatomic, retain) NSNumber * prime;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) IPKProvider *provider;

@end
