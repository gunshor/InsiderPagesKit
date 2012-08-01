//
//  InsiderPagesKitTests.m
//  InsiderPagesKitTests
//
//  Created by Truman, Christopher on 8/1/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "InsiderPagesKitTests.h"

@implementation InsiderPagesKitTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    [IPKHTTPClient setDevelopmentModeEnabled:YES];
}



- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

-(void)testInitial{
    [[IPKHTTPClient sharedClient] getListsWithSuccess:^(AFJSONRequestOperation *operation, id responseObject){
        NSLog(@"%@ %@ %@", operation, operation.response, responseObject);
    }
      failure:^(AFJSONRequestOperation *operation, NSError *error){
          NSLog(@"%@ %@", operation, error);
      }
     ];
    sleep(500);
}
@end
