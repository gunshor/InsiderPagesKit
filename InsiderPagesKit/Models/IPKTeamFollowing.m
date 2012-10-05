//
//  IPKTeamFollowing.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 10/2/12.
//

#import "IPKTeamFollowing.h"
#import "IPKPage.h"
#import "IPKUser.h"

@implementation IPKTeamFollowing

@dynamic team_id;
@dynamic privilege;
@dynamic user_id;
@dynamic team;
@dynamic user;

+(IPKTeamFollowing *)teamFollowingForUserID:(NSNumber*)userID andTeamID:(NSNumber*)teamID{
    // Default to the main context
    NSManagedObjectContext * context;
	if (!context) {
		context = [NSManagedObjectContext MR_contextForCurrentThread];
	}
	
	// Create the fetch request for the ID
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [self MR_entityDescriptionInContext:context];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user_id = %@ && team_id == %@", userID, teamID];
    fetchRequest.includesPendingChanges = YES;
	fetchRequest.fetchLimit = 1;
	
	// Execute the fetch request
	NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
	
	// If the object is not found, return nil
	if (results.count == 0) {
		return nil;
	}
	
	// Return the object
	return [results objectAtIndex:0];
}

+(IPKTeamFollowing *)createFollowingForUserID:(NSNumber*)userID andTeamID:(NSNumber*)teamID privilege:(NSNumber *)privilege{
    IPKTeamFollowing * teamFollowing = [self teamFollowingForUserID:userID andTeamID:teamID];
    if (teamFollowing) {
        return teamFollowing;
    }else{
        NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
        teamFollowing = [IPKTeamFollowing MR_createInContext:context];
        teamFollowing.user_id = userID;
        teamFollowing.user = [IPKUser objectWithRemoteID:userID context:context];
        teamFollowing.team_id = teamID;
        teamFollowing.team = [IPKPage objectWithRemoteID:teamID context:context];
        teamFollowing.privilege = privilege;
        return teamFollowing;
    }
}

@end
