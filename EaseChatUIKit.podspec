#
# Be sure to run `pod lib lint EaseChatUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EaseChatUIKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of EaseChatUIKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/zjc19891106/EaseChatUIKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zjc19891106' => '984065974@qq.com' }
  s.source           = { :git => 'https://github.com/zjc19891106/EaseChatUIKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.ios.deployment_target = '13.0'
  s.xcconfig = {'ENABLE_BITCODE' => 'NO'}
  
  s.subspec 'Service' do |ss|
      ss.source_files = [
        'Sources/EaseChatUIKit/Classes/Service/**/*'
      ]
      ss.dependency 'Agora_Chat_iOS'
  end

  s.subspec 'UI' do |ss|
    ss.source_files = [
      'Sources/EaseChatUIKit/Classes/UI/**/*.{h,swift}'
    ]
    ss.resources = ['Sources/EaseChatUIKit/Classes/UI/**/*.bundle']

  end
  s.static_framework = true
  
  s.swift_version = '5.0'
  s.prefix_header_contents = '
  # if __has_include (<EaseChatUIKit/EaseChatUIKit-Bridge.h>)
  #import <EaseChatUIKit/EaseChatUIKit-Bridge.h> 
  # else
  #import "EaseChatUIKit-Bridge.h"
  # endif
  '
  s.public_header_files = 'Sources/EaseChatUIKit/Classes/UI/Foundation/EaseChatUIKit-Bridge.h'

  s.preserve_paths =  ['Sources/EaseChatUIKit/Classes/UI/Core/Foundation/third-party/**/*.a','Sources/EaseChatUIKit/Classes/UI/Core/Foundation/third-party/vo-amrwbenc/lib/*.a']
  

  s.vendored_libraries = ['Sources/EaseChatUIKit/Classes/UI/Core/Foundation/third-party/**/*.a','Sources/EaseChatUIKit/Classes/UI/Core/Foundation/third-party/vo-amrwbenc/lib/*.a'] 

  s.xcconfig = { 'LIBRARY_SEARCH_PATHS' => '$(PODS_ROOT)/Sources/EaseChatUIKit/Classes/UI/Core/Foundation/third-party/**/*' } # 设置搜索路径，使得项目可以找到这些静态库

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

   s.frameworks = 'UIKit', 'Foundation','Combine','AudioToolbox'
end
