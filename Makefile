
TESTS = test/*.js
REPORTER = dot

#
# Browser Build
#

all: chai.js

chai.js: node_modules lib/*
	@printf "==> [Browser :: build]\n"
	@./node_modules/.bin/browserify --bare --outfile chai.js --standalone chai --entry index.js

#
# Node Module
#

node_modules: package.json
	@npm install

#
# Tests
#

test: test-node test-phantom

test-node: node_modules
	@printf "==> [Test :: Node.js]\n"
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--require ./test/bootstrap \
		--reporter $(REPORTER) \
		$(TESTS)

test-cov: node_modules
	@NODE_ENV=test ./node_modules/.bin/istanbul cover ./node_modules/.bin/_mocha -- \
		--require ./test/bootstrap \
		$(TESTS) \

test-phantom: chai.js
	@printf "==> [Test :: Karma (PhantomJS)]\n"
	@./node_modules/karma/bin/karma start \
		--single-run --browsers PhantomJS

test-firefox: chai.js
	@printf "==> [Test :: Karma (Firefox)]\n"
	@./node_modules/karma/bin/karma start \
		--browsers Firefox

test-sauce: chai.js
	@printf "==> [Test :: Karma (Sauce)]\n"
	@CHAI_TEST_ENV=sauce ./node_modules/karma/bin/karma start \
		--single-run

test-travisci:
	@echo TRAVIS_JOB_ID $(TRAVIS_JOB_ID)
	@make test-cov
	@make test-sauce

#
# Clean up
#

clean: clean-node clean-browser clean-cov

clean-node:
	@rm -rf node_modules

clean-browser:
	@rm -f chai.js

clean-cov:
	@rm -rf coverage

#
# Instructions
#

.PHONY: all
.PHONY: test test-all test-node test-phantom test-sauce test-cov
.PHONY: clean clean-node clean-browser clean-cov
