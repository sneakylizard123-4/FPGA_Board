# Build flow: yosys -> nextpnr-ice40 -> icepack -> iceprog
# Targets the ICE40UP5K-SG48 on the FPGA_Board.

FREQ    = 12
DEVICE  = up5k
PACKAGE = sg48
PCF     = constraints/rainbow.pcf
SRCS    = rtl/rainbow.v

TOP     = rainbow
TARGET  = $(TOP).bin

all: $(TARGET)

$(TOP).json: $(SRCS)
	yosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP) -json $@"

$(TOP).asc: $(TOP).json $(PCF)
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --json $< --pcf $(PCF) \
		--freq $(FREQ) --asc $@

$(TARGET): $(TOP).asc
	icepack $< $@

# Program the flash with the bitstream.
prog: $(TARGET)
	iceprog $<

clean:
	rm -f $(TOP).json $(TOP).asc $(TARGET)

.PHONY: all prog clean
