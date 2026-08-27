TARGET := iphone:clang:16.5:14.0
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

FLEX_ROOT := upstream

SOURCES := $(shell find $(FLEX_ROOT)/Classes \( -name '*.c' -o -name '*.m' -o -name '*.mm' \))
IMPORTS := $(addprefix -I,$(shell find $(FLEX_ROOT)/Classes -type d))

TWEAK_NAME := libbhFLEX

# Linux Theos toolchains can omit Apple's private __isOSVersionAtLeast helper
# from the SDK stubs. Reuse NeoFreeBird's compatibility implementation so FLEX
# can link independently as its own dylib.
$(TWEAK_NAME)_FILES := $(SOURCES) ../../src/Core/OSVersionShim.m
$(TWEAK_NAME)_FRAMEWORKS := CoreGraphics UIKit ImageIO QuartzCore
$(TWEAK_NAME)_LIBRARIES := sqlite3 z
$(TWEAK_NAME)_CFLAGS := -fobjc-arc -w $(IMPORTS)
$(TWEAK_NAME)_CCFLAGS := -std=gnu++11

include $(THEOS_MAKE_PATH)/tweak.mk
