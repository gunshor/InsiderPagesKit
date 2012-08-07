//
//  InsiderPagesKitTests.m
//  InsiderPagesKitTests
//
//  Created by Truman, Christopher on 8/1/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
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
    [SSManagedObject setTesting:@YES];
    [IPKUser mainContext];
    [[NSRunLoop mainRunLoop] runUntilDate:[[NSDate date] dateByAddingTimeInterval:1]];

    __block BOOL finished = NO;

    [[IPKHTTPClient sharedClient] signInWithFacebookUserID:@"1574820006" accessToken:@"BAADT9DxG8csBALZCAWzmNfqa8EcaEpGU4ekoNhtfkdYtynCZCQlA1VZBUGxeZBz7DUS4M1enge8i3CDCIwfLrWTusbayH66B3Q10OFAinyhDo4BAeeQJcuSgJvuxmtciDwnuGH1uNwZDZD" success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
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
    
    [[IPKHTTPClient sharedClient] signInWithFacebookUserID:@"1574820006" accessToken:@"BAADT9DxG8csBALZCAWzmNfqa8EcaEpGU4ekoNhtfkdYtynCZCQlA1VZBUGxeZBz7DUS4M1enge8i3CDCIwfLrWTusbayH66B3Q10OFAinyhDo4BAeeQJcuSgJvuxmtciDwnuGH1uNwZDZD" success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
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
    [[IPKHTTPClient sharedClient] signInWithFacebookUserID:@"1574820006" accessToken:@"BAADT9DxG8csBALZCAWzmNfqa8EcaEpGU4ekoNhtfkdYtynCZCQlA1VZBUGxeZBz7DUS4M1enge8i3CDCIwfLrWTusbayH66B3Q10OFAinyhDo4BAeeQJcuSgJvuxmtciDwnuGH1uNwZDZD" success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
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
    NSMutableDictionary * results  = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1574820006",@"id",
                                      @"Christopher Lee Truman",@"name",
                                      @"Christopher",@"first_name",
                                      @"Lee",@"middle_name",
                                      @"Truman",@"last_name",
                                      @"09/10/1990",@"birthday",
                                      [NSDictionary dictionaryWithObjectsAndKeys:@"103122293060974", @"id", @"Gardena, California", @"name", nil],  @"location", @"cleetruman@gmail.com", @"email", nil];
    [[IPKHTTPClient sharedClient] registerWithFacebookMeResponse:results success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
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
    NSString * remoteIDString  = [NSString stringWithFormat:@"%@", [IPKUser currentUser].id];
    [[IPKHTTPClient sharedClient] getPagesForUserWithId:remoteIDString success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] getFollowersForUserWithId:remoteIDString success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] getFollowingForUserWithId:remoteIDString success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    __block IPKPage * page = [[IPKPage alloc] init];
    page.name = @"Unit Test Mobile";
    page.description_text = @"Unit Test Mobile Description";
    page.privacy_setting = @0;
    [[IPKHTTPClient sharedClient] createPage:page success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        [page unpackDictionary:[responseObject objectForKey:@"team"]];
        [page save];
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    NSString * pageId = [NSString stringWithFormat:@"%@", page.id];
    [[IPKHTTPClient sharedClient] deletePageWithId:pageId success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after following page");
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
}

-(void)testUserActions{
    __block BOOL finished = NO;
    NSString * pageID = [NSString stringWithFormat:@"%d", 1];

    [[IPKHTTPClient sharedClient] followPageWithId:pageID success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after following page");
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] unfollowPageWithId:pageID success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after unfollowing page");
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
        
    finished = NO;
    NSString * userID = [NSString stringWithFormat:@"%d", 1];
    [[IPKHTTPClient sharedClient] unfollowUserWithId:userID success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after following user");
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        NSLog(@"Fail %@, %@, %@", error, operation.response, operation.request.URL);
        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] followUserWithId:userID success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after following user");
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        NSLog(@"Fail %@, %@, %@", error, operation.response, operation.request.URL);
        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
}

-(void)testPublicUserAccess{
    __block BOOL finished = NO;
    NSString * userID = [NSString stringWithFormat:@"%d", 1];
    [[IPKHTTPClient sharedClient] getUserInfoWithId:userID success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] getFollowersForUserWithId:userID success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] getFollowingForUserWithId:userID success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
}

-(void)testPageActions{
    
    __block BOOL finished = NO;
    NSString * pageID = [NSString stringWithFormat:@"%d", 39];
    NSString * providerID = [NSString stringWithFormat:@"%d", 1];
    [[IPKHTTPClient sharedClient] getProvidersForPageWithId:pageID success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        STAssertTrue([[[responseObject allKeys] objectAtIndex:0] isEqualToString: @"providers"], @"Server should respond with list of providers");
        STAssertTrue([[responseObject objectForKey:@"providers"] isKindOfClass: [NSArray class]], @"Server should provide an array of providers.");
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] getFollowersForPageWithId:pageID success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        STAssertTrue([[[responseObject allKeys] objectAtIndex:0] isEqualToString:@"followers" ], @"Server should respond with list of followers");
        STAssertTrue([[responseObject objectForKey:@"followers"] isKindOfClass:[NSArray class]], @"Server should respond with array of followers");
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] addProvidersToPageWithId:pageID providerId:providerID success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after adding provider to page");

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] addProvidersToPageWithId:pageID providerId:providerID scoopText:@"scoop" success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after adding provider to page");
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    [[IPKHTTPClient sharedClient] removeProvidersFromPageWithId:pageID providerId:providerID success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        STAssertTrue([[responseObject objectForKey:@"success"] boolValue], @"Server should respond with success after removing provider from page");

        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
}

-(void)testSearch{
    __block BOOL finished = NO;
    
    IPKQueryModel * providerQueryModel = [IPKQueryModel new];
    providerQueryModel.created_at = [NSDate date];
    providerQueryModel.updated_at = [NSDate date];
    providerQueryModel.queryString = @"doctor";
    providerQueryModel.state = @"CA";
    providerQueryModel.city = @"San Francisco";
    providerQueryModel.filterType = [NSNumber numberWithInt:kIPKQueryModelFilterAll];
    providerQueryModel.currentPage = @"1";
    providerQueryModel.perPageNumber = @"20";
    [providerQueryModel save];
    [[IPKHTTPClient sharedClient] providerSearchWithQueryModel:providerQueryModel success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    IPKQueryModel * insiderQueryModel = [IPKQueryModel new];
    insiderQueryModel.created_at = [NSDate date];
    insiderQueryModel.updated_at = [NSDate date];
    insiderQueryModel.queryString = @"Chris";
    insiderQueryModel.state = @"CA";
    insiderQueryModel.city = @"San Francisco";
    insiderQueryModel.filterType = [NSNumber numberWithInt:kIPKQueryModelFilterAll];
    insiderQueryModel.currentPage = @"1";
    insiderQueryModel.perPageNumber = @"20";
    [insiderQueryModel save];
    [[IPKHTTPClient sharedClient] insiderSearchWithQueryModel:insiderQueryModel success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
    
    finished = NO;
    IPKQueryModel * pageQueryModel = [IPKQueryModel new];
    pageQueryModel.created_at = [NSDate date];
    pageQueryModel.updated_at = [NSDate date];
    pageQueryModel.queryString = @"Health";
    pageQueryModel.state = @"CA";
    pageQueryModel.city = @"San Francisco";
    pageQueryModel.filterType = [NSNumber numberWithInt:kIPKQueryModelFilterAll];
    pageQueryModel.currentPage = @"1";
    pageQueryModel.perPageNumber = @"20";
    [pageQueryModel save];
    [[IPKHTTPClient sharedClient] pageSearchWithQueryModel:pageQueryModel success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        STAssertTrue(NO, [error debugDescription]);        
        finished = YES;
    }];
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

@end
