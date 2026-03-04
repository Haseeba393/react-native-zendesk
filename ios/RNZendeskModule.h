#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <ReactCommon/RCTTurboModule.h>
#endif

@interface RNZendeskModule : NSObject <RCTBridgeModule
#ifdef RCT_NEW_ARCH_ENABLED
, RCTTurboModule
#endif
>
@end
