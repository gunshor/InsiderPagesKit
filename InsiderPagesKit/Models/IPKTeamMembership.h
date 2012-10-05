//
//  IPKTeamMembership.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 10/2/12.
//

@class IPKPage, IPKProvider, IPKUser;

@interface IPKTeamMembership : NSManagedObject

@property (nonatomic, retain) NSNumber * team_id;
@property (nonatomic, retain) NSNumber * listing_id;
@property (nonatomic, retain) NSNumber * owner_id;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * pollaverage;
@property (nonatomic, retain) IPKPage *team;
@property (nonatomic, retain) IPKProvider *listing;
@property (nonatomic, retain) IPKUser *owner;

+(IPKTeamMembership *)teamMembershipForUserID:(NSNumber*)userID teamID:(NSNumber*)teamID listingID:(NSNumber *)listingID;

+(IPKTeamMembership *)createMembershipForUserID:(NSNumber*)userID teamID:(NSNumber*)teamID listingID:(NSNumber *)listingID;

@end
