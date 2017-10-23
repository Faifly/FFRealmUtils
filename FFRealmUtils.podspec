#
# Be sure to run `pod lib lint FFRealmUtils.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FFRealmUtils'
  s.version          = '1.1.1'
  s.summary          = 'Realm and Marshal tools'

  s.description      = <<-DESC
This library simplifies workflow with Realm and provides some helper methods for mapping via Marshal
                       DESC

  s.homepage         = 'https://github.com/Faifly/FFRealmUtils'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ArKalmykov' => 'ar.kalmykov@yahoo.com' }
  s.source           = { :git => 'https://github.com/Faifly/FFRealmUtils.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'FFRealmUtils/Classes/**/*'

  s.dependency 'Realm'
  s.dependency 'RealmSwift'
  s.dependency 'Marshal'
end
