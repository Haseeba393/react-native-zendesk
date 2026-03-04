#import "RNZendeskModule.h"

#import <React/RCTConvert.h>
#import <React/RCTLog.h>
#import <UIKit/UIKit.h>
#import <SupportSDK/SupportSDK.h>
#import <ZendeskCoreSDK/ZendeskCoreSDK.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <ReactCommon/CallInvoker.h>
#import <ReactCommon/TurboModule.h>
#if __has_include(<React-Codegen/RNZendeskSpec.h>)
#import <React-Codegen/RNZendeskSpec.h>
#define RN_ZENDESK_HAS_CODEGEN 1
#elif __has_include("RNZendeskSpec.h")
#import "RNZendeskSpec.h"
#define RN_ZENDESK_HAS_CODEGEN 1
#else
#define RN_ZENDESK_HAS_CODEGEN 0
#endif
#endif

@interface RNZendeskModule ()
@property(nonatomic, strong) NSString *subdomain;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *apiToken;
@property(nonatomic, strong) NSString *locale;
@property(nonatomic, assign) BOOL sdkInitialized;
@end

@implementation RNZendeskModule

RCT_EXPORT_MODULE(RNZendesk)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

- (instancetype)init
{
  if (self = [super init]) {
    _locale = @"";
    _sdkInitialized = NO;
  }
  return self;
}

RCT_EXPORT_METHOD(initialize
                  : (NSDictionary *)config resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject)
{
  NSString *providedSubdomain = [RCTConvert NSString:config[@"subdomain"]];
  self.email = [RCTConvert NSString:config[@"email"]];
  self.apiToken = [RCTConvert NSString:config[@"apiToken"]];
  NSString *name = [RCTConvert NSString:config[@"name"]];
  NSString *locale = [RCTConvert NSString:config[@"locale"]];
  self.locale = locale.length > 0 ? locale : @"";

  NSString *zendeskUrl = [RCTConvert NSString:config[@"zendeskUrl"]];
  NSString *appId = [RCTConvert NSString:config[@"appId"]];
  NSString *clientId = [RCTConvert NSString:config[@"clientId"]];
  NSString *derivedSubdomain = [self extractSubdomainFromZendeskUrl:zendeskUrl];
  self.subdomain = providedSubdomain.length > 0 ? providedSubdomain : derivedSubdomain;

  if (self.subdomain.length == 0) {
    reject(@"E_ZENDESK_CONFIG",
           @"Provide subdomain or a valid zendeskUrl (https://<subdomain>.zendesk.com)",
           nil);
    return;
  }

  self.sdkInitialized = NO;
  if (zendeskUrl.length > 0 && appId.length > 0 && clientId.length > 0) {
    @try {
      [ZDKClassicZendesk initializeWithAppId:appId clientId:clientId zendeskUrl:zendeskUrl];
      [ZDKSupport initializeWithZendesk:[ZDKClassicZendesk instance]];

      id<ZDKObjCIdentity> identity = [[ZDKObjCAnonymous alloc] initWithName:name email:self.email];
      [[ZDKClassicZendesk instance] setIdentity:identity];
      if (self.locale.length > 0) {
        [ZDKSupport instance].helpCenterLocaleOverride = self.locale.lowercaseString;
      }
      self.sdkInitialized = YES;
    } @catch (NSException *exception) {
      reject(@"E_ZENDESK_SDK_INIT", exception.reason, nil);
      return;
    }
  }
  resolve(@(YES));
}

RCT_EXPORT_METHOD(getArticles
                  : (NSString *)locale labels
                  : (NSArray<NSString *> *)labels page
                  : (NSNumber *)page perPage
                  : (NSNumber *)perPage resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject)
{
  if (!resolve || !reject) {
    return;
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    [self openHelpCenterImpl:resolve reject:reject];
  });
}

RCT_EXPORT_METHOD(getArticle
                  : (NSNumber *)articleId locale
                  : (NSString *)locale resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject)
{
  if (!resolve || !reject || !articleId) {
    return;
  }
  NSNumber *articleIdCopy = [articleId copy];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self openArticleImpl:articleIdCopy resolve:resolve reject:reject];
  });
}

