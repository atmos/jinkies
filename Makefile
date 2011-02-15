deps:
	@test `which coffee` || echo "You need to have CoffeeScript in your PATH.\nPlease install it using `brew install coffee-script` or `npm install coffee-script`."

build: deps
	@coffee -o lib src/
	@coffee -o spec spec/

install: deps
	@coffee -o lib src/
	@npm install

publish: deps
	@coffee -o lib src/
	@npm publish

test: build
	@vows spec/*_spec.js --spec

http: build
	@node lib/app.js

dev: deps
	@coffee -wc --bare -o lib src/

.PHONY: all
