Pod::Spec.new do |s|
    s.name                  = 'HyperwalletUISDK1'
    s.version               = '1.0.0-beta03'
    s.summary               = 'Hyperwallet UI SDK for iOS to integrate with Hyperwallet Platform'
    s.homepage              = 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Hyperwallet Systems Inc' => 'devsupport@hyperwallet.com' }
    s.platform              = :ios
    s.ios.deployment_target = '10.0'
    s.source                = { :git => 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk.git', :branch => "task/HW-52892-Modularization-for-hyperwalletUISDK"}
    s.requires_arc          = true
    s.swift_version         = '4.2'
    s.dependency 'HyperwalletSDK', '1.0.0-beta02'

    s.default_subspec = 'TransferMethod', 'Receipt'

    s.subspec "Common" do |common|
        common.resources = ['Common/**/*.xcassets', 'Common/**/*.ttf', 'Common/**/*.xib', 'Common/**/*.strings']
        common.source_files  = "Common/**/*.{swift,h}"
    end

    s.subspec "TransferMethodRepository" do |transferMethodRepository|
        transferMethodRepository.source_files = "TransferMethodRepository/Sources/**/*.{swift,h}"
    end

    s.subspec "ReceiptRepository" do |receiptRepository|
        receiptRepository.source_files = "ReceiptRepository/Sources/**/*.{swift,h}"
    end

    s.subspec "UserRepository" do |userRepository|
        userRepository.source_files = "UserRepository/Sources/**/*.{swift,h}"
    end

    s.subspec "TransferMethod" do |transferMethod|
        transferMethod.source_files = "TransferMethod/Sources/**/*.{swift,h}"
        transferMethod.dependency "Common"
        transferMethod.dependency "UserRepository"
        transferMethod.dependency "TransferMethodRepository"
    end

    s.subspec "Receipt" do |receipt|
        receipt.source_files = "Receipt/Sources/**/*.{swift,h}"
        receipt.dependency 'Common'
        receipt.dependency 'ReceiptRepository'
    end

    s.test_spec 'Tests' do |ts|
        ts.source_files = '/*/Tests/**/*.swift'
        ts.resources = '/*/Tests/**/*.json'
        ts.dependency 'Hippolyte', '0.6.0'
    end

    s.test_spec 'UITests' do |ts|
        ts.requires_app_host = true
        ts.source_files = 'UITests/**/*.swift'
        ts.resources = 'UITests/**/*.json'
        ts.dependency 'Swifter', '1.4.6'
    end
end
