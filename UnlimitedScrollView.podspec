#
#  Be sure to run `pod spec lint UnlimitedScrollView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name          = "UnlimitedScrollView"
  s.version       = "0.1.0"
  s.summary       = "UnlimitedScrollView provides an endlessly UIScrollView"
  s.homepage      = "https://github.com/tamanyan/UnlimitedScrollView"
  s.screenshots   = "https://raw.githubusercontent.com/tamanyan/UnlimitedScrollView/master/images/demo.gif"
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.author        = { "Taketo Yoshida" => "tamanyan.sss@gmail.com" }
  s.source        = { :git => "https://github.com/tamanyan/UnlimitedScrollView.git", :tag => "#{s.version}" }
  s.source_files  = "UnlimitedScrollView/UnlimitedScrollView/*.{h,swift}"
	s.platform     = :ios, '8.0'
	s.requires_arc = true
end