RCT_EXPORT_METHOD(searchArticles
                  : (NSString *)query locale
                  : (NSString *)locale page
                  : (NSNumber *)page perPage
                  : (NSNumber *)perPage resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject)
{
  if (!resolve || !reject) {
    return;
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    [self openHelpCenterImpl:resolve reject:reject];
  });
}

RCT_EXPORT_METHOD(createTicket
                  : (NSDictionary *)request resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject)
{
  if (!resolve || !reject) {
    return;
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    [self openContactSupportImpl:resolve reject:reject];
  });
}

RCT_EXPORT_METHOD(openHelpCenter
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject)
{
  if (!resolve || !reject) {
    return;
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    [self openHelpCenterImpl:resolve reject:reject];
  });
}

- (void)openHelpCenterImpl:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject
{
  if (self.sdkInitialized) {
    UIViewController *helpCenter = [ZDKHelpCenterUi buildHelpCenterOverviewUiWithConfigs:@[]];
    [self presentZendeskController:helpCenter
                           resolve:resolve
                            reject:reject
                         errorCode:@"E_ZENDESK_OPEN_HELP_CENTER"];
    return;
  }

  NSString *domain = [self requiredSubdomainOrReject:reject];
  if (domain.length == 0) {
    return;
  }
  NSString *localeSegment = self.locale.length > 0 ? [@"/" stringByAppendingString:self.locale] : @"";
  NSString *url = [NSString stringWithFormat:@"https://%@.zendesk.com/hc%@", domain, localeSegment];
  [self openUrl:url resolve:resolve reject:reject];
}

RCT_EXPORT_METHOD(openArticle
                  : (NSNumber *)articleId resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject)
{
  if (!resolve || !reject || !articleId) {
    return;
  }
  NSNumber *articleIdCopy = [articleId copy];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self openArticleImpl:articleIdCopy resolve:resolve reject:reject];
  });
}

- (void)openArticleImpl:(NSNumber *)articleId resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject
{
  if (self.sdkInitialized) {
    UIViewController *articleController = [ZDKHelpCenterUi buildHelpCenterArticleUiWithArticleId:articleId.stringValue andConfigs:@[]];
    [self presentZendeskController:articleController
                           resolve:resolve
                            reject:reject
                         errorCode:@"E_ZENDESK_OPEN_ARTICLE"];
    return;
  }

  NSString *domain = [self requiredSubdomainOrReject:reject];
  if (domain.length == 0) {
    return;
  }
  NSString *url = [NSString
      stringWithFormat:@"https://%@.zendesk.com/hc/articles/%@",
                       domain, articleId];
  [self openUrl:url resolve:resolve reject:reject];
}

- (void)openContactSupportImpl:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject
{
  if (self.sdkInitialized) {
    UIViewController *requestController = [ZDKRequestUi buildRequestUiWith:@[]];
    [self presentZendeskController:requestController
                           resolve:resolve
                            reject:reject
                         errorCode:@"E_ZENDESK_OPEN_CONTACT_SUPPORT"];
    return;
  }

  NSString *domain = [self requiredSubdomainOrReject:reject];
  if (domain.length == 0) {
    return;
  }
  NSString *localeSegment = self.locale.length > 0 ? [@"/" stringByAppendingString:self.locale] : @"";
  NSString *url = [NSString stringWithFormat:@"https://%@.zendesk.com/hc%@/requests/new", domain, localeSegment];
  [self openUrl:url resolve:resolve reject:reject];
}

RCT_EXPORT_METHOD(openContactSupport
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject)
{
  if (!resolve || !reject) {
    return;
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    [self openContactSupportImpl:resolve reject:reject];
  });
}

