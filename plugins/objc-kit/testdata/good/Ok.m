#import <Foundation/Foundation.h>
#import <os/log.h>

@interface Ok : NSObject
- (void)run;
@end

@implementation Ok
- (void)run {
  os_log_t log = os_log_create("farm", "ok");
  os_log_info(log, "ok path");
  // Documented intentional seam; keep allow on the smell line when needed.
  NSLog(@"documented"); // objc-rg-allow: fixture documents allow marker for intentional NSLog seam
}
@end
