Pod::Spec.new do |s|
  s.name    = 'GoSquared'
  s.version = '1.0.0'
  s.summary = 'Tracking SDK for integrating GoSquared in your iOS app.'

  s.homepage         = 'https://gosquared.com/'
  s.social_media_url = 'https://twitter.com/gosquared'

  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author  = { 'Giles Williams' => 'giles.williams@gmail.com', 'Ed Wellbrook' => 'edwellbrook@gmail.com', 'Ben White' => 'ben@benjackwhite.co.uk' }

  s.ios.deployment_target  = '6.0'
  s.tvos.deployment_target = '9.0'

  s.requires_arc    = true
  s.source          = { :git => 'https://github.com/gosquared/gosquared-ios.git', :tag => "v#{s.version}" }
  s.default_subspec = 'Core'

  s.prepare_command = 'curl -f -s -o GoSquared/Embed/chat.js.tmp "https://js.gs-chat.com/chat-embedded.js?$RANDOM" && mv GoSquared/Embed/chat.js.tmp GoSquared/Embed/chat.js'

  s.subspec 'Core' do |ss|
    ss.source_files        = 'GoSquared/*.{h,m}'
    ss.public_header_files = 'Gosquared/{GoSquared,GSTracker,GSTypes,GSTransaction,GSTransactionItem}.h'
    ss.frameworks          = 'Foundation', 'UIKit'
  end

  s.subspec 'Autoload' do |ss|
    ss.dependency 'GoSquared/Core'

    ss.source_files        = 'GoSquared/Autoload/*.{h,m}'
    ss.public_header_files = 'GoSquared/Autoload/*.h'
    ss.frameworks          = 'Foundation', 'UIKit'
  end

  s.subspec 'Chat' do |ss|
    ss.dependency 'GoSquared/Core'

    ss.ios.deployment_target = '8.0'
    ss.source_files          = 'GoSquared/Chat/*.{h,m}'
    ss.public_header_files   = 'Gosquared/Chat/{GoSquared+Chat,GSChatViewController,UIViewController+Chat}.h'
    ss.frameworks            = 'Foundation', 'UIKit', 'WebKit'
    ss.weak_frameworks       = 'SafariServices'
    ss.resource_bundles     = { 'GSChatEmbed' => 'GoSquared/Embed/**/*' }
  end
end
