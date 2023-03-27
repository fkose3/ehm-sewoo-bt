
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNEhmSewooBtSpec.h"

@interface EhmSewooBt : NSObject <NativeEhmSewooBtSpec>
#else
#import <React/RCTBridgeModule.h>

@interface EhmSewooBt : NSObject <RCTBridgeModule>
#endif

@end
