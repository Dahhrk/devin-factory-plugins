#import <Foundation/Foundation.h>

// Boundary: prefer typed methods / blocks over performSelector: smells.
// performSelector: / performSelectorOnMainThread: / performSelectorInBackground: /
// performSelectorOnThread: are banned by objc-rg-gate.
@protocol ProductRunnable <NSObject>
- (void)run;
@end

static inline void ProductRun(id<ProductRunnable> target) {
  [target run];
}
