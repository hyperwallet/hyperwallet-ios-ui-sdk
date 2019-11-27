docs:
	@jazzy \
        --min-acl public \
		--podspec HyperwalletUISDK.podspec \
        --no-hide-documentation-coverage \
        --theme fullwidth \
        --output ./docs \
        --documentation=./*.md
	@rm -rf ./build
