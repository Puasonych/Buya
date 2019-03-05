Pod::Spec.new do |spec|
  spec.name               = 'Buya'
  spec.version            = '0.0.4'
  spec.summary            = 'Network abstraction framework'
  spec.homepage           = 'https://github.com/Puasonych/Buya'
  spec.license            = { :type => 'MIT' }
  spec.authors            = { 'Erik Basargin' => 'basargin.erik@gmail.com', 'Kirill Saltykov' => 'kirill.salti@gmail.com' }
  spec.social_media_url   = 'https://twitter.com/Puasonych'
  spec.source             = { :git => 'https://github.com/Puasonych/Buya.git', :tag => '0.0.4' }
  spec.swift_version      = '4.2'

  spec.ios.deployment_target  = '8.0'

  spec.default_subspec = 'Core'

  spec.subspec 'Core' do |subspec|
    subspec.source_files = 'Buya/**/*.swift'
    subspec.framework = 'Foundation'
    subspec.dependency 'RxSwift', '~> 4.4'
    subspec.dependency 'RxCocoa', '~> 4.4'
  end
end
