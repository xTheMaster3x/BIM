GO_EASY_ON_ME = 1
ARCHS = armv7 arm64
TARGET = iphone:clang:latest:latest
THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

TWEAK_NAME = Bim
Bim_FILES = Tweak.xm BingBongWebViewController.m
Bim_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSMS"
