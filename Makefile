SHELL=/bin/bash

build:
	swift build

release:
	swift build -c release
	
test:
	swift test --parallel

test-with-coverage:
	swift test --parallel --enable-code-coverage

clean:
	rm -rf .build

check:
	./scripts/run-checks.sh

format:
	./scripts/run-swift-format.sh --fix

doc:
	swift package --allow-writing-to-directory ./docs \
    generate-documentation --target FeatherSpecHummingbird \
    --include-extended-types \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path feather-spec-hummingbird \
	--output-path ./docs
	
preview:
	swift package --disable-sandbox preview-documentation --target FeatherSpecHummingbird
