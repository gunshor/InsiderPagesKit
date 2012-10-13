//
//  IPKAddress.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/29/12.
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
@dynamic city;
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

-(void)unpackCityGridDictionary:(NSDictionary*)cityGridDictionary{
    [super unpackDictionary:cityGridDictionary];
    self.city = [cityGridDictionary safeObjectForKey:@"city"];
    self.phone = [cityGridDictionary safeObjectForKey:@"phone"];
    self.address_1 = [cityGridDictionary safeObjectForKey:@"street"];
    self.address_2 = [cityGridDictionary safeObjectForKey:@"address_2"];
    self.zip_code = [cityGridDictionary safeObjectForKey:@"postal_code"];
    self.lat = [cityGridDictionary safeObjectForKey:@"latitude"];
    self.lng = [cityGridDictionary safeObjectForKey:@"longitude"];
}

- (void)unpackProviderDictionary:(NSDictionary *)providerDictionary {
	[super unpackDictionary:providerDictionary];    
	self.provider_id = [providerDictionary safeObjectForKey:@"provider_id"];
    self.city_id = [providerDictionary safeObjectForKey:@"city_id"];
    self.phone = [providerDictionary safeObjectForKey:@"phone"];
    self.address_1 = [providerDictionary safeObjectForKey:@"address_1"];
    self.address_2 = [providerDictionary safeObjectForKey:@"address_2"];
    self.zip_code = [providerDictionary safeObjectForKey:@"zip_code"];
    self.prime = [providerDictionary safeObjectForKey:@"prime"];
    self.lat = [providerDictionary safeObjectForKey:@"lat"];
    self.lng = [providerDictionary safeObjectForKey:@"lng"];
    self.provider = [IPKProvider objectWithRemoteID:self.provider_id];
}

@end
