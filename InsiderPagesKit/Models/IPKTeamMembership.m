//
//  IPKTeamMembership.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 10/2/12.
//

#import "IPKTeamMembership.h"
#import "IPKPage.h"
#import "IPKProvider.h"
#import "IPKUser.h"


@implementation IPKTeamMembership

@dynamic team_id;
@dynamic listing_id;
@dynamic owner_id;
@dynamic position;
@dynamic team;
@dynamic listing;
@dynamic owner;

+(IPKTeamMembership *)teamMembershipForUserID:(NSNumber*)userID teamID:(NSNumber*)teamID listingID:(NSNumber *)listingID{
    // Default to the main context
    NSManagedObjectContext * context;
	if (!context) {
		context = [NSManagedObjectContext MR_contextForCurrentThread];
	}
	
	// Create the fetch request for the ID
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [self MR_entityDescriptionInContext:context];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"owner_id = %@ && team_id == %@ && listing_id == %@", userID, teamID, listingID];
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

+(IPKTeamMembership *)createMembershipForUserID:(NSNumber*)userID teamID:(NSNumber*)teamID listingID:(NSNumber *)listingID{
    IPKTeamMembership * teamMembership = [self teamMembershipForUserID:userID teamID:teamID listingID:listingID];
    if (teamMembership) {
        return teamMembership;
    }else{
        NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
        teamMembership = [IPKTeamMembership MR_createInContext:context];
        teamMembership.owner_id = userID;
        teamMembership.owner = [IPKUser objectWithRemoteID:userID context:context];
        teamMembership.team_id = teamID;
        teamMembership.team = [IPKPage objectWithRemoteID:teamID context:context];
        teamMembership.listing_id = listingID;
        teamMembership.listing = [IPKProvider objectWithRemoteID:listingID context:context];
        [context MR_save];
        return teamMembership;
    }

}

@end
