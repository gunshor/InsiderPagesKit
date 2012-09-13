//
//  IPKAddress.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/29/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKAddress.h"
#import "IPKProvider.h"
#import "NSDictionary+InsiderPagesKit.h"

@implementation IPKAddress

@dynamic remoteID;
@dynamic updatedAt;
@dynamic createdAt;
@dynamic provider_id;
@dynamic city_id;
@dynamic phone;
@dynamic address_1;
@dynamic address_2;
@dynamic zip_code;
@dynamic prime;
@dynamic lat;
@dynamic lng;
@dynamic provider;

+ (NSString *)entityName {
	return @"IPKAddress";
}

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];    
	self.provider_id = [dictionary safeObjectForKey:@"provider_id"];
    self.city_id = [dictionary safeObjectForKey:@"city_id"];
    self.phone = [dictionary safeObjectForKey:@"phone"];
    self.address_1 = [dictionary safeObjectForKey:@"address_1"];
    self.address_2 = [dictionary safeObjectForKey:@"address_2"];
    self.zip_code = [dictionary safeObjectForKey:@"zip_code"];
    self.prime = [dictionary safeObjectForKey:@"prime"];
    self.lat = [dictionary safeObjectForKey:@"lat"];
    self.lng = [dictionary safeObjectForKey:@"lng"];
    self.provider = [IPKProvider objectWithRemoteID:self.provider_id];
}

@end
