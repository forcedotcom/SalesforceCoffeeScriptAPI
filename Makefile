REPORTER = dot

test:
	@NODE_ENV=test ./node_modules/.bin/mocha -b \
	--compilers coffee:coffee-script \
	--reporter $(REPORTER)

docs:
	./node_modules/.bin/docco *.coffee

push:
	git push origin master

.PHONY: test 