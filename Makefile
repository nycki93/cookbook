# targets

all: site/index.html site/style.css

#rules

site/index.html: src/index.md
	mkdir -p site
	pandoc -s --css=style.css -o site/index.html src/index.md

site/style.css: src/style.css
	mkdir -p site
	cp src/style.css site/style.css