RCT_EXPORT_METHOD(openContactSupportWithDetails
                  : (NSString *)email customFields
                  : (NSArray<NSDictionary *> *)customFields resolve
                  : (RCTPromiseResolveBlock)resolve reject
                  : (RCTPromiseRejectBlock)reject)
{
  if (!resolve || !reject) {
    return;
  }
  NSString *emailCopy = email ? [email copy] : nil;
  NSArray *customFieldsCopy = customFields ? [customFields copy] : nil;
  dispatch_async(dispatch_get_main_queue(), ^{
    [self openContactSupportWithDetailsImpl:emailCopy customFields:customFieldsCopy resolve:resolve reject:reject];
  });
}

- (void)openContactSupportWithDetailsImpl:(NSString *)email
                            customFields:(NSArray<NSDictionary *> *)customFields
                                 resolve:(RCTPromiseResolveBlock)resolve
                                  reject:(RCTPromiseRejectBlock)reject
{
  if (self.sdkInitialized) {
    if (email.length > 0) {
      id<ZDKObjCIdentity> identity = [[ZDKObjCAnonymous alloc] initWithName:nil email:email];
      [[ZDKClassicZendesk instance] setIdentity:identity];
    }

    NSMutableArray<ZDKCustomField *> *fields = [NSMutableArray array];
    for (NSDictionary *item in customFields) {
      NSString *key = [RCTConvert NSString:item[@"key"]];
      NSString *value = [RCTConvert NSString:item[@"value"]];
      if (key.length == 0 || value.length == 0) {
        continue;
      }
      NSString *keyTrimmed = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      if ([keyTrimmed hasSuffix:@"L"] || [keyTrimmed hasSuffix:@"l"]) {
        keyTrimmed = [keyTrimmed substringToIndex:keyTrimmed.length - 1];
      }
      NSNumber *fieldId = @(keyTrimmed.longLongValue);
      [fields addObject:[[ZDKCustomField alloc] initWithFieldId:fieldId value:value]];
    }

    ZDKRequestUiConfiguration *config = [ZDKRequestUiConfiguration new];
    config.customFields = fields;

    UIViewController *requestController = [ZDKRequestUi buildRequestUiWith:@[ config ]];
    [self presentZendeskController:requestController
                           resolve:resolve
                            reject:reject
                         errorCode:@"E_ZENDESK_OPEN_CONTACT_SUPPORT"];
    return;
  }

  [self openContactSupportImpl:resolve reject:reject];
}

- (void)openUrl:(NSString *)urlString
        resolve:(RCTPromiseResolveBlock)resolve
         reject:(RCTPromiseRejectBlock)reject
{
  dispatch_async(dispatch_get_main_queue(), ^{
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
      reject(@"E_ZENDESK_OPEN_URL", @"Invalid URL", nil);
      return;
    }

    if (![[UIApplication sharedApplication] canOpenURL:url]) {
      reject(@"E_ZENDESK_OPEN_URL", @"Unable to open URL", nil);
      return;
    }

    [[UIApplication sharedApplication]
        openURL:url
        options:@{}
        completionHandler:^(BOOL success) {
          if (!success) {
            reject(@"E_ZENDESK_OPEN_URL", @"openURL completion failed", nil);
            return;
          }
          resolve(@(YES));
        }];
  });
}

- (void)performRequest:(NSString *)method
                   url:(NSString *)urlString
               payload:(NSDictionary *)payload
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject
{
  NSURL *url = [NSURL URLWithString:urlString];
  if (url == nil) {
    reject(@"E_ZENDESK_URL", @"Invalid URL", nil);
    return;
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  request.HTTPMethod = method;
  [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
  NSString *auth = [self authHeader];
  if (auth.length > 0) {
    [request addValue:auth forHTTPHeaderField:@"Authorization"];
  }

  if (payload != nil) {
    NSError *serializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&serializationError];
    if (serializationError != nil) {
      reject(@"E_ZENDESK_SERIALIZE", serializationError.localizedDescription, serializationError);
      return;
    }
    request.HTTPBody = jsonData;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  }

  NSURLSessionDataTask *task = [[NSURLSession sharedSession]
      dataTaskWithRequest:request
        completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
          if (error != nil) {
            reject(@"E_ZENDESK_NETWORK", error.localizedDescription, error);
            return;
          }

          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
          NSString *rawBody = data != nil ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"{}";

          if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
            reject(@"E_ZENDESK_HTTP",
                   [NSString stringWithFormat:@"Zendesk request failed (%ld): %@", (long)httpResponse.statusCode, rawBody],
                   nil);
            return;
          }

          if (data == nil) {
            resolve(@{});
            return;
          }

          NSError *jsonError = nil;
          id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
          if (jsonError != nil || ![object isKindOfClass:[NSDictionary class]]) {
            resolve(@{ @"raw" : rawBody ?: @"" });
            return;
          }
          resolve(object);
        }];
  [task resume];
}

