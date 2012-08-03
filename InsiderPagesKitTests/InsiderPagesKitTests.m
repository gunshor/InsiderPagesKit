//
//  InsiderPagesKitTests.m
//  InsiderPagesKitTests
//
//  Created by Truman, Christopher on 8/1/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "InsiderPagesKitTests.h"
#import "NSRunLoop+TimeOutAndFlag.h"
@implementation InsiderPagesKitTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    [IPKHTTPClient setDevelopmentModeEnabled:YES];
    NSIndexSet * set = [[NSIndexSet alloc] initWithIndex:500];
    [AFHTTPRequestOperation addAcceptableStatusCodes:set];
    [SSManagedObject setTesting:@YES];
    [IPKUser mainContext];
}



- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

-(void)testRegistration{
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                            @"1574820006",
//                            @"fb_user_id",@"BAADT9DxG8csBALZCAWzmNfqa8EcaEpGU4ekoNhtfkdYtynCZCQlA1VZBUGxeZBz7DUS4M1enge8i3CDCIwfLrWTusbayH66B3Q10OFAinyhDo4BAeeQJcuSgJvuxmtciDwnuGH1uNwZDZD",
//                            @"fb_access_token", nil];
    // create the semaphore and lock it once before we start
    // the async operation
    
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
    [[NSRunLoop mainRunLoop] runUntilTimeout:5 orFinishedFlag:&finished];
       NSMutableDictionary * results  = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1574820006",@"id",
                                      @"Christopher Lee Truman",@"name",
                                      @"Christopher",@"first_name",
                                      @"Lee",@"middle_name",
                                      @"Truman",@"last_name",
                                      @"09/10/1990",@"birthday",
                                      [NSDictionary dictionaryWithObjectsAndKeys:@"103122293060974", @"id", @"Gardena, California", @"name", nil],  @"location", @"cleetruman@gmail.com", @"email", nil];
    [[IPKHTTPClient sharedClient] registerWithFacebookMeResponse:results success:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"HELLO");
        NSLog(@"%@", responseObject);
        finished = YES;
    } failure:^(AFJSONRequestOperation *operation, NSError *error){
        NSLog(@"Fail %@, %@, %@", error, operation.response, operation.request.URL);
        finished = YES;
    }];
}

-(void)testPages{
//    [IPKHTTPClient ]
}

@end
