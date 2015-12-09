Pod::Spec.new do |s|

  s.name             = "GoSquared"
  s.version          = "0.0.5"
  s.summary          = "Tracking SDK for integrating GoSquared in your iOS app."

  s.homepage         = "https://gosquared.com/"
  s.social_media_url = "https://twitter.com/gosquared"

  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Giles Williams" => "giles.williams@gmail.com",
                         "Ed Wellbrook"   => "edwellbrook@gmail.com" }

  s.platform         = :ios, "6.0"
  s.requires_arc     = true
  s.source           = { :git => "https://github.com/gosquared/gosquared-ios.git", :tag => "v#{s.version}" }
  s.default_subspec  = "GoSquared"

  s.subspec "GoSquared" do |ss|
    ss.source_files  = "GoSquared/*.{m,h}"
  end

  # include swizzling to automatically track view controllers
  s.subspec "Autoload" do |ss|
    ss.source_files  = "GoSquared/**/*.{m,h}"
  end

end
