docs:
		@mkdir -p TempJson
		sourcekitten doc --module-name Transfer > TempJson/Transfer.json
		sourcekitten doc --module-name UserRepository > TempJson/UserRepository.json
		sourcekitten doc --module-name TransferRepository > TempJson/TransferRepository.json
		sourcekitten doc --module-name TransferMethodRepository > TempJson/TransferMethodRepository.json
		sourcekitten doc --module-name TransferMethod > TempJson/TransferMethod.json
		sourcekitten doc --module-name Common > TempJson/Common.json
		sourcekitten doc --module-name ReceiptRepository > TempJson/ReceiptRepository.json
		sourcekitten doc --module-name Receipt > TempJson/Receipt.json
		@jazzy \
					--build-tool-arguments CODE_SIGN_IDENTITY=,CODE_SIGNING_REQUIRED=NO,CODE_SIGNING_ALLOWED=NO,POC_C-MVVM-RX
					--author Hyperwallet Systems Inc \
					--author_url https://www.hyperwallet.com/ \
					--github_url https://github.com/hyperwallet/hyperwallet-ios-ui-sdk \
					--module HyperwalletUISDK \
					--module-version 0.0.1 \
					--hide-documentation-coverage \
					--readme README.md \
					--skip-undocumented \
					--use-safe-filenames \
					--min-acl public \
					--clean \
					--title HyperwalletUISDK \
					--sourcekitten-sourcefile TempJson/Transfer.json,TempJson/UserRepository.json,TempJson/TransferRepository.json,TempJson/TransferMethodRepository.json,TempJson/TransferMethod.json,TempJson/Common.json,TempJson/ReceiptRepository.json,TempJson/Receipt.json \
					--no-hide-documentation-coverage \
					--theme fullwidth \
					--output ./docs \
					--documentation=./*.md
		@rm -rf ./build
		@rm -rf TempJson
