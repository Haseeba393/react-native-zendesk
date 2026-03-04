#import <React/RCTViewManager.h>
#import "RNZendeskHelpCenterView.h"

@interface RNZendeskHelpCenterViewManager : RCTViewManager
@end

@implementation RNZendeskHelpCenterViewManager

RCT_EXPORT_MODULE(RNZendeskHelpCenterView)

- (UIView *)view
{
  return [RNZendeskHelpCenterView new];
}

RCT_EXPORT_VIEW_PROPERTY(url, NSString)
RCT_EXPORT_VIEW_PROPERTY(javaScriptEnabled, BOOL)

@end
