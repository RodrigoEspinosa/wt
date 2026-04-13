PREFIX ?= /usr/local

install:
	install -d $(PREFIX)/bin
	install -m 755 bin/wt $(PREFIX)/bin/wt

install-man:
	install -d $(PREFIX)/share/man/man1
	install -m 644 doc/wt.1 $(PREFIX)/share/man/man1/wt.1

uninstall:
	rm -f $(PREFIX)/bin/wt
	rm -f $(PREFIX)/share/man/man1/wt.1

.PHONY: install install-man uninstall
