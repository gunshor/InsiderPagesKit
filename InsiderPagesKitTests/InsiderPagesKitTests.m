//
//  InsiderPagesKitTests.m
//  InsiderPagesKitTests
//
//  Created by Truman, Christopher on 8/1/12.
//

#import "InsiderPagesKitTests.h"
#import "NSRunLoop+TimeOutAndFlag.h"
#import "IPKPage.h"
#import "IPKQueryModel.h"
@implementation InsiderPagesKitTests

#warning actual specs are not implemented, these test only consist of functional demos

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    [IPKHTTPClient setDevelopmentModeEnabled:YES];
    NSIndexSet * set = [[NSIndexSet alloc] initWithIndex:500];
    [AFHTTPRequestOperation addAcceptableStatusCodes:set];
//    [SSManagedObject setTesting:@YES];
    [MagicalRecord setDefaultModelFromClass:[self class]];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    [[NSRunLoop mainRunLoop] runUntilDate:[[NSDate date] dateByAddingTimeInterval:1]];
    
    __block BOOL finished = NO;
    NSMutableDictionary * results  = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1574820006",@"id",
                                      @"Christopher Lee Truman",@"name",
                                      @"Christopher",@"first_name",
                                      @"Lee",@"middle_name",
                                      @"Truman",@"last_name",
                                      @"09/10/1990",@"birthday",
                                      [NSDictionary dictionaryWithObjectsAndKeys:@"103122293060974", @"id", @"Gardena, California", @"name", nil],  @"location", @"cleetruman@gmail.com", @"email", nil];
    [[IPKHTTPClient sharedClient] signInWithFacebookUserID:@"1574820006" accessToken:@"BAADT9DxG8csBALZCAWzmNfqa8EcaEpGU4ekoNhtfkdYtynCZCQlA1VZBUGxeZBz7DUS4M1enge8i3CDCIwfLrWTusbayH66B3Q10OFAinyhDo4BAeeQJcuSgJvuxmtciDwnuGH1uNwZDZD" facebookMeResponse:results success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[responseObject objectForKey:@"message"] isEqualToString:@"logged in"], @"Server should respond with logged in message");
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        NSLog(@"Fail %@, %@", error, operation.response);
        STAssertEquals(operation.response.statusCode,
                       500,
                       @"Facebook Authorization should return 500 if we send fb info for a user that doesn't exist.");
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    //pause to make sure server knows we are logged in
    [[NSRunLoop mainRunLoop] runUntilTimeout:1 orFinishedFlag:&finished];
}

