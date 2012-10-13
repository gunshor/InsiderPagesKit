//
//  IPKAbstractModel.h
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/10/12.
//

#import "IPKRemoteManagedObject.h"

@interface IPKAbstractModel : IPKRemoteManagedObject

-(NSString*)formattedTimeElapsedSinceUpdated;
-(NSString*)formattedTimeElapsedSinceCreated;
+(NSString*)defaultSortDescriptors;

@end
