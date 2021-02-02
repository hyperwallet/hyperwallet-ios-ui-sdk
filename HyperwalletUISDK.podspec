Pod::Spec.new do |spec|
    spec.name                  = 'HyperwalletUISDK'
    spec.version               = '1.0.0-beta11'
    spec.summary               = 'Hyperwallet UI SDK for iOS to integrate with Hyperwallet Platform'
    spec.homepage              = 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk'
    spec.license               = { :type => 'MIT', :file => 'LICENSE' }
    spec.author                = { 'Hyperwallet Systems Inc' => 'devsupport@hyperwallet.com' }
    spec.platform              = :ios
    spec.ios.deployment_target = '10.0'
    spec.source                = { :git => 'https://github.com/hyperwallet/hyperwallet-ios-ui-sdk.git', :tag => "#{spec.version}"}
    spec.requires_arc          = true
    spec.swift_version         = '5.0'
    spec.dependency 'HyperwalletSDK', '1.0.0-beta11'

    spec.default_subspec = 'TransferMethod', 'Receipt', 'Transfer'

    spec.subspec "Common" do |common|
        common.resources = ['Common/Sources/Resources/*', 'Common/**/*.xib', 'Common/**/*.strings']
        common.source_files  = "Common/Sources/**/*.{swift,h}"
        common.dependency 'Insights', '1.0.0-beta04'
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
        receipt.dependency "HyperwalletUISDK/ReceiptRepository"
        receipt.dependency "HyperwalletUISDK/TransferMethodRepository"
    end

    spec.subspec "Transfer" do |transfer|
        transfer.source_files = "Transfer/Sources/**/*.{swift,h}"
        transfer.dependency "HyperwalletUISDK/Common"
        transfer.dependency "HyperwalletUISDK/UserRepository"
        transfer.dependency "HyperwalletUISDK/TransferRepository"
        transfer.dependency "HyperwalletUISDK/TransferMethodRepository"
    end
end
