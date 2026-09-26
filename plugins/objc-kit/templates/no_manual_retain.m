#import <Foundation/Foundation.h>

// Boundary: prefer ARC. Manual [obj retain] / [obj release] / [obj autorelease]
// message sends are banned by objc-rg-gate. CFRetain/CFRelease at CF bridges stay
// outside this Tier 0 bar; document with objc-rg-allow when an ObjC MRC call is intentional.
static inline id ProductKeep(id value) {
  return value; // ARC retains as needed via strong locals / properties
}
