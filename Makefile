BRANCH=`git rev-parse --abbrev-ref HEAD`
COMMIT=`git rev-parse --short HEAD`
MASTER_COMMIT=`git rev-parse --short HEAD~1`
GOLDFLAGS="-X main.branch $(BRANCH) -X main.commit $(COMMIT)"

default: build

race:
	@TEST_FREELIST_TYPE=hashmap go test -v -race -timeout 25m -tags simulate -short -test.run="TestSimulate_*"
	@echo "array freelist test"
	@TEST_FREELIST_TYPE=array go test -v -race -timeout 25m -tags simulate -short -test.run="TestSimulate_*"

# go get github.com/kisielk/errcheck
errcheck:
	@errcheck -ignorepkg=bytes -ignore=os:Remove github.com/ledgerwatch/bolt

test:
	@TEST_FREELIST_TYPE=hashmap go test -v -timeout 20m
	# Note: gets "program not an importable package" in out of path builds
	@TEST_FREELIST_TYPE=hashmap go test -v ./cmd/bolt
	@echo "array freelist test"
	@TEST_FREELIST_TYPE=array go test -v -timeout 20m
	# Note: gets "program not an importable package" in out of path builds
	@TEST_FREELIST_TYPE=array go test -v ./cmd/bolt

lint:
	golangci-lint run --new-from-rev=$(MASTER_COMMIT) ./...

lintci-deps:
	rm -f ./build/bin/golangci-lint
	curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b ./build/bin v1.27.0

.PHONY: fmt test
