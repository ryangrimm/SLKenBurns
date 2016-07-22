Pod::Spec.new do |s|
  s.name     = 'SLKenBurnsView'
  s.version  = '0.1'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'Takes images from either an array or delegate callbacks to create a Ken Burns effect on them.'
  s.framework = 'QuartzCore'
  s.homepage = 'https://github.com/ryangrimm/SLKenBurns'
  s.author   = { 'Ryan Grimm' => 'ryan@swelllinesllc.com' }
  s.source   = { :git => 'https://github.com/ryangrimm/SLKenBurns.git', :tag => '0.1' }
  s.platform = :ios
  s.ios.deployment_target = "6.0"
  s.source_files = 'KenBurns/*.{h,m}'
  s.requires_arc = true
end
