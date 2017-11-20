Pod::Spec.new do |spec|
  spec.name         = 'FilestackSDK'
  spec.version      = File.read('./VERSION')
  spec.license      = { :type => 'Apache License, Version 2.0"', :file => "LICENSE" }
  spec.homepage     = 'https://github.com/filestack/filestack-swift'
  spec.authors      = { 'Filestack' => 'ios@filestack.com' }
  spec.summary      = 'Official Swift SDK for Filestack.'
  spec.source       = { :git => 'https://github.com/filestack/filestack-swift.git', :tag => spec.version }

  spec.ios.deployment_target  = '9.0'

  spec.source_files = 'FilestackSDK/**/*.{h,swift}'

  spec.dependency 'Alamofire', '~> 4.5'
  spec.dependency 'CryptoSwift', '~> 0.7.0'
end
