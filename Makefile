REPORTER = dot

test:
	@NODE_ENV=test ./node_modules/.bin/mocha -b \
	--compilers coffee:coffee-script \
	--reporter $(REPORTER)

.PHONY: test 