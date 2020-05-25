Pod::Spec.new do |s|
  s.name                    = "USController"
  s.version                 = "1.0.0"
  s.summary                 = "More customizable split controller for IOS device universe."
  s.homepage                = "https://github.com/ytur/USController"
  s.license                 = { :type => "MIT" }
  s.author                  = { "ytur" => "yasinturkoglu@yahoo.com" }
  s.swift_version           = "5.2"
  s.ios.deployment_target   = "9.0"
  s.source                  = { :git => "https://github.com/ytur/USController.git", :tag => "#{s.version}" }
  s.source_files            = "Source/**/*.swift"
end
