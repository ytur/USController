Pod::Spec.new do |s|
  s.name = 'USController'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'More customizable split controller for IOS device universe.'
  s.homepage = 'https://github.com/ytur/USController'
  s.authors = { 'ytur' => 'yasinturkoglu@yahoo.com' }
  s.swift_versions = ['5.1', '5.2']
  s.ios.deployment_target = '9.0'
  s.source = { :git => 'https://github.com/ytur/USController.git', :tag => s.version }
  s.source_files = 'Source/**/*.swift'
end
