//
//  Provider.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKAbstractModel.h"

@class IPKPage;
@class IPKReview;
@class IPKAddress;

@interface IPKProvider : IPKAbstractModel

@property (nonatomic, strong) NSString * attribution_url;
@property (nonatomic, strong) NSString * business_name;
@property (nonatomic, strong) NSNumber * cg_listing_id;
@property (nonatomic, strong) NSNumber * created_by_id;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSString * description_text;
@property (nonatomic, strong) NSString * email_address;
@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSNumber * last_updated_by_id;
@property (nonatomic, strong) NSNumber * remoteID;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSDate * updated_from_ip_at;
@property (nonatomic, strong) NSDate * updatedAt;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSString * cached_slug;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSString * listing_type;
@property (nonatomic, strong) NSSet *pages;
@property (nonatomic, strong) IPKReview *reviews;
@property (nonatomic, strong) NSSet *activities;
@property (nonatomic, strong) IPKAddress * address;

-(NSDictionary*)packToDictionary;
-(NSString*)full_name;
-(NSString*)listing_id;

@end

@interface IPKProvider (CoreDataGeneratedAccessors)

- (void)addPagesObject:(IPKPage *)value;
- (void)removePagesObject:(IPKPage *)value;
- (void)addPages:(NSSet *)values;
- (void)removePages:(NSSet *)values;

@end