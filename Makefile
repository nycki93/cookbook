# targets

all: docs/index.html docs/style.css

#rules

docs/index.html: src/index.md
	mkdir -p docs
	pandoc -s --css=style.css -o docs/index.html src/index.md

docs/style.css: src/style.css
	mkdir -p docs
	cp src/style.css docs/style.css
