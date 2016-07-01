Pod::Spec.new do |s|
  s.name = 'GoSquared'
  s.version = '0.7.0'
  s.summary = 'Tracking SDK for integrating GoSquared in your iOS app.'

  s.homepage = 'https://gosquared.com/'
  s.social_media_url = 'https://twitter.com/gosquared'

  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Giles Williams' => 'giles.williams@gmail.com', 'Ed Wellbrook' => 'edwellbrook@gmail.com' }

  s.ios.deployment_target = '6.0'
  s.tvos.deployment_target = '9.0'

  s.requires_arc = true
  s.source = { :git => 'https://github.com/gosquared/gosquared-ios.git', :tag => "v#{s.version}" }
  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = 'GoSquared/*.{h,m}'
    ss.public_header_files = 'Gosquared/{GoSquared,GSTracker,GSTypes,GSTransaction,GSTransactionItem}.h'
  end

  # include swizzling to automatically track view controllers
  s.subspec 'Autoload' do |ss|
    ss.source_files = 'GoSquared/Autoload/*.{h,m}'
    ss.dependency 'GoSquared/Core'
  end

  s.subspec 'Chat' do |ss|
    ss.ios.deployment_target = '7.0'
    ss.source_files = 'GoSquared+Chat/**/*.{h,m}'
    ss.public_header_files = 'Gosquared+Chat/{GoSquared+Chat,GSTracker+Chat,GSChatViewController,GSChatBarButtonItem,UIViewController+Chat}.h'
    ss.dependency 'GoSquared/Core'
    ss.dependency 'SocketRocket', '0.4.2'
    ss.dependency 'PINRemoteImage', '2.1.3'
  end
end
