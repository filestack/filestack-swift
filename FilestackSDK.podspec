Pod::Spec.new do |spec|
  spec.name         = 'FilestackSDK'
  spec.version      = File.read('./VERSION')
  spec.license      = { :type => 'Apache License, Version 2.0"', :file => "LICENSE" }
  spec.homepage     = 'https://github.com/filestack/filestack-swift'
  spec.authors      = { 'Filestack' => 'ios@filestack.com' }
  spec.summary      = 'Official Swift SDK for Filestack.'
  spec.source       = { :git => 'https://github.com/filestack/filestack-swift.git', :tag => spec.version }

  spec.ios.deployment_target  = '11.0'

  spec.source_files = 'Sources/**/*.{h,swift}'
  spec.exclude_files = 'Sources/**/SPMSupport/*.*'

  spec.dependency 'Alamofire', '~> 4.9'
end
