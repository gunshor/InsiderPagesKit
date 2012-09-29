//
//  Provider.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKProvider.h"
#import "IPKAddress.h"
#import "NSMutableDictionary+InsiderPagesKit.h"
#import "NSDictionary+InsiderPagesKit.h"

@implementation IPKProvider

@dynamic attribution_url;
@dynamic business_name;
@dynamic cg_listing_id;
@dynamic created_by_id;
@dynamic createdAt;
@dynamic description_text;
@dynamic email_address;
@dynamic first_name;
@dynamic last_name;
@dynamic last_updated_by_id;
@dynamic remoteID;
@dynamic state;
@dynamic updated_from_ip_at;
@dynamic updatedAt;
@dynamic url;
@dynamic user_id;
@dynamic cached_slug;
@dynamic listing_type;
@dynamic pages;
@dynamic activities;
@dynamic reviews;
@dynamic address;

-(NSDictionary*)packToDictionary{
    NSMutableDictionary * packedDictionary = [NSMutableDictionary dictionary];
    [packedDictionary setSafeObject:self.attribution_url forKey:@"attribution_url"];
    [packedDictionary setSafeObject:self.business_name forKey:@"business_name"];
    [packedDictionary setSafeObject:self.cg_listing_id forKey:@"cg_listing_id"];
    [packedDictionary setSafeObject:self.created_by_id forKey:@"created_by_id"];
    [packedDictionary setSafeObject:self.description_text forKey:@"description"];
    [packedDictionary setSafeObject:self.email_address forKey:@"email_address"];
    [packedDictionary setSafeObject:self.first_name forKey:@"first_name"];
    [packedDictionary setSafeObject:self.last_name forKey:@"last_name"];
    [packedDictionary setSafeObject:self.last_updated_by_id forKey:@"last_updated_by_id"];
    [packedDictionary setSafeObject:self.state forKey:@"state"];
    [packedDictionary setSafeObject:self.url forKey:@"url"];
    [packedDictionary setSafeObject:self.updated_from_ip_at forKey:@"updated_from_ip_at"];
    return packedDictionary;
}

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];    
	self.attribution_url = [dictionary safeObjectForKey:@"attribution_url"];
    self.business_name = [dictionary safeObjectForKey:@"business_name"];
    self.cg_listing_id = [dictionary safeObjectForKey:@"cg_listing_id"];
    self.created_by_id = [dictionary safeObjectForKey:@"created_by_id"];
    self.description_text = [dictionary safeObjectForKey:@"description"];
    self.email_address = [dictionary safeObjectForKey:@"email_address"];
    self.first_name = [dictionary safeObjectForKey:@"first_name"];
    self.last_name = [dictionary safeObjectForKey:@"last_name"];
    self.last_updated_by_id = [dictionary safeObjectForKey:@"last_updated_by_id"];
    self.state = [dictionary safeObjectForKey:@"state"];
    self.url = [dictionary safeObjectForKey:@"url"];
    self.user_id = [dictionary safeObjectForKey:@"user_id"];
    self.updated_from_ip_at = [dictionary safeObjectForKey:@"updated_from_ip_at"];
    self.listing_type = [dictionary safeObjectForKey:@"listing_type"];
    if ([self.listing_type isEqualToString:@"CgListing"]) {
        self.address = [IPKAddress MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        [self.address unpackCityGridDictionary:[dictionary objectForKey:@"primary_address"]];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        self.address.provider = self;
    }else{
        self.address = [IPKAddress MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        [self.address unpackProviderDictionary:[[dictionary objectForKey:@"primary_address"] objectForKey:@"address"]];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
    }
    self.cached_slug = [dictionary safeObjectForKey:@"cached_slug"];
}

-(NSString *)full_name{
    if (![self.first_name isEqualToString:@""] && ![self.last_name isEqualToString:@""] && self.first_name != nil && self.last_name != nil) {
        return [self.first_name stringByAppendingFormat:@" %@", self.last_name];
    }
    return self.business_name;
}

-(NSString*)listing_id{
    return [self.listing_type stringByAppendingFormat:@"_%@", self.remoteID];
}

@end
