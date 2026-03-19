PREFIX ?= /usr/local

install:
	install -d $(PREFIX)/bin
	install -m 755 bin/wt $(PREFIX)/bin/wt

uninstall:
	rm -f $(PREFIX)/bin/wt

.PHONY: install uninstall
