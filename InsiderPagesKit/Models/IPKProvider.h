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

@property (nonatomic, retain) NSString * attribution_url;
@property (nonatomic, retain) NSString * business_name;
@property (nonatomic, retain) NSNumber * cg_listing_id;
@property (nonatomic, retain) NSNumber * created_by_id;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * description_text;
@property (nonatomic, retain) NSString * email_address;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSNumber * last_updated_by_id;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSDate * updated_from_ip_at;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSSet *pages;
@property (nonatomic, retain) IPKReview *reviews;
@property (nonatomic, retain) NSSet *activities;
@property (nonatomic, retain) IPKAddress * address;

-(NSDictionary*)packToDictionary;
-(NSString*)full_name;

@end

@interface IPKProvider (CoreDataGeneratedAccessors)

- (void)addPagesObject:(IPKPage *)value;
- (void)removePagesObject:(IPKPage *)value;
- (void)addPages:(NSSet *)values;
- (void)removePages:(NSSet *)values;

@end