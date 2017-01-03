include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AntennaGIFDL
AntennaGIFDL_FILES = Tweak.xm MBProgressHUD.m
AntennaGIFDL_FRAMEWORKS = Photos AssetsLibrary UIKit CoreGraphics QuartzCore
AntennaGIFDL_CFLAGS = -fobjc-arc 
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 amrc"
