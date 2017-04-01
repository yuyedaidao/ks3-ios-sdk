Pod::Spec.new do |s|

  s.name         = "Ks3SDK"
  s.version      = "1.7.2"
  s.summary      = "iOS SDK for Kingsoft Standard Storage Service"

  s.description  = <<-DESC
    An iOS SDK for developers to use Kingsoft Standard Storage Service easier.
                   DESC

  s.homepage     = "http://www.ksyun.com/proservice/storage_service"

  s.license      = "Apache License, Version 2.0"

  s.author             = { "voidmain" => "voidmain1313113@gmail.com" }

  s.source       = { :git => "https://github.com/ks3sdk/ks3-ios-sdk.git", :tag => "v" + s.version.to_s }

  s.requires_arc = true

  s.ios.deployment_target = '6.0'

  s.source_files  = "KS3SDKIOS/**/*.{h,m}"

  s.frameworks = 'SystemConfiguration'

  s.library   = 'resolv'
end
