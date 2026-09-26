#import <Foundation/Foundation.h>

// Intentional smells for objc-rg-gate discrimination (not product code).
@interface Smell : NSObject
@end

@implementation Smell
- (void)run {
  NSLog(@"intentional library NSLog smell");
  id target = self;
  [target performSelector:@selector(description)];
  id kept = [target retain];
  [kept release];
  [[NSObject new] autorelease];
}
@end
