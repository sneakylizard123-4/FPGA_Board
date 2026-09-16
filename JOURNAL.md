---
title: "FPGA Board"
author: sneak
description: "iCE40 UltraPlus FPGA development board with on-board FT232H flasher and SPI flash boot"
created_at: "2026-08-07T00:00:00Z"
---

# August 7: project start

started the fpga board project.
wanted a fpga to experiment with, but without the bga/lga foorprint

![image](images/schematic/01-root.png)

**Total time spent: 3 hours**

# August 7: tinyfpga boot mode

added tinyfpga features
i dont know too much about it
still would be nice to add

![config](images/schematic/06-config.png)

**Total time spent: 3 hours**

# August 8: schematic - usb and power

started usb and power sheet
entire board will be powered off the usb-c
need to make sure copper is thick enough to handle the power

![usb](images/schematic/02-usb.png)
![power](images/schematic/03-power.png)

**Total time spent: 4 hours**

# August 8: schematic - fpga core

started the iCE40 sheet, the main fpga
added the capacitors and the required components that the fpga needs

![fpga](images/schematic/04-fpga.png)

**Total time spent: 5 hours**

# August 9: schematic - clock, flasher, headers

started clock sheet, it generates clock (in the name)
it is deliberately boring to prevent it breaking
![clock](images/schematic/05-clock.png)

using ft232h as the flasher, and it also has its own flash memory
ft232h was confusing as it needs specific resistors and capacitors, also the flash
![flasher](images/schematic/07-flasher.png)

using two 2x24 connectors breaking out the io.
hopefully we can make shields or something soon
![headers](images/schematic/08-headers.png)

**Total time spent: 6 hours**

# August 10: schematic review

reviewed schematic and cleaned up unnecessary stuff
some strap resistors were included twice so they were removed
![root schematic](images/schematic/01-root.png)

**Total time spent: 2 hours**

# August 11: pcb start

started pcb, standard 50x75mm size with m3 mounting holes 5mm from edges

added usb-c on the bottom 50mm side
then added headers to the left and right of the fpga.
fpga is in the center-top, with the frt232h below it.

started the via fanout, need to get them signals go through
![pcb](images/pcb-editor.png)

**Total time spent: 3 hours**

# August 12: firmware - rainbow proof of life

asked a friend to help with verilog
using yosis and friends
![rainbow](images/4776-00.mp4)

**Total time spent: 2 hours**

# August 13: production files and fab order

generated drill files for JLCPCB
used via in pad to save space (this will be changed)

50x75mm 4-layer pcb, 1.6mm thick
![board render](images/board-render.png)

**Total time spent: 1 hour**

# August 13: schematic review - external feedback

sent schematics for review
issues:
- r3/r4 (usb data line resistors): originally 5.1k by accident, will switch to 22
- missing 100nf caps on some parts
- pullups on flash cs and sclk (r23/r24): 10k
- power sequencing delay for fpga, reviewer said it should be too much of an issue but will become an issue with bigger fpgas

also updated bom
![editor](images/pcb-editor.png)

**Total time spent: 3 hours**

# August 25: through-hole vias out of pads

made the fpga's exposed pad smaller so we dont need via-in-pad
sswapped to a footprint with a smaller exposed pad, 5.6x5.6 down to 3.5x3.5 (thank you instagram reels).
![pcb editor](images/pcb-editor.png)

**Total time spent: 4 hours**

