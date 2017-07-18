Version=0.1

PREFIX = /usr/local
SYSCONFDIR = /etc

SYSCONF = \
	data/artools.conf

BIN_BASE = \
	bin/mkchroot \
	bin/basestrap \
	bin/artools-chroot \
	bin/fstabgen \
	bin/signfile \
	bin/chroot-run

LIBS_BASE = \
	lib/util.sh \
	lib/util-msg.sh \
	lib/util-mount.sh \
	lib/util-chroot.sh \
	lib/util-fstab.sh

SHARED_BASE = \
	data/pacman-default.conf \
	data/pacman-multilib.conf

LIST_PKG = \
	$(wildcard data/pkg.list.d/*.list)

ARCH_CONF = \
	$(wildcard data/make.conf.d/*.conf)

LIST_IMPORT = \
	$(wildcard data/import.list.d/*.list)

BIN_PKG = \
	bin/checkpkg \
	bin/lddd \
	bin/finddeps \
	bin/find-libdeps \
	bin/signpkgs \
	bin/mkchrootpkg \
	bin/buildpkg \
	bin/buildtree \
	bin/deploypkg

LIBS_PKG = \
	$(wildcard lib/util-pkg*.sh)

SHARED_PKG = \
	data/makepkg.conf

LIST_ISO = \
	$(wildcard data/iso.list.d/*.list)

BIN_ISO = \
	bin/buildiso \
	bin/deployiso

LIBS_ISO = \
	$(wildcard lib/util-iso*.sh)

SHARED_ISO = \
	data/mkinitcpio.conf \
	data/profile.conf.example

CPIOHOOKS = \
	$(wildcard initcpio/hooks/*)

CPIOINST = \
	$(wildcard initcpio/install/*)

CPIO = \
	initcpio/script/artix_shutdown

MAN_XML = \
	buildpkg.xml \
	buildtree.xml \
	buildiso.xml \
	deployiso.xml \
	deploypkg.xml \
	check-yaml.xml \
	artools.conf.xml \
	profile.conf.xml

BIN_YAML = \
	bin/check-yaml

LIBS_YAML = \
	$(wildcard lib/util-yaml*.sh) \
	lib/util-profile.sh

SHARED_YAML = \
	data/linux.preset

all: $(BIN_BASE) $(BIN_PKG) $(BIN_ISO) $(BIN_YAML) doc

edit = sed -e "s|@datadir[@]|$(DESTDIR)$(PREFIX)/share/artools|g" \
	-e "s|@sysconfdir[@]|$(DESTDIR)$(SYSCONFDIR)/artools|g" \
	-e "s|@libdir[@]|$(DESTDIR)$(PREFIX)/lib/artools|g" \
	-e "s|@version@|${Version}|"

%: %.in Makefile
	@echo "GEN $@"
	@$(RM) "$@"
	@m4 -P $@.in | $(edit) >$@
	@chmod a-w "$@"
	@chmod +x "$@"

doc:
	mkdir -p man
	$(foreach var,$(MAN_XML),xsltproc /usr/share/docbook2X/xslt/man/docbook.xsl docbook/$(var) | db2x_manxml --output-dir man ;)

clean:
	rm -f $(BIN_BASE) ${BIN_PKG} ${BIN_ISO}
	rm -rf man

install_base:
	install -dm0755 $(DESTDIR)$(SYSCONFDIR)/artools
	install -m0644 ${SYSCONF} $(DESTDIR)$(SYSCONFDIR)/artools

	install -dm0755 $(DESTDIR)$(PREFIX)/bin
	install -m0755 ${BIN_BASE} $(DESTDIR)$(PREFIX)/bin

	install -dm0755 $(DESTDIR)$(PREFIX)/lib/artools
	install -m0644 ${LIBS_BASE} $(DESTDIR)$(PREFIX)/lib/artools

	install -dm0755 $(DESTDIR)$(PREFIX)/share/artools
	install -m0644 ${SHARED_BASE} $(DESTDIR)$(PREFIX)/share/artools

install_pkg:
	install -dm0755 $(DESTDIR)$(SYSCONFDIR)/artools/pkg.list.d
	install -m0644 ${LIST_PKG} $(DESTDIR)$(SYSCONFDIR)/artools/pkg.list.d

	install -dm0755 $(DESTDIR)$(SYSCONFDIR)/artools/import.list.d
	install -m0644 ${LIST_IMPORT} $(DESTDIR)$(SYSCONFDIR)/artools/import.list.d

	install -dm0755 $(DESTDIR)$(SYSCONFDIR)/artools/make.conf.d
	install -m0644 ${ARCH_CONF} $(DESTDIR)$(SYSCONFDIR)/artools/make.conf.d

	install -dm0755 $(DESTDIR)$(PREFIX)/bin
	install -m0755 ${BIN_PKG} $(DESTDIR)$(PREFIX)/bin

	ln -sf find-libdeps $(DESTDIR)$(PREFIX)/bin/find-libprovides

	install -dm0755 $(DESTDIR)$(PREFIX)/lib/artools
	install -m0644 ${LIBS_PKG} $(DESTDIR)$(PREFIX)/lib/artools

	install -dm0755 $(DESTDIR)$(PREFIX)/share/artools
	install -m0644 ${SHARED_PKG} $(DESTDIR)$(PREFIX)/share/artools

	install -dm0755 $(DESTDIR)$(PREFIX)/share/man/man1
	gzip -c man/buildpkg.1 > $(DESTDIR)$(PREFIX)/share/man/man1/buildpkg.1.gz
	gzip -c man/buildtree.1 > $(DESTDIR)$(PREFIX)/share/man/man1/buildtree.1.gz

install_iso:
	install -dm0755 $(DESTDIR)$(SYSCONFDIR)/artools/iso.list.d
	install -m0644 ${LIST_ISO} $(DESTDIR)$(SYSCONFDIR)/artools/iso.list.d

	install -dm0755 $(DESTDIR)$(PREFIX)/bin
	install -m0755 ${BIN_ISO} $(DESTDIR)$(PREFIX)/bin

	install -dm0755 $(DESTDIR)$(PREFIX)/lib/artools
	install -m0644 ${LIBS_ISO} $(DESTDIR)$(PREFIX)/lib/artools

	install -dm0755 $(DESTDIR)$(SYSCONFDIR)/initcpio/hooks
	install -m0755 ${CPIOHOOKS} $(DESTDIR)$(SYSCONFDIR)/initcpio/hooks

	install -dm0755 $(DESTDIR)$(SYSCONFDIR)/initcpio/install
	install -m0755 ${CPIOINST} $(DESTDIR)$(SYSCONFDIR)/initcpio/install

	install -m0755 ${CPIO} $(DESTDIR)$(SYSCONFDIR)/initcpio


	install -dm0755 $(DESTDIR)$(PREFIX)/share/artools
	install -m0644 ${SHARED_ISO} $(DESTDIR)$(PREFIX)/share/artools

	install -dm0755 $(DESTDIR)$(PREFIX)/share/man/man1
	gzip -c man/buildiso.1 > $(DESTDIR)$(PREFIX)/share/man/man1/buildiso.1.gz
	gzip -c man/deployiso.1 > $(DESTDIR)$(PREFIX)/share/man/man1/deployiso.1.gz

	install -dm0755 $(DESTDIR)$(PREFIX)/share/man/man5
	gzip -c man/artools.conf.5 > $(DESTDIR)$(PREFIX)/share/man/man5/artools.conf.5.gz
	gzip -c man/profile.conf.5 > $(DESTDIR)$(PREFIX)/share/man/man5/profile.conf.5.gz

install_yaml:
	install -dm0755 $(DESTDIR)$(PREFIX)/bin
	install -m0755 ${BIN_YAML} $(DESTDIR)$(PREFIX)/bin

	install -dm0755 $(DESTDIR)$(PREFIX)/lib/artools
	install -m0644 ${LIBS_YAML} $(DESTDIR)$(PREFIX)/lib/artools

	install -dm0755 $(DESTDIR)$(PREFIX)/share/artools
	install -m0644 ${SHARED_YAML} $(DESTDIR)$(PREFIX)/share/artools

	install -dm0755 $(DESTDIR)$(PREFIX)/share/man/man1
	gzip -c man/check-yaml.1 > $(DESTDIR)$(PREFIX)/share/man/man1/check-yaml.1.gz

uninstall_base:
	for f in ${SYSCONF}; do rm -f $(DESTDIR)$(SYSCONFDIR)/artools/$$f; done
	for f in ${BIN_BASE}; do rm -f $(DESTDIR)$(PREFIX)/bin/$$f; done
	for f in ${SHARED_BASE}; do rm -f $(DESTDIR)$(PREFIX)/share/artools/$$f; done
	for f in ${LIBS_BASE}; do rm -f $(DESTDIR)$(PREFIX)/lib/artools/$$f; done

uninstall_pkg:
	for f in ${LIST_PKG}; do rm -f $(DESTDIR)$(SYSCONFDIR)/artools/pkg.list.d/$$f; done
	for f in ${LIST_IMPORT}; do rm -f $(DESTDIR)$(SYSCONFDIR)/artools/import.list.d/$$f; done
	for f in ${ARCH_CONF}; do rm -f $(DESTDIR)$(SYSCONFDIR)/artools/make.conf.d/$$f; done
	for f in ${BIN_PKG}; do rm -f $(DESTDIR)$(PREFIX)/bin/$$f; done
	rm -f $(DESTDIR)$(PREFIX)/bin/find-libprovides
	for f in ${SHARED_PKG}; do rm -f $(DESTDIR)$(PREFIX)/share/artools/$$f; done
	for f in ${LIBS_PKG}; do rm -f $(DESTDIR)$(PREFIX)/lib/artools/$$f; done
	rm -f $(DESTDIR)$(PREFIX)/share/man/man1/buildpkg.1.gz
	rm -f $(DESTDIR)$(PREFIX)/share/man/man1/buildtree.1.gz

uninstall_iso:
	for f in ${LIST_ISO}; do rm -f $(DESTDIR)$(SYSCONFDIR)/artools/iso.list.d/$$f; done
	for f in ${BIN_ISO}; do rm -f $(DESTDIR)$(PREFIX)/bin/$$f; done
	for f in ${SHARED_ISO}; do rm -f $(DESTDIR)$(PREFIX)/share/artools/$$f; done

	for f in ${LIBS_ISO}; do rm -f $(DESTDIR)$(PREFIX)/lib/artools/$$f; done
	for f in ${CPIOHOOKS}; do rm -f $(DESTDIR)$(SYSCONFDIR)/initcpio/hooks/$$f; done
	for f in ${CPIOINST}; do rm -f $(DESTDIR)$(SYSCONFDIR)/initcpio/install/$$f; done
	for f in ${CPIO}; do rm -f $(DESTDIR)$(SYSCONFDIR)/initcpio/$$f; done
	rm -f $(DESTDIR)$(PREFIX)/share/man/man1/buildiso.1.gz
	rm -f $(DESTDIR)$(PREFIX)/share/man/man1/deployiso.1.gz
	rm -f $(DESTDIR)$(PREFIX)/share/man/man5/artools.conf.5.gz
	rm -f $(DESTDIR)$(PREFIX)/share/man/man5/profile.conf.5.gz

uninstall_yaml:
	for f in ${BIN_YAML}; do rm -f $(DESTDIR)$(PREFIX)/bin/$$f; done
	for f in ${LIBS_YAML}; do rm -f $(DESTDIR)$(PREFIX)/lib/artools/$$f; done
	for f in ${SHARED_YAML}; do rm -f $(DESTDIR)$(PREFIX)/share/artools/$$f; done
	rm -f $(DESTDIR)$(PREFIX)/share/man/man1/check-yaml.1.gz

install: install_base install_pkg install_iso install_yaml

uninstall: uninstall_base uninstall_pkg uninstall_iso uninstall_yaml

dist:
	git archive --format=tar --prefix=artools-$(Version)/ $(Version) | gzip -9 > artools-$(Version).tar.gz
	gpg --detach-sign --use-agent artools-$(Version).tar.gz

.PHONY: all clean install uninstall dist