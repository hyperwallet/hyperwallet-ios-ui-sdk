Pod::Spec.new do |spec|
    spec.name                  = 'HyperwalletUISDK'
    spec.version               = '1.0.0-beta03'
    spec.summary               = 'Hyperwallet UI SDK for iOS to integrate with Hyperwallet Platform'
    spec.homepage              = 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk'
    spec.license               = { :type => 'MIT', :file => 'LICENSE' }
    spec.author                = { 'Hyperwallet Systems Inc' => 'devsupport@hyperwallet.com' }
    spec.platform              = :ios
    spec.ios.deployment_target = '10.0'
    spec.source                = { :git => 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk.git', :branch => "development"}
    spec.requires_arc          = true
    spec.swift_version         = '5.0'
    spec.dependency 'HyperwalletSDK', '1.0.0-beta04'

    spec.default_subspec = 'TransferMethod', 'Receipt', 'Transfer'

    spec.subspec "Common" do |common|
        common.resources = ['Common/**/*.xcassets', 'Common/**/*.ttf', 'Common/**/*.xib', 'Common/**/*.strings']
        common.source_files  = "Common/Sources/**/*.{swift,h}"
        common.dependency "HyperwalletUISDK/UserRepository"
    end

    spec.subspec "TransferMethodRepository" do |transferMethodRepository|
        transferMethodRepository.source_files = "TransferMethodRepository/Sources/**/*.{swift,h}"
    end

    spec.subspec "ReceiptRepository" do |receiptRepository|
        receiptRepository.source_files = "ReceiptRepository/Sources/**/*.{swift,h}"
    end

    spec.subspec "TransferRepository" do |transferRepository|
        transferRepository.source_files = "TransferRepository/Sources/**/*.{swift,h}"
    end

    spec.subspec "UserRepository" do |userRepository|
        userRepository.source_files = "UserRepository/Sources/**/*.{swift,h}"
    end

    spec.subspec "TransferMethod" do |transferMethod|
        transferMethod.source_files = "TransferMethod/Sources/**/*.{swift,h}"
        transferMethod.dependency "HyperwalletUISDK/Common"
        transferMethod.dependency "HyperwalletUISDK/UserRepository"
        transferMethod.dependency "HyperwalletUISDK/TransferMethodRepository"
    end

    spec.subspec "Receipt" do |receipt|
        receipt.source_files = "Receipt/Sources/**/*.{swift,h}"
        receipt.dependency "HyperwalletUISDK/Common"
        receipt.dependency 'HyperwalletUISDK/ReceiptRepository'
    end

    spec.subspec "Transfer" do |transfer|
        transfer.source_files = "Transfer/Sources/**/*.{swift,h}"
        transfer.dependency 'HyperwalletUISDK/Common'
        transfer.dependency 'HyperwalletUISDK/UserRepository'
        transfer.dependency 'HyperwalletUISDK/TransferRepository'
        transfer.dependency 'HyperwalletUISDK/TransferMethodRepository'
    end

    spec.test_spec 'Tests' do |ts|
        ts.source_files = '**/Tests/**/*.swift'
        ts.resources = '**/Tests/**/*.json'
        ts.dependency 'Hippolyte', '0.6.0'
    end

    spec.test_spec 'UITests' do |ts|
        ts.requires_app_host = true
        ts.source_files = 'UITests/**/*.swift'
        ts.resources = 'UITests/**/*.json'
        ts.dependency 'Swifter', '1.4.6'
    end
end
