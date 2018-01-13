#!/usr/bin/make -f
# -*- makefile -*-

####################################################################################################
# VARIABLES: SHELL
####################################################################################################
export SHELL=/bin/bash

####################################################################################################
# VARIABLES: MAKE
####################################################################################################
export MAKE_TARGET=$@

####################################################################################################
# FUNCTIONS: FILESYSTEM
####################################################################################################
define to_absolute_path
$(abspath $(shell pwd)/$(1))
endef

####################################################################################################
# FUNCTIONS: PACKAGE
####################################################################################################
define get_package_name
dpkg-parsechangelog -c 0 -S "Source"
endef

define get_package_version
dpkg-parsechangelog -c 0 -S "Version"
endef

define get_package_architecture
sed -nr '/^Architecture:[[:space:]]+[^$$]+$$/ s!^Architecture:[[:space:]]+([^$$]+)$$!\1!p' <"$(DEBIAN_CONTROL_FILE)"
endef

define get_package_architecture_host
dpkg-architecture -qDEB_HOST_ARCH
endef

define get_package_selection
dpkg --get-selections | egrep '^$(PKG_NAME)[[:space:]]+install$$'
endef

####################################################################################################
# FUNCTIONS: PERMISSIONS
####################################################################################################
define assert_is_superuser
ifneq ("$(shell id -u)","0")
$$(error Must be root to execute the $(1) Make target)
endif
endef

####################################################################################################
# VARIABLES: DIRECTORIES
####################################################################################################
export BASE_DIR=$(call to_absolute_path,.)
export DEBIAN_DIR=$(BASE_DIR)/debian
export OUT_DIR=$(call to_absolute_path,..)

####################################################################################################
# VARIABLES: SOURCE DIRECTORIES
####################################################################################################
export SRC_DIR=$(BASE_DIR)/src
export SRC_MAIN_DIR=$(SRC_DIR)/main
export SRC_DEBIAN_DIR=$(SRC_MAIN_DIR)/debian

####################################################################################################
# VARIABLES: TEST SOURCE DIRECTORIES
####################################################################################################
export TEST_SRC_DIR=$(SRC_DIR)/test
export TEST_SRC_DEBIAN_DIR=$(TEST_SRC_DIR)/debian

####################################################################################################
# VARIABLES: BUILD DIRECTORIES
####################################################################################################
export BUILD_DIR=$(DEBIAN_DIR)/build
export BUILD_MAIN_DIR=$(BUILD_DIR)/main
export BUILD_DEBIAN_DIR=$(BUILD_MAIN_DIR)/debian

####################################################################################################
# VARIABLES: TEST BUILD DIRECTORIES
####################################################################################################
export TEST_BUILD_DIR=$(BUILD_DIR)/test
export TEST_BUILD_DEBIAN_DIR=$(TEST_BUILD_DIR)/debian

####################################################################################################
# VARIABLES: PACKAGE
####################################################################################################
export PKG_NAME=$(shell $(call get_package_name))
export PKG_VERSION=$(shell $(call get_package_version))
export PKG_ARCH=$(shell $(call get_package_architecture))
export PKG_ARCH_HOST=$(shell $(call get_package_architecture_host))

####################################################################################################
# VARIABLES: DEBIAN FILES
####################################################################################################
export DEBIAN_CHANGELOG_FILE=$(DEBIAN_DIR)/changelog
export DEBIAN_CONTROL_FILE=$(DEBIAN_DIR)/control

####################################################################################################
# VARIABLES: PACKAGE FILES
####################################################################################################
export PKG_CHANGES_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION)_$(PKG_ARCH_HOST).changes
export PKG_DEB_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION)_$(PKG_ARCH).deb
export PKG_DSC_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION).dsc
export PKG_ORIG_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION).tar.xz
export PKG_SRC_CHANGES_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION)_source.changes

####################################################################################################
# VARIABLES: UPLOAD
####################################################################################################
export PPA_USER=michal.kotelba
export PPA_NAME=ppa

####################################################################################################
# TARGETS
####################################################################################################
.PHONY: all build build-src clean clean-src install purge remove upload

all: clean build

clean:
	dh_clean
	rm -f "$(PKG_CHANGES_FILE)" "$(PKG_DEB_FILE)"
	rm -fr "$(BUILD_DIR)"

clean-src:
	rm -f "$(PKG_DSC_FILE)" "$(PKG_ORIG_FILE)" "$(PKG_SRC_CHANGES_FILE)"

build: $(PKG_DSC_FILE) $(PKG_ORIG_FILE) $(PKG_CHANGES_FILE) $(PKG_DEB_FILE)

build-src: $(PKG_SRC_CHANGES_FILE)

$(PKG_CHANGES_FILE) $(PKG_DEB_FILE): $(PKG_DSC_FILE) $(PKG_ORIG_FILE)
	dpkg-buildpackage -g -nc -sa

$(PKG_DSC_FILE) $(PKG_ORIG_FILE) $(PKG_SRC_CHANGES_FILE):
	dpkg-buildpackage -nc -S -sa

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
