//
//  IPKAbstractModel.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/10/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import <InsiderPagesKit/InsiderPagesKit.h>
#import "SSDataKit.h"
#import "IPKRemoteManagedObject.h"

@interface IPKAbstractModel : IPKRemoteManagedObject

-(NSString*)formattedTimeElapsedSinceUpdated;
-(NSString*)formattedTimeElapsedSinceCreated;

@end
