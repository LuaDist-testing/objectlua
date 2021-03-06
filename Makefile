PROJECT := objectlua
VERSION := $(shell cat 'WhatsNew.txt' | grep "What's new in version" | sed -e 's/[^0-9\.]*//g')

DISTDIR := $(PROJECT)-$(VERSION)
DISTFILE    := $(DISTDIR).tar.gz
FILES   := $(shell find ./* -maxdepth 0 '(' -path '*.svn*' -o -path './$(PROJECT)*' ')' -prune -o -print)

all: dist distcheck

test: test-clean
	cp -r src/$(PROJECT) test/$(PROJECT)
	cd test && lua TestObjectLua.lua
	make test-clean

test-clean:
	rm -rf test/$(PROJECT)

dist: dist-clean test
	@echo "Distribution temp directory: $(DISTDIR)"
	@echo "Distribution file: $(DISTFILE)"
	@echo "Version: $(VERSION)"
	mkdir $(DISTDIR)
	cp -r $(FILES) $(DISTDIR)
	tar --exclude '.svn*' --exclude '*Trait*' --exclude '*Mixin*' -cvzf $(DISTFILE) $(DISTDIR)/*
	rm -rf $(DISTDIR)

dist-clean:
	rm -rf $(PROJECT)-*.tar.gz

distcheck: $(DISTFILE) distcheck-clean
	mkdir -p tmp
	cd tmp && tar -xzf ../$(DISTFILE)
	cd tmp/$(DISTDIR) && make test
	make distcheck-clean

distcheck-clean:
	rm -rf tmp

clean: test-clean dist-clean distcheck-clean

tag:
	svn copy . https://objectlua.googlecode.com/svn/tags/$(VERSION) -m '$(VERSION) version tag'
