#
# Be sure to run `pod lib lint NNCodeCoverage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NNCodeCoverage'
  s.version          = '1.0.0'
  s.summary          = 'iOS code coverage, supports OC and swift.'
  s.homepage         = 'https://github.com/YiHuaXie/NNCodeCoverage'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NeroXie' => 'xyh30902@163.com' }
  s.source           = { :git => 'https://github.com/YiHuaXie/NNCodeCoverage.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'NNCodeCoverage/Classes/**/*'
  s.module_map = 'NNCodeCoverage/module.modulemap'
  
  # s.resource_bundles = {
  #   'NNCodeCoverage' => ['NNCodeCoverage/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
