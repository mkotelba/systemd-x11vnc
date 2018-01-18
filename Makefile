#!/usr/bin/make -f
# -*- makefile -*-

####################################################################################################
# VARIABLES: SHELL
####################################################################################################
export SHELL=/bin/bash

####################################################################################################
# FUNCTIONS: PERMISSIONS
####################################################################################################
define assert_is_superuser
ifneq ("$(shell id -u)","0")
$$(error Must be root to execute the $(1) Make target)
endif
endef

####################################################################################################
# VARIABLES: PACKAGE
####################################################################################################
PKG_NAME=$(shell dpkg-parsechangelog -c 0 -S "Source")
PKG_VERSION=$(shell dpkg-parsechangelog -c 0 -S "Version")
PKG_ARCH=$(shell sed -nr '/^Architecture:[[:space:]]+[^$$]+$$/ s!^Architecture:[[:space:]]+([^$$]+)$$!\1!p' <"$(DEBIAN_CONTROL_FILE)")

####################################################################################################
# VARIABLES: DIRECTORIES
####################################################################################################
DEBIAN_DIR=debian
OUT_DIR=..

####################################################################################################
# VARIABLES: DEBIAN FILES
####################################################################################################
DEBIAN_CONTROL_FILE=$(DEBIAN_DIR)/control

####################################################################################################
# VARIABLES: PACKAGE FILES
####################################################################################################
PKG_BUILD_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION)_$(DEB_TARGET_ARCH).build
PKG_CHANGES_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION)_$(DEB_TARGET_ARCH).changes
PKG_DEB_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION)_$(PKG_ARCH).deb
PKG_DSC_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION).dsc
PKG_SRC_ARCHIVE_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION).tar.xz
PKG_SRC_BUILD_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION)_source.build
PKG_SRC_CHANGES_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION)_source.changes
PKG_SRC_PPA_UPLOAD_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION)_source.ppa.upload

####################################################################################################
# VARIABLES: UPLOAD
####################################################################################################
PPA_USER=michal.kotelba
PPA_NAME=ppa

####################################################################################################
# TARGETS
####################################################################################################
.PHONY: all apt-install apt-purge apt-remove build build-binary build-src clean clean-out upload

ifeq ($(MAKELEVEL),0)
all: clean-out build-src build-binary
else
all: build
endif

apt-install:
	$(eval $(call assert_is_superuser,$@))
	dpkg -i "$(PKG_DEB_FILE)"

apt-purge:
	$(eval $(call assert_is_superuser,$@))
	$(if $(shell $(call get_package_selection)),apt-get -y "purge" "$(PKG_NAME)")

apt-remove:
	$(eval $(call assert_is_superuser,$@))
	$(if $(shell $(call get_package_selection)),apt-get -y "remove" "$(PKG_NAME)")

build:

build-binary: $(PKG_DEB_FILE)

$(PKG_DEB_FILE):
	debuild -b

build-src: $(PKG_SRC_CHANGES_FILE)

$(PKG_SRC_CHANGES_FILE):
	debuild -S -sa

clean:

clean-out:
	debclean
	rm -f "$(PKG_DSC_FILE)" "$(PKG_SRC_ARCHIVE_FILE)" "$(PKG_SRC_BUILD_FILE)" "$(PKG_SRC_CHANGES_FILE)" "$(PKG_SRC_PPA_UPLOAD_FILE)" "$(PKG_BUILD_FILE)" \
		"$(PKG_CHANGES_FILE)" "$(PKG_DEB_FILE)"

upload:
	dput "ppa:$(PPA_USER)/$(PPA_NAME)" "$(PKG_SRC_CHANGES_FILE)"
