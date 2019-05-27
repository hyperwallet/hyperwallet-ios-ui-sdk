Pod::Spec.new do |s|
    s.name                  = 'HyperwalletUISDK'
    s.version               = '1.0.0-beta02'
    s.summary               = 'Hyperwallet UI SDK for iOS to integrate with Hyperwallet Platform'
    s.homepage              = 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Hyperwallet Systems Inc' => 'devsupport@hyperwallet.com' }
    s.platform              = :ios
    s.ios.deployment_target = '10.0'
    s.source                = { :git => 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk.git', :tag => "#{s.version}"}
    s.requires_arc          = true
    s.swift_version         = '4.2'
    s.resources             = ['HyperwalletCommon/**/*.xcassets', 'HyperwalletCommon/**/*.ttf']
    s.dependency 'HyperwalletSDK', '1.0.0-beta02'

    s.subspec "Common" do |s|
        s.resources = ['Common/**/*.xcassets', 'Common/**/*.ttf', 'Common/**/*.xib', 'Common/**/*.strings']
        s.source_files  = "Common/**/*.{swift,h}"
    end

    s.subspec "TransferMethod" do |s|
        s.source_files = "HyperwalletTransferMethod/**/*.{swift,h,xib}"
        s.dependency "HyperwalletUISDK/Common"
    end

    s.test_spec 'Tests' do |ts|
        ts.source_files = 'Tests/**/*.swift'
        ts.resources = 'Tests/**/*.json'
        ts.dependency 'Hippolyte', '0.6.0'
    end

    s.test_spec 'UITests' do |ts|
        ts.requires_app_host = true
        ts.source_files = 'UITests/**/*.swift'
        ts.resources = 'UITests/**/*.json'
        ts.dependency 'Swifter', '1.4.6'
    end
end
