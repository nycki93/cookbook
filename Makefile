# targets

all: docs/index.html docs/style.css

#rules

docs/index.html: src/index.md src/nav.html
	mkdir -p docs
	pandoc \
		-o docs/index.html \
		--standalone \
		--table-of-contents \
		--section-divs \
		--css style.css \
		--no-highlight \
		--include-before-body src/nav.html \
		--from markdown+emoji \
		src/index.md

docs/style.css: src/style.css
	mkdir -p docs
	cp src/style.css docs/style.css
