# https://www.embecosm.com/resources/tool-chain-downloads/#riscv-stable
#CROSS_COMPILE ?= riscv32-unknown-elf-

# Toolchain from https://nucleisys.com/download.php
#CROSS_COMPILE ?= riscv-nuclei-elf-

# Toolchain from https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack
CROSS_COMPILE ?= riscv-none-elf-

CH32_FAMILY = ch32v30x
SDK_DIR = hw/mcu/wch/ch32v307
SDK_SRC_DIR = $(SDK_DIR)/EVT/EXAM/SRC

include $(TOP)/$(BOARD_PATH)/board.mk
CPU_CORE ?= rv32imac-ilp32

# default to use high speed port, unless specified in board.mk or command line
SPEED ?= high

CFLAGS += \
	-flto \
	-msmall-data-limit=8 \
	-mno-save-restore \
	-fmessage-length=0 \
	-fsigned-char \
	-DCFG_TUSB_MCU=OPT_MCU_CH32V307 \

ifeq ($(SPEED),high)
  CFLAGS += -DBOARD_TUD_MAX_SPEED=OPT_MODE_HIGH_SPEED
  $(info "Using USBHS driver for HighSpeed mode")
else
  CFLAGS += -DBOARD_TUD_MAX_SPEED=OPT_MODE_FULL_SPEED
  $(info "Using USBFS driver for FullSpeed mode")
endif

LDFLAGS_GCC += \
	-nostdlib -nostartfiles \
  --specs=nosys.specs --specs=nano.specs \

SRC_C += \
	src/portable/wch/dcd_ch32_usbhs.c \
	src/portable/wch/dcd_ch32_usbfs.c \
	$(SDK_SRC_DIR)/Core/core_riscv.c \
	$(SDK_SRC_DIR)/Peripheral/src/${CH32_FAMILY}_gpio.c \
	$(SDK_SRC_DIR)/Peripheral/src/${CH32_FAMILY}_misc.c \
	$(SDK_SRC_DIR)/Peripheral/src/${CH32_FAMILY}_rcc.c \
	$(SDK_SRC_DIR)/Peripheral/src/${CH32_FAMILY}_usart.c

SRC_S += \
	$(SDK_SRC_DIR)/Startup/startup_${CH32_FAMILY}_D8C.S

INC += \
	$(TOP)/$(BOARD_PATH) \
	$(TOP)/$(SDK_SRC_DIR)/Peripheral/inc

# For freeRTOS port source
FREERTOS_PORTABLE_SRC = $(FREERTOS_PORTABLE_PATH)/RISC-V

OPENOCD_WCH_OPTION=-f $(TOP)/$(FAMILY_PATH)/wch-riscv.cfg
flash: flash-openocd-wch
