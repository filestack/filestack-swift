Pod::Spec.new do |spec|
  spec.name         = 'FilestackSDK'
  spec.version      = File.read('./VERSION')
  spec.license      = { :type => 'Apache License, Version 2.0"', :file => "LICENSE" }
  spec.homepage     = 'https://github.com/filestack/filestack-swift'
  spec.authors      = { 'Filestack' => 'ios@filepicker.io' }
  spec.summary      = 'Official Swift SDK for Filestack - API and content management system that makes it easy to add powerful file uploading and transformation capabilities to any web or mobile application.'
  spec.source       = { :git => 'https://github.com/filestack/filestack-swift.git', :tag => "v#{spec.version}" }

  spec.ios.deployment_target  = '9.0'

  spec.source_files       = 'FilestackSDK/**/*.swift'
  
  spec.dependency 'Alamofire', '~> 4.5'
  spec.dependency 'SCrypto', '~> 2.0'
end