-(void)testRegistration{
    __block BOOL finished = NO;
    NSMutableDictionary * results  = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1574820006",@"id",
                                      @"Christopher Lee Truman",@"name",
                                      @"Christopher",@"first_name",
                                      @"Lee",@"middle_name",
                                      @"Truman",@"last_name",
                                      @"09/10/1990",@"birthday",
                                      [NSDictionary dictionaryWithObjectsAndKeys:@"103122293060974", @"id", @"Gardena, California", @"name", nil],  @"location", @"cleetruman@gmail.com", @"email", nil];
    [[IPKHTTPClient sharedClient] signInWithFacebookUserID:@"1574820006" accessToken:@"BAAC4zZAGNmZBUBADxLdsPHm0idD4l5FMnPBrmQww0UZBZBILZCZCQH9ASe9aMpAhwWLlrwz5Dds0z4o2ZAzpZB4WNzP9o3hPXc0ZAO1hy5LsD9RlR2vbBWfBrEZCxBHUqF5GcWM8jbtgZBmZCAZDZD" facebookMeResponse:results success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        NSLog(@"Fail %@, %@", error, operation.response);
        STAssertEquals(operation.response.statusCode,
                       500,
                       @"Facebook Authorization should return 500 if we send fb info for a user that doesn't exist.");
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    
    [[IPKHTTPClient sharedClient] updateCurrentUserWithSuccess:^(IPKUser * currentUser){
        NSLog(@"%@", currentUser);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
}

-(void)testUserResources{
    __block BOOL finished = NO;
    NSString * remoteIDString  = [NSString stringWithFormat:@"%@", [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID];
    [[IPKHTTPClient sharedClient] getPagesForUserWithId:remoteIDString success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] getFavoritePagesForUserWithId:remoteIDString success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        for (NSDictionary * teamDict in [responseObject objectForKey:@"team"]) {
            STAssertTrue([[teamDict objectForKey:@"is_favorite"] boolValue], @"All favorite pages should have their 'is_favorite' property set as such");
            STAssertFalse([[teamDict objectForKey:@"user_id"] isEqualToNumber:[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID], @"following pages should not have been created by the user requesting the pages %@", teamDict);
        }
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] getFollowingPagesForUserWithId:remoteIDString success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        for (NSDictionary * teamDict in [responseObject objectForKey:@"teams"]) {

        }

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] getFollowersForUserWithId:remoteIDString success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] getFollowingForUserWithId:remoteIDString success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    __block IPKPage * page = [IPKPage MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    page.name = @"Unit Test Mobile";
    page.description_text = @"Unit Test Mobile Description";
    page.privacy_setting = @0;
    [[IPKHTTPClient sharedClient] createPage:page success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        [page unpackDictionary:[responseObject objectForKey:@"team"]];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    NSString * pageId = [NSString stringWithFormat:@"%@", page.remoteID];
    [[IPKHTTPClient sharedClient] deletePageWithId:pageId success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after following page");
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    
    finished = NO;
    
    IPKQueryModel * pageQueryModel = [IPKQueryModel MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    pageQueryModel.createdAt = [NSDate date];
    pageQueryModel.updatedAt = [NSDate date];
    pageQueryModel.queryString = @"Unit Test Mobile";
    pageQueryModel.state = @"CA";
    pageQueryModel.city = @"San Francisco";
    pageQueryModel.filterType = [NSNumber numberWithInt:kIPKQueryModelFilterAll];
    pageQueryModel.currentPage = @"1";
    pageQueryModel.perPageNumber = @"20";
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
    [[IPKHTTPClient sharedClient] pageSearchWithQueryModel:pageQueryModel success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        for (NSDictionary * pageDictionary in [responseObject objectForKey:@"results"]) {
            IPKPage * page = [IPKPage objectWithDictionary:pageDictionary];
            __block BOOL finishedInner = NO;
            
            NSString * pageId = [NSString stringWithFormat:@"%@", page.remoteID];
            [[IPKHTTPClient sharedClient] deletePageWithId:pageId success:^(AFJSONRequestOperation *operation, id responseObject){
                // NSLog(@"%@", responseObject);

                STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after following page");
                finishedInner = YES;
            } failure:^(AFJSONRequestOperation *operation, NSError *error){
                STAssertTrue(NO, [error debugDescription]);        
                finishedInner = YES;
            }];
            [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finishedInner];
        }

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:500 orFinishedFlag:&finished];
}

-(void)testUserActions{
    __block BOOL finished = NO;
    //    http://qa.insiderpages.com/users/ChristopherBBaker/teams/396
    NSString * pageID = [NSString stringWithFormat:@"%d", 396];
    [[IPKHTTPClient sharedClient] followPageWithId:pageID success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after following page, %@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;

    [[IPKHTTPClient sharedClient] unfollowPageWithId:pageID success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after unfollowing page, %@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    NSString * userID = [NSString stringWithFormat:@"%d", 8];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];

    [[IPKHTTPClient sharedClient] followUserWithId:userID success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after following user, %@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        NSLog(@"Fail %@, %@, %@", error, operation.response, operation.request.URL);
        STAssertTrue(NO, [error debugDescription]);  
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] unfollowUserWithId:userID success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after following user, %@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        NSLog(@"Fail %@, %@, %@", error, operation.response, operation.request.URL);
        STAssertTrue(NO, [error debugDescription]);  
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
}

-(void)testPublicUserAccess{
    __block BOOL finished = NO;
    NSString * userID = [NSString stringWithFormat:@"%@", [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID];
    [[IPKHTTPClient sharedClient] getUserInfoWithId:userID success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] getFollowersForUserWithId:userID success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] getFollowingForUserWithId:userID success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
}

-(void)testPageActions{
    
    __block BOOL finished = NO;
    //    http://qa.insiderpages.com/users/ChristopherBBaker/teams/396
    NSString * otherUsersPageID = [NSString stringWithFormat:@"%d", 396];
    //    http://qa.insiderpages.com/users/cleetruman/teams/810
    NSString * myPageID = [NSString stringWithFormat:@"%d", 810];
    NSString * providerID = [NSString stringWithFormat:@"CgListing_%d", 670507540];
    IPKProvider * provider = [IPKProvider objectWithRemoteID:@(670507540)];
    [provider setListing_type:@"CgListing"];
    [[IPKHTTPClient sharedClient] getProvidersForPageWithId:myPageID sortUser:[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]] success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[[responseObject allKeys] objectAtIndex:0] isEqualToString: @"providers"], @"Server should respond with list of providers");
        STAssertTrue([[responseObject objectForKey:@"providers"] isKindOfClass: [NSArray class]], @"Server should provide an array of providers.");
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] getFollowersForPageWithId:myPageID success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);
        STAssertTrue([[[responseObject allKeys] objectAtIndex:1] isEqualToString:@"followers" ], @"Server should respond with list of followers");
        STAssertTrue([[responseObject objectForKey:@"followers"] isKindOfClass:[NSArray class]] || [[responseObject objectForKey:@"followers"] isKindOfClass:[NSDictionary class]], @"Server should respond with array of followers");
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] addProvidersToPageWithId:myPageID provider:provider success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after adding provider to page");
        
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] addProvidersToPageWithId:myPageID provider:provider scoopText:@"scoop" success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after adding provider to page");
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] removeProvidersFromPageWithId:myPageID provider:provider success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after removing provider from page");
        
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] favoritePageWithId:otherUsersPageID success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after favorite-ing a page");
        
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];

    finished = NO;
    [[IPKHTTPClient sharedClient] unfavoritePageWithId:otherUsersPageID success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after removing provider from page");
        
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];

}

