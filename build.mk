#!/usr/bin/make -f
# -*- makefile -*-

include include.mk

####################################################################################################
# TARGETS
####################################################################################################
.PHONY: all build build-pkg build-src-pkg clean install purge remove upload

all: clean build

build: build-src-pkg build-pkg

build-pkg: $(PKG_DEB_FILE)

$(PKG_DEB_FILE):
	debuild -b

build-src-pkg: $(PKG_SRC_CHANGES_FILE)

$(PKG_SRC_CHANGES_FILE):
	debuild -S -sa

clean:
	debclean
	rm -f "$(PKG_DSC_FILE)" "$(PKG_ORIG_FILE)" "$(PKG_SRC_BUILD_FILE)" "$(PKG_SRC_CHANGES_FILE)" "$(PKG_BUILD_FILE)" "$(PKG_CHANGES_FILE)" "$(PKG_DEB_FILE)"

install: $(PKG_DEB_FILE)
	$(eval $(call assert_is_superuser,$(MAKE_TARGET)))
	dpkg -i "$(PKG_DEB_FILE)"

purge:
	$(eval $(call assert_is_superuser,$(MAKE_TARGET)))
	$(if $(shell $(call get_package_selection)),apt-get -y "$(MAKE_TARGET)" "$(PKG_NAME)")

remove:
	$(eval $(call assert_is_superuser,$(MAKE_TARGET)))
	$(if $(shell $(call get_package_selection)),apt-get -y "$(MAKE_TARGET)" "$(PKG_NAME)")

upload: $(PKG_SRC_CHANGES_FILE)
	dput "ppa:$(PPA_USER)/$(PPA_NAME)" "$(PKG_SRC_CHANGES_FILE)"
