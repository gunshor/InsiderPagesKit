//
//  IPKReview.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/10/12.
//

#import "IPKAbstractModel.h"

@interface IPKReview : IPKAbstractModel

@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * image_content_type;
@property (nonatomic, retain) NSString * image_file_name;
@property (nonatomic, retain) NSNumber * image_file_size;
@property (nonatomic, retain) NSDate * image_updated_at;
@property (nonatomic, retain) NSNumber * ip_review_id;
@property (nonatomic, retain) NSNumber * listing_id;
@property (nonatomic, retain) NSString * listing_type;
@property (nonatomic, retain) NSNumber * privacy_setting;
@property (nonatomic, retain) NSString * reviewed_by;
@property (nonatomic, retain) NSNumber * team_id;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * user_ip;
@property (nonatomic, retain) NSString * why_recommended;

@end
