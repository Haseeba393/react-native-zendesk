require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  pod_xcconfig = {
    "CLANG_ENABLE_MODULES" => "YES",
    "CLANG_ENABLE_OBJC_ARC" => "YES",
    "OTHER_CFLAGS" => "$(inherited) -fmodules -fcxx-modules",
    "OTHER_CPLUSPLUSFLAGS" => "$(inherited) -fmodules -fcxx-modules"
  }

  s.name         = "react-native-zendesk"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.license      = package["license"]
  s.authors      = package["author"]
  s.homepage     = "https://github.com/Haseeba393/react-native-zendesk"
  s.platforms    = { :ios => "13.0" }
  s.source       = { :git => "https://github.com/Haseeba393/react-native-zendesk.git", :tag => "v#{s.version}" }
  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.pod_target_xcconfig = pod_xcconfig

  s.dependency "React-Core"
  s.dependency "React-Codegen"
  s.dependency "ZendeskSupportSDK", "~> 9.0"
  s.dependency "ZendeskCoreSDK", "~> 5.0"

  if ENV["RCT_NEW_ARCH_ENABLED"] == "1"
    s.compiler_flags = "-DRCT_NEW_ARCH_ENABLED=1"
    s.pod_target_xcconfig = pod_xcconfig.merge({
      "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
      "CLANG_CXX_LANGUAGE_STANDARD" => "c++20"
    })
    s.dependency "React-RCTFabric"
    s.dependency "ReactCommon/turbomodule/core"
  end
end
