BRANCH=`git rev-parse --abbrev-ref HEAD`
COMMIT=`git rev-parse --short HEAD`
GOLDFLAGS="-X main.branch $(BRANCH) -X main.commit $(COMMIT)"

default: build

race:
	@TEST_FREELIST_TYPE=hashmap go test -v -race -timeout 25m -tags simulate -test.run="TestSimulate_(100op|1000op)"
	@echo "array freelist test"
	@TEST_FREELIST_TYPE=array go test -v -race -timeout 25m -tags simulate -test.run="TestSimulate_(100op|1000op)"

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


.PHONY: fmt test
