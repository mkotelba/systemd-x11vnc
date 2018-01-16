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
export to_absolute_path

####################################################################################################
# FUNCTIONS: PACKAGE
####################################################################################################
define get_package_name
dpkg-parsechangelog -c 0 -S "Source"
endef
export get_package_name

define get_package_version
dpkg-parsechangelog -c 0 -S "Version"
endef
export get_package_version

define get_package_architecture
sed -nr '/^Architecture:[[:space:]]+[^$$]+$$/ s!^Architecture:[[:space:]]+([^$$]+)$$!\1!p' <"$(DEBIAN_CONTROL_FILE)"
endef
export get_package_architecture

define get_package_architecture_host
dpkg-architecture -qDEB_HOST_ARCH
endef
export get_package_architecture_host

define get_package_selection
dpkg --get-selections | egrep '^$(PKG_NAME)[[:space:]]+install$$'
endef
export get_package_selection

####################################################################################################
# FUNCTIONS: PERMISSIONS
####################################################################################################
define assert_is_superuser
ifneq ("$(shell id -u)","0")
$$(error Must be root to execute the $(1) Make target)
endif
endef
export assert_is_superuser

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
export SRC_MAIN_DEBIAN_DIR=$(SRC_MAIN_DIR)/debian

####################################################################################################
# VARIABLES: SOURCE TEST DIRECTORIES
####################################################################################################
export SRC_TEST_DIR=$(SRC_DIR)/test
export SRC_TEST_DEBIAN_DIR=$(SRC_TEST_DIR)/debian

####################################################################################################
# VARIABLES: BUILD DIRECTORIES
####################################################################################################
export BUILD_DIR=$(DEBIAN_DIR)/build
export BUILD_MAIN_DIR=$(BUILD_DIR)/main
export BUILD_MAIN_DEBIAN_DIR=$(BUILD_MAIN_DIR)/debian

####################################################################################################
# VARIABLES: BUILD TEST DIRECTORIES
####################################################################################################
export BUILD_TEST_DIR=$(BUILD_DIR)/test
export BUILD_TEST_DEBIAN_DIR=$(BUILD_TEST_DIR)/debian

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
export PKG_BUILD_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION)_$(PKG_ARCH_HOST).build
export PKG_CHANGES_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION)_$(PKG_ARCH_HOST).changes
export PKG_DEB_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION)_$(PKG_ARCH).deb
export PKG_DSC_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION).dsc
export PKG_ORIG_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION).tar.xz
export PKG_SRC_BUILD_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION)_source.build
export PKG_SRC_CHANGES_FILE=$(OUT_DIR)/$(PKG_NAME)_$(PKG_VERSION)_source.changes

####################################################################################################
# VARIABLES: UPLOAD
####################################################################################################
export PPA_USER=michal.kotelba
export PPA_NAME=ppa
