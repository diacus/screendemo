VERSION := 2021.04.0

PKG_ROOT := screendemo-$(VERSION)

PKG_DEB := $(PKG_ROOT)/DEBIAN
PKG_MAN := $(PKG_ROOT)/usr/share/man
PKG_BIN := $(PKG_ROOT)/usr/local/bin

default: debian-package

package-deb:
	@mkdir -p -m 755 $(PKG_DEB)
	install -m 600 MANIFEST -T $(PKG_DEB)/control

package-man: doc/screendemo.ronn
	@mkdir -p -m 755 $(PKG_MAN)/man1
	ronn -r doc/screendemo.ronn
	gzip doc/screendemo.1
	install -m 644 doc/screendemo.1.gz -T $(PKG_MAN)/man1/screendemo.1.gz

package-bin:
	@mkdir -p -m 755 $(PKG_BIN)
	install -m 555 src/screendemo.pl -T $(PKG_BIN)/screendemo

debian-package: package-deb package-man package-bin
	dpkg-deb --build screendemo-$(VERSION)
	$(RM) -r screendemo-$(VERSION)

clean:
	$(RM) -r screendemo-$(VERSION).deb $(PKG_ROOT)
	find doc -name '*.gz' -delete
