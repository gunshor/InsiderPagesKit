//
//  Page.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/2/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKPage.h"
#import "IPKUser.h"
#import "NSDictionary+InsiderPagesKit.h"
#import "NSMutableDictionary+InsiderPagesKit.h"

@implementation IPKPage

@dynamic name;
@dynamic description_text;
@dynamic id;
@dynamic remoteID;
@dynamic image_content_type;
@dynamic image_file_name;
@dynamic image_file_size;
@dynamic image_updated_at;
@dynamic privacy_setting;
@dynamic sequence;
@dynamic sort;
@dynamic updatedAt;
@dynamic user_id;
@dynamic createdAt;
@dynamic providers;
@dynamic owner;
@dynamic followers;
@dynamic is_favorite;

-(NSDictionary*)packToDictionary{
    NSMutableDictionary * packedDictionary = [NSMutableDictionary dictionary];
    [packedDictionary setSafeObject:self.name forKey:@"name"];
//    [packedDictionary setSafeObject:self.description_text forKey:@"description_text"];
//    [packedDictionary setSafeObject:self.id forKey:@"id"];
    [packedDictionary setSafeObject:self.image_content_type forKey:@"image_content_type"];
    [packedDictionary setSafeObject:self.image_file_name forKey:@"image_file_name"];
    [packedDictionary setSafeObject:self.image_file_size forKey:@"image_file_size"];
    [packedDictionary setSafeObject:self.image_updated_at forKey:@"image_updated_at"];
    [packedDictionary setSafeObject:self.privacy_setting forKey:@"privacy_setting"];
    [packedDictionary setSafeObject:self.sequence forKey:@"sequence"];
    [packedDictionary setSafeObject:self.sort forKey:@"sort"];
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
    self.id = [dictionary safeObjectForKey:@"id"];
    self.image_content_type = [dictionary safeObjectForKey:@"image_content_type"];
    self.image_file_name = [dictionary safeObjectForKey:@"image_file_name"];
    self.image_file_size = [dictionary safeObjectForKey:@"image_file_size"];
    self.image_updated_at = [dictionary safeObjectForKey:@"image_updated_at"];
    self.privacy_setting = [dictionary safeObjectForKey:@"privacy_setting"];
    self.sequence = [dictionary safeObjectForKey:@"sequence"];
    self.sort = [dictionary safeObjectForKey:@"sort"];
    self.user_id = [dictionary safeObjectForKey:@"user_id"];
    self.providers = [dictionary safeObjectForKey:@"providers"];
    self.owner = [dictionary safeObjectForKey:@"owner"];
    self.followers = [dictionary safeObjectForKey:@"followers"];
    if ([dictionary safeObjectForKey:@"is_favorite"]) {
        self.is_favorite = [dictionary safeObjectForKey:@"is_favorite"];
    }
    else {
        [self setValue:[NSNumber numberWithInt:1] forKey:@"is_favorite"];
    }
}

@end