-(void)testCollaboratorAction{
    __block BOOL finished = NO;
    
    NSString * remoteIDString  = [NSString stringWithFormat:@"%@", [IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID];
    [[IPKHTTPClient sharedClient] getPagesForUserWithId:remoteIDString success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);
        
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    
    NSString * myPageID = [NSString stringWithFormat:@"%d", 810];

    [[IPKHTTPClient sharedClient] getProvidersForPageWithId:myPageID sortUser:[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]] success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);
        
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;

    NSString * hanaUserID = [NSString stringWithFormat:@"%lld", 5359006809];
    [[IPKHTTPClient sharedClient] reorderProvidersForPageWithId:myPageID newOrder:@[@(0),@(1)] success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after removing provider from page");
        
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] getCollaboratorsForPageWithId:myPageID success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

//        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after removing provider from page");
        
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] addCollaboratorsToPageWithId:myPageID userID:hanaUserID success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after removing collaborator from page");
        
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] removeCollaboratorsFromPageWithId:myPageID userID:hanaUserID success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after removing collaborator from page");
        
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];

}

-(void)testProviderActions{
    
    __block BOOL finished = NO;
    NSString * providerID = [NSString stringWithFormat:@"%d", 1];
    [[IPKHTTPClient sharedClient] getPagesForProviderWithId:providerID withCurrentPage:@1 perPage:@10 success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        STAssertTrue([[[responseObject allKeys] objectAtIndex:0] isEqualToString: @"pages"], @"Server should respond with list of pages");
        STAssertTrue([[responseObject objectForKey:@"pages"] isKindOfClass: [NSArray class]], @"Server should provide an array of pages.");
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
}

-(void)testSearch{
    __block BOOL finished = NO;
    
    IPKQueryModel * providerQueryModel = [IPKQueryModel MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    providerQueryModel.createdAt = [NSDate date];
    providerQueryModel.updatedAt = [NSDate date];
    providerQueryModel.queryString = @"doctor";
    providerQueryModel.state = @"CA";
    providerQueryModel.city = @"San Francisco";
    providerQueryModel.filterType = [NSNumber numberWithInt:kIPKQueryModelFilterAll];
    providerQueryModel.currentPage = @"1";
    providerQueryModel.perPageNumber = @"20";
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
    [[IPKHTTPClient sharedClient] providerSearchWithQueryModel:providerQueryModel success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    IPKQueryModel * insiderQueryModel = [IPKQueryModel MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    insiderQueryModel.createdAt = [NSDate date];
    insiderQueryModel.updatedAt = [NSDate date];
    insiderQueryModel.queryString = @"Chris";
    insiderQueryModel.state = @"CA";
    insiderQueryModel.city = @"San Francisco";
    insiderQueryModel.filterType = [NSNumber numberWithInt:kIPKQueryModelFilterAll];
    insiderQueryModel.currentPage = @"1";
    insiderQueryModel.perPageNumber = @"20";
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
    [[IPKHTTPClient sharedClient] insiderSearchWithQueryModel:insiderQueryModel success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    IPKQueryModel * pageQueryModel = [IPKQueryModel MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    pageQueryModel.createdAt = [NSDate date];
    pageQueryModel.updatedAt = [NSDate date];
    pageQueryModel.queryString = @"Health";
    pageQueryModel.state = @"CA";
    pageQueryModel.city = @"San Francisco";
    pageQueryModel.filterType = [NSNumber numberWithInt:kIPKQueryModelFilterAll];
    pageQueryModel.currentPage = @"1";
    pageQueryModel.perPageNumber = @"20";
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
    [[IPKHTTPClient sharedClient] pageSearchWithQueryModel:pageQueryModel success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
}

-(void)testActivities{
    __block BOOL finished = NO;

    for (int i = 0; i <= 4; i++) {
        enum IPKActivityType type = i;
        [[IPKHTTPClient sharedClient] getActivititesOfType:(enum IPKActivityType)type includeFollowing:YES currentPage:@1 perPage:@10 success:^(AFJSONRequestOperation *operation, id responseObject){
            // NSLog(@"%@", responseObject);

            finished = YES;
        } failure:^(AFJSONRequestOperation *operation, NSError *error){
            STAssertTrue(NO, [error debugDescription]);
            finished = YES;
        }];
        [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
        
        finished = NO;
    }
    
    for (int i = 0; i <= 4; i++) {
        enum IPKActivityType type = i;
        [[IPKHTTPClient sharedClient] getActivititesOfType:(enum IPKActivityType)type includeFollowing:NO currentPage:@1 perPage:@10 success:^(AFJSONRequestOperation *operation, id responseObject){
            // NSLog(@"%@", responseObject);

            finished = YES;
        } failure:^(AFJSONRequestOperation *operation, NSError *error){
            STAssertTrue(NO, [error debugDescription]);
            finished = YES;
        }];
        [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
        
        finished = NO;
    }
    
    [[IPKHTTPClient sharedClient] getPageActivititesWithCurrentPage:@1 perPage:@10 success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
}

-(void)testNotifications{
    __block BOOL finished = NO;
    
    [[IPKHTTPClient sharedClient] getNotificationsWithCurrentPage:@1 perPage:@10 success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
}

-(void)testScoops{

    __block BOOL finished = NO;
    NSString * userIDString = [NSString stringWithFormat:@"%@",[IPKUser currentUserInContext:[NSManagedObjectContext MR_contextForCurrentThread]].remoteID];
    [[IPKHTTPClient sharedClient] getScoopsForUserWithId:userIDString withCurrentPage:@1 perPage:@3 success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        for (NSDictionary* plugDictionary in [responseObject objectForKey:@"scoops"]) {
            for (NSDictionary * scoopDictionary in [responseObject objectForKey:@"scoops"]) {
                STAssertTrue([[scoopDictionary objectForKey:@"why_recommended"] isKindOfClass:[NSString class]], @"Should contain why_recommended string");
            }
        }

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
        
    finished = NO;
    NSString * localProviderID = [NSString stringWithFormat:@"%d", 1];
    [[IPKHTTPClient sharedClient] getScoopsForProviderWithId:localProviderID withCurrentPage:@1 perPage:@3 success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        for (NSDictionary * scoopDictionary in [responseObject objectForKey:@"scoops"]) {
            NSLog(@"%@", [scoopDictionary objectForKey:@"why_recommended"]);
            STAssertTrue([[scoopDictionary objectForKey:@"why_recommended"] isKindOfClass:[NSString class]], @"Should contain why_recommended string");
        }
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] getScoopsForProviderWithId:localProviderID withCurrentPage:@2 perPage:@3 success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        for (NSDictionary * scoopDictionary in [responseObject objectForKey:@"scoops"]) {
            NSLog(@"%@", [scoopDictionary objectForKey:@"why_recommended"]);
            STAssertTrue([[scoopDictionary objectForKey:@"why_recommended"] isKindOfClass:[NSString class]], @"Should contain why_recommended string");
        }
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
        
    finished = NO;
    NSString * localPageId = [(@41) stringValue];
    [[IPKHTTPClient sharedClient] getScoopsForPageWithId:localPageId withCurrentPage:@1 perPage:@3 success:^(AFJSONRequestOperation *operation, id responseObject){
        // NSLog(@"%@", responseObject);

        for (NSDictionary * scoopDictionary in [responseObject objectForKey:@"scoops"]) {
            STAssertTrue([[scoopDictionary objectForKey:@"why_recommended"] isKindOfClass:[NSString class]], @"Should contain why_recommended string");
        }
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

@end
