TARGET := iphone:clang:latest:14.0
ARCHS = arm64
INSTALL_TARGET_PROCESSES = Among Us

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AmongUsMod

# Dobby is built by .github/workflows/build.yml into Dobby/lib.
AmongUsMod_FILES = ModMenu.mm EspLogic.cpp
AmongUsMod_CFLAGS = -fobjc-arc -fblocks -std=c++17 -I./Dobby/include
AmongUsMod_CCFLAGS = -fblocks -std=c++17 -I./Dobby/include
AmongUsMod_LDFLAGS = -L./Dobby/lib -ldobby
AmongUsMod_FRAMEWORKS = Foundation UIKit QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
