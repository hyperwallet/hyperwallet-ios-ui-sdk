Pod::Spec.new do |spec|
    spec.name                  = 'HyperwalletUISDK'
    spec.version               = '1.0.0-beta01'
    spec.summary               = 'Hyperwallet UI SDK for iOS to integrate with Hyperwallet Platform'
    spec.homepage              = 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk'
    spec.license               = { :type => 'MIT', :file => 'LICENSE' }
    spec.author                = { 'Hyperwallet Systems Inc' => 'devsupport@hyperwallet.com' }
    spec.platform              = :ios
    spec.ios.deployment_target = '10.0'
    spec.source                = { :git => 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk.git', :tag => "#{spec.version}"}
    spec.source_files          = 'Sources/**/*.{swift,h,strings,xib}'
    spec.requires_arc          = true
    spec.swift_version         = '4.2'
    spec.resources             = ['Sources/**/*.xcassets', 'Sources/**/*.ttf']

    spec.dependency 'HyperwalletSDK', '1.0.0-beta01'

    spec.test_spec 'Tests' do |test_spec|
        test_spec.source_files = 'Tests/**/*.swift'
        test_spec.resources = 'Tests/**/*.json'
        test_spec.dependency 'Hippolyte', '0.6.0'
    end

    spec.test_spec 'UITests' do |uitest_spec|
        uitest_spec.requires_app_host = true
        uitest_spec.source_files = 'UITests/**/*.swift'
        uitest_spec.resources = 'UITests/**/*.json'
        uitest_spec.dependency 'Swifter', '1.4.6'
    end
end
