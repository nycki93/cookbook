# targets

all: docs/index.html docs/style.css

#rules

docs/index.html: src/index.md docs/style.css
	mkdir -p docs
	pandoc \
		-o docs/index.html \
		--standalone \
		--table-of-contents \
		--section-divs \
		--resource-path docs \
		--css style.css \
		--no-highlight \
		--from markdown+emoji \
		src/index.md

docs/style.css: src/style.css
	mkdir -p docs
	cp src/style.css docs/style.css
