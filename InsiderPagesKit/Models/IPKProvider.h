//
//  Provider.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKAbstractModel.h"

@class IPKPage;

@interface IPKProvider : IPKAbstractModel

@property (nonatomic, retain) NSNumber * attribution_url;
@property (nonatomic, retain) NSString * business_name;
@property (nonatomic, retain) NSNumber * cg_listing_id;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * created_by_id;
@property (nonatomic, retain) NSString * description_text;
@property (nonatomic, retain) NSString * email_address;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) id last_updated_by_id;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) id updated_from_ip_at;

-(NSDictionary*)packToDictionary;
-(NSString*)full_name;

@end

@interface IPKProvider (CoreDataGeneratedAccessors)

- (void)addPagesObject:(IPKPage *)value;
- (void)removePagesObject:(IPKPage *)value;
- (void)addPages:(NSSet *)values;
- (void)removePages:(NSSet *)values;

@end