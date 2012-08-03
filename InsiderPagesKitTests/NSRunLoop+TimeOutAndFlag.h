//
//  NSRunLoop+TimeOutAndFlag.h
//
//

@interface NSRunLoop (TimeOutAndFlag)

- (void)runUntilTimeout:(NSTimeInterval)delay orFinishedFlag:(BOOL*)finished;

@end
