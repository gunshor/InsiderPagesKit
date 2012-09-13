//
//  IPKReview.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/10/12.
//

#import "IPKReview.h"
#import "IPKUser.h" 
#import "IPKProvider.h"
#import "IPKPage.h"
#import "NSDictionary+InsiderPagesKit.h"

@implementation IPKReview

@dynamic about;
@dynamic createdAt;
@dynamic image_content_type;
@dynamic image_file_name;
@dynamic image_file_size;
@dynamic image_updated_at;
@dynamic ip_review_id;
@dynamic listing_id;
@dynamic listing_type;
@dynamic privacy_setting;
@dynamic remoteID;
@dynamic reviewed_by;
@dynamic team_id;
@dynamic updatedAt;
@dynamic user_id;
@dynamic user_ip;
@dynamic why_recommended;
@dynamic activities;
@dynamic reviewer;
@dynamic provider;
@dynamic page;

+ (NSString *)entityName {
	return @"IPKReview";
}

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];    
	self.about = [dictionary safeObjectForKey:@"about"];
    self.image_content_type = [dictionary safeObjectForKey:@"image_content_type"];
    self.image_file_name = [dictionary safeObjectForKey:@"image_file_name"];
    self.image_file_size = [dictionary safeObjectForKey:@"image_file_size"];
    self.image_updated_at = [dictionary safeObjectForKey:@"image_updated_at"];
    self.ip_review_id = [dictionary safeObjectForKey:@"ip_review_id"];
    self.listing_id = [dictionary safeObjectForKey:@"listing_id"];
    self.listing_type = [dictionary safeObjectForKey:@"listing_type"];
#warning need to figure out how to differentiate cglisting and provider when linking to a review
//    if ([self.listing_type isEqualToString:@"CgListing"]) {
//        self.provider = [[IPKProvider MR_findByAttribute:@"cg_listing_id" withValue:self.listing_id] objectAtIndex:0];
//    }else if([self.listing_type isEqualToString:@"Provider"]){
//        self.provider = [[IPKProvider MR_findByAttribute:@"ip_listing_id" withValue:self.listing_id] objectAtIndex:0];
//    }
    self.privacy_setting = [dictionary safeObjectForKey:@"privacy_setting"];
    self.reviewed_by = [dictionary safeObjectForKey:@"reviewed_by"];
    self.team_id = [dictionary safeObjectForKey:@"team_id"];
    if(self.team_id != nil){
        self.page = [IPKPage objectWithRemoteID:self.team_id];
    }
    self.user_id = [dictionary safeObjectForKey:@"user_id"];
    if (self.user_id) {
        self.reviewer = [IPKUser objectWithRemoteID:self.user_id];
    }
    self.user_ip = [dictionary safeObjectForKey:@"user_ip"];
    self.why_recommended = [dictionary safeObjectForKey:@"why_recommended"];
}

@end
