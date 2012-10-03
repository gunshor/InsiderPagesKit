//
//  IPKTeamFollowing.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 10/2/12.
//

@class IPKPage, IPKUser;

@interface IPKTeamFollowing : NSManagedObject

@property (nonatomic, retain) NSNumber * team_id;
@property (nonatomic, retain) NSNumber * privilege;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) IPKPage *team;
@property (nonatomic, retain) IPKUser *user;

+(IPKTeamFollowing *)teamFollowingForUserID:(NSNumber*)userID andTeamID:(NSNumber*)teamID;

+(IPKTeamFollowing *)createFollowingForUserID:(NSNumber*)userID andTeamID:(NSNumber*)teamID privilege:(NSNumber *)privilege;

@end