- (void)presentZendeskController:(UIViewController *)controller
                         resolve:(RCTPromiseResolveBlock)resolve
                          reject:(RCTPromiseRejectBlock)reject
                       errorCode:(NSString *)errorCode
{
  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController *top = [self topMostViewController];
    if (top == nil || controller == nil) {
      reject(errorCode, @"Unable to find active view controller", nil);
      return;
    }

    if (top.navigationController != nil) {
      [top.navigationController pushViewController:controller animated:YES];
    } else {
      UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
      [top presentViewController:nav animated:YES completion:nil];
    }
    resolve(@(YES));
  });
}

- (UIViewController *)topMostViewController
{
  UIWindow *window = nil;
  for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
    if (![scene isKindOfClass:[UIWindowScene class]]) {
      continue;
    }
    if (scene.activationState != UISceneActivationStateForegroundActive) {
      continue;
    }
    for (UIWindow *candidate in ((UIWindowScene *)scene).windows) {
      if (candidate.isKeyWindow) {
        window = candidate;
        break;
      }
    }
    if (window != nil) {
      break;
    }
  }
  if (window == nil) {
    window = UIApplication.sharedApplication.keyWindow;
  }

  UIViewController *top = window.rootViewController;
  while (top.presentedViewController != nil) {
    top = top.presentedViewController;
  }
  return top;
}

- (NSString *)extractSubdomainFromZendeskUrl:(NSString *)zendeskUrl
{
  if (zendeskUrl.length == 0) {
    return nil;
  }

  NSURL *url = [NSURL URLWithString:zendeskUrl];
  NSString *host = url.host.lowercaseString;
  NSString *suffix = @".zendesk.com";
  if (host.length == 0 || ![host hasSuffix:suffix]) {
    return nil;
  }

  NSString *subdomain = [host substringToIndex:(host.length - suffix.length)];
  return subdomain.length > 0 ? subdomain : nil;
}

- (NSString *)baseApiUrlOrReject:(RCTPromiseRejectBlock)reject
{
  NSString *domain = [self requiredSubdomainOrReject:reject];
  if (domain.length == 0) {
    return nil;
  }
  return [NSString stringWithFormat:@"https://%@.zendesk.com/api/v2", domain];
}

- (NSString *)requiredSubdomainOrReject:(RCTPromiseRejectBlock)reject
{
  if (self.subdomain.length == 0) {
    reject(@"E_ZENDESK_CONFIG", @"Zendesk is not initialized. Call initialize() first.", nil);
    return nil;
  }
  return self.subdomain;
}

- (NSString *)authHeader
{
  if (self.email.length == 0 || self.apiToken.length == 0) {
    return nil;
  }

  NSString *raw = [NSString stringWithFormat:@"%@/token:%@", self.email, self.apiToken];
  NSData *data = [raw dataUsingEncoding:NSUTF8StringEncoding];
  NSString *encoded = [data base64EncodedStringWithOptions:0];
  return [NSString stringWithFormat:@"Basic %@", encoded];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
#if RN_ZENDESK_HAS_CODEGEN
  return std::make_shared<facebook::react::NativeZendeskSpecJSI>(params);
#else
  return nullptr;
#endif
}
#endif

@end
