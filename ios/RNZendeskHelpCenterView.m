#import "RNZendeskHelpCenterView.h"

@interface RNZendeskHelpCenterView ()
@property(nonatomic, strong) WKWebView *webView;
@end

@implementation RNZendeskHelpCenterView

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _javaScriptEnabled = YES;
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.defaultWebpagePreferences.allowsContentJavaScript = YES;
    _webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_webView];
  }
  return self;
}

- (void)setJavaScriptEnabled:(BOOL)javaScriptEnabled
{
  _javaScriptEnabled = javaScriptEnabled;
  self.webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = javaScriptEnabled;
}

- (void)setUrl:(NSString *)url
{
  _url = [url copy];
  if (_url.length == 0) {
    return;
  }

  NSURL *targetURL = [NSURL URLWithString:_url];
  if (targetURL == nil) {
    return;
  }
  NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
  [self.webView loadRequest:request];
}

@end
