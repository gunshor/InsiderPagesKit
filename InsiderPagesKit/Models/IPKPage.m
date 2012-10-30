//
//  IPKPage.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//

#import "IPKHTTPClient.h"
#import "IPKPage.h"
#import "IPKUser.h"
#import "NSDictionary+InsiderPagesKit.h"
#import "NSMutableDictionary+InsiderPagesKit.h"

@implementation IPKPage

@dynamic createdAt;
@dynamic description_text;
@dynamic image_content_type;
@dynamic image_file_name;
@dynamic image_updated_at;
@dynamic name;
@dynamic privacy_setting;
@dynamic remoteID;
@dynamic sequence;
@dynamic sort;
@dynamic updatedAt;
@dynamic user_id;
@dynamic section_header;
@dynamic is_favorite;
@dynamic is_following;
@dynamic is_collaborator;
@dynamic collaborator_count;
@dynamic business_count;
@dynamic comment_count;
@dynamic following_users;
@dynamic owner;
@dynamic providers;
@dynamic activities;
@dynamic reviews;
@dynamic teamMemberships;
@dynamic teamFollowings;

-(NSDictionary*)packToDictionary{
    NSMutableDictionary * packedDictionary = [NSMutableDictionary dictionary];
    [packedDictionary setSafeObject:self.name forKey:@"name"];
    //    [packedDictionary setSafeObject:self.description_text forKey:@"description_text"];
    //    [packedDictionary setSafeObject:self.id forKey:@"id"];
    [packedDictionary setSafeObject:self.image_content_type forKey:@"image_content_type"];
    [packedDictionary setSafeObject:self.image_file_name forKey:@"image_file_name"];
    [packedDictionary setSafeObject:self.image_updated_at forKey:@"image_updated_at"];
    [packedDictionary setSafeObject:self.privacy_setting forKey:@"privacy_setting"];
//    [packedDictionary setSafeObject:self.sequence forKey:@"sequence"];
//    [packedDictionary setSafeObject:self.sort forKey:@"sort"];
    //    [packedDictionary setSafeObject:self.user_id forKey:@"user_id"];
    //    [packedDictionary setSafeObject:self.providers forKey:@"providers"];
    //    [packedDictionary setSafeObject:self.owner forKey:@"owner"];
    //    [packedDictionary setSafeObject:self.followers forKey:@"followers"];
    return packedDictionary;
}

- (void)unpackDictionary:(NSDictionary *)dictionary {
	[super unpackDictionary:dictionary];    
	self.name = [dictionary safeObjectForKey:@"name"];
    self.description_text = [dictionary safeObjectForKey:@"description_text"];
    self.image_content_type = [dictionary safeObjectForKey:@"image_content_type"];
    self.image_file_name = [dictionary safeObjectForKey:@"image_file_name"];
    self.image_updated_at = [dictionary safeObjectForKey:@"image_updated_at"] ? [[IPKRemoteManagedObject class] parseDate:[dictionary objectForKey:@"image_updated_at"]] : nil;
    self.privacy_setting = [dictionary safeObjectForKey:@"privacy_setting"];
    self.sequence = [dictionary safeObjectForKey:@"sequence"];
    self.sort = [dictionary safeObjectForKey:@"sort"];
    self.user_id = [dictionary safeObjectForKey:@"user_id"];
    self.providers = [dictionary safeObjectForKey:@"providers"];
    if ([dictionary safeObjectForKey:@"user_id"]) {
        self.owner = [IPKUser objectWithRemoteID:self.user_id context:self.managedObjectContext];
    }
    self.following_users = [dictionary safeObjectForKey:@"followers"];
    if ([dictionary safeObjectForKey:@"is_favorite"]) {
        self.is_favorite = [dictionary safeObjectForKey:@"is_favorite"];
    }
    else {
        self.is_favorite = [NSNumber numberWithBool:NO];
    }
    if ([dictionary safeObjectForKey:@"is_following"]) {
        self.is_following = [dictionary safeObjectForKey:@"is_following"];
    }
    else {
        self.is_following = [NSNumber numberWithBool:NO];
    }
    if ([dictionary safeObjectForKey:@"is_collaborator"]) {
        self.is_collaborator = [dictionary safeObjectForKey:@"is_collaborator"];
    }
    else {
        self.is_collaborator = [NSNumber numberWithBool:NO];
    }

    self.comment_count = [dictionary safeObjectForKey:@"comment_count"];
    self.collaborator_count = [dictionary safeObjectForKey:@"collaborator_count"];
    self.business_count = [dictionary safeObjectForKey:@"business_count"];
}

- (void)update {
	[self updateWithSuccess:nil failure:nil];
}


- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"pollaverage", @"sort_option",
                            nil];
    NSString * path = [NSString stringWithFormat:@"teams/%@",self.remoteID];
    [[IPKHTTPClient sharedClient] getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self unpackDictionary:[responseObject objectForKey:@"team"]];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure((AFJSONRequestOperation *)operation, error);
        }
    }];
}

//http://stackoverflow.com/a/7922993/150920
- (void)addProvidersObject:(IPKProvider *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.providers];
    [tempSet addObject:value];
    self.providers = tempSet;
}

@end
