

Pod::Spec.new do |spec|

  spec.name         = "HiddenCamera"
  spec.version      = "1.0.6"
  spec.summary      = "Hidden Camera takes selfie with out user knowledge."
  spec.description  = "Hidden Camera takes selfie with out user knowledge."
  spec.homepage     = "http://EXAMPLE/HiddenCamera"
  spec.license      = "MIT"
  spec.author             = { "" => "" }
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/ashwinflx/HiddenCamera.git", :tag => "1.0.6" }
  spec.source_files  = "HiddenCamera"
  spec.static_framework  = true
  spec.swift_version = "4.2"
  spec.dependency 'OpenCV2', '~> 4.1.1'

end
