# SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD       := $(shell pwd)

CONFIG_RTW88_CORE=m
CONFIG_RTW88_USB=m
CONFIG_RTW88_8822B=y
CONFIG_RTW88_8822C=y
ccflags-y += -DDEBUG
ccflags-y += -DCONFIG_RTW88_DEBUG
ccflags-y += -DCONFIG_RTW88_DEBUGFS
ifeq ($(CONFIG_RTW88_8822B), y)
ccflags-y += -DCONFIG_RTW88_8822B
endif
ifeq ($(CONFIG_RTW88_8822C), y)
ccflags-y += -DCONFIG_RTW88_8822C
endif



########### section below is for upstream kernel ###########

obj-$(CONFIG_RTW88_CORE)	+= rtw88.o
rtw88-y += main.o \
	   mac80211.o \
	   util.o \
	   debug.o \
	   tx.o \
	   rx.o \
	   mac.o \
	   phy.o \
	   coex.o \
	   efuse.o \
	   fw.o \
	   ps.o \
	   sec.o \
	   bf.o \
	   wow.o \
	   regd.o

rtw88-$(CONFIG_RTW88_8822B)	+= rtw8822b.o rtw8822b_table.o
rtw88-$(CONFIG_RTW88_8822C)	+= rtw8822c.o rtw8822c_table.o

obj-$(CONFIG_RTW88_USB)		+= rtwusb.o
rtwusb-objs			:= usb.o

########### section above is for upstream kernel ###########

SUBARCH := $(shell uname -m | sed -e s/i.86/i386/)
ARCH ?= $(SUBARCH)

all:
	$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C $(KERNELDIR) M=$(PWD)

strip:
	$(CROSS_COMPILE)strip $(MODULE_NAME).ko --strip-unneeded

install:
	#mkdir /lib/firmware/rtw88
	cp fw/* /lib/firmware/rtw88/
	#cp fw/rtw8822b_fw.bin /lib/firmware/rtw88/
	#cp fw/rtw8822c_fw.bin /lib/firmware/rtw88/
	#cp fw/rtw8822c_wow_fw.bin /lib/firmware/rtw88/
	#install -p -m 644 $(MODULE_NAME).ko $(MODDESTDIR)
	cp rtw88.ko /lib/modules/`uname -r`/kernel/drivers/net/wireless/realtek/rtw88
	cp rtwusb.ko /lib/modules/`uname -r`/kernel/drivers/net/wireless/realtek/rtw88
	/sbin/depmod -a ${KVER}

uninstall:
	rm -f $(MODDESTDIR)/$(MODULE_NAME).ko
	/sbin/depmod -a ${KVER}

cscope:
	find ./ -name "*.[ch]" > cscope.files
	cscope -Rbq -i cscope.files
	ctags -R --exclude=.git

.PHONY: clean

clean:
	rm -f *.o .*.d *.a *.ko .*.cmd *.mod* *.order *.symvers *.tmp_versions
