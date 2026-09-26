#import <Foundation/Foundation.h>
#import <os/log.h>

// Boundary: prefer os_log (or an injected logger) over NSLog in library code.
// NSLog is banned by objc-rg-gate. Escape: objc-rg-allow with rationale on the smell line.
static inline void ProductLogInfo(os_log_t log, NSString *message) {
  os_log_info(log, "%{public}@", message);
}
