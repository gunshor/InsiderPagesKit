//
//  IPKReview.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/10/12.
//

#import "IPKAbstractModel.h"

@class IPKUser;
@class IPKPage;
@class IPKProvider;

@interface IPKReview : IPKAbstractModel

@property (nonatomic, strong) NSString * about;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSString * image_content_type;
@property (nonatomic, strong) NSString * image_file_name;
@property (nonatomic, strong) NSNumber * image_file_size;
@property (nonatomic, strong) NSDate * image_updated_at;
@property (nonatomic, strong) NSNumber * ip_review_id;
@property (nonatomic, strong) NSNumber * listing_id;
@property (nonatomic, strong) NSString * listing_type;
@property (nonatomic, strong) NSNumber * privacy_setting;
@property (nonatomic, strong) NSNumber * remoteID;
@property (nonatomic, strong) NSString * reviewed_by;
@property (nonatomic, strong) NSNumber * team_id;
@property (nonatomic, strong) NSDate * updatedAt;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSString * user_ip;
@property (nonatomic, strong) NSString * why_recommended;
@property (nonatomic, strong) NSSet *activities;
@property (nonatomic, strong) IPKUser *reviewer;
@property (nonatomic, strong) IPKProvider *provider;
@property (nonatomic, strong) IPKPage *page;

@end
