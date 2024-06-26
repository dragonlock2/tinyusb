# https://www.embecosm.com/resources/tool-chain-downloads/#riscv-stable
#CROSS_COMPILE ?= riscv32-unknown-elf-

# Toolchain from https://nucleisys.com/download.php
#CROSS_COMPILE ?= riscv-nuclei-elf-

# Toolchain from https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack
CROSS_COMPILE ?= riscv-none-elf-

CH32_FAMILY = ch32v20x
SDK_DIR = hw/mcu/wch/ch32v20x
SDK_SRC_DIR = $(SDK_DIR)/EVT/EXAM/SRC

include $(TOP)/$(BOARD_PATH)/board.mk
CPU_CORE ?= rv32imac-ilp32

CFLAGS += \
	-mcmodel=medany \
	-ffat-lto-objects \
	-flto \
	-DCH32V20x_${MCU_VARIANT} \
	-DCFG_TUSB_MCU=OPT_MCU_CH32V20X \
	-DBOARD_TUD_MAX_SPEED=OPT_MODE_FULL_SPEED \

LDFLAGS_GCC += \
	-nostdlib -nostartfiles \
	--specs=nosys.specs --specs=nano.specs \

LD_FILE = $(FAMILY_PATH)/linker/${CH32_FAMILY}.ld

SRC_C += \
	src/portable/wch/dcd_ch32_usbfs.c \
	$(SDK_SRC_DIR)/Core/core_riscv.c \
	$(SDK_SRC_DIR)/Peripheral/src/ch32v20x_gpio.c \
	$(SDK_SRC_DIR)/Peripheral/src/ch32v20x_misc.c \
	$(SDK_SRC_DIR)/Peripheral/src/ch32v20x_rcc.c \
	$(SDK_SRC_DIR)/Peripheral/src/ch32v20x_usart.c \

SRC_S += $(SDK_SRC_DIR)/Startup/startup_ch32v20x_${MCU_VARIANT}.S

INC += \
	$(TOP)/$(BOARD_PATH) \
	$(TOP)/$(SDK_SRC_DIR)/Peripheral/inc \

FREERTOS_PORTABLE_SRC = $(FREERTOS_PORTABLE_PATH)/RISC-V

OPENOCD_WCH_OPTION=-f $(TOP)/$(FAMILY_PATH)/wch-riscv.cfg
flash: flash-openocd-wch
