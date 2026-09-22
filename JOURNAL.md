---
title: "FPGA Board"
author: sneak
description: "iCE40 UltraPlus FPGA development board with on-board FT232H flasher and SPI flash boot"
created_at: "2026-08-07T00:00:00Z"
---

# August 7: project start

## What I did

- started the fpga board project
- picked the ice40 up5k as the fpga
- decided on a devboard layout with headers breaking out the io instead of a bare module

## Why

- wanted a fpga to experiment with, but without a bga/lga footprint i could never hand solder
- the whole icestorm toolchain is open source (yosys + nextpnr + icepack), no proprietary ide
- 5280 luts, built in rgb drive pins, and a qfn-48 package i can actually solder

## Screenshots

![image](images/schematic/01-root.png)

**Total time spent: 3 hours**

---

# August 7: tinyfpga boot mode

## What I did

- added config sheet
- added tinyfpga features
- added the config sheet with the strap resistors that pick the boot source - on-board spi flash, or direct load over the flasher
- super simple sheet with just 3 resistors

## Why

- the tinyfpga is the most well known ice40 board and lots of tutorials use it, wanted my board to be able to act like one
- second boot mode just in case

## Screenshots

![config](images/schematic/06-config.png)

**Total time spent: 3 hours**

---

# August 8: schematic - usb and power

## What I did

- started the usb and power sheets
- added the usb-c with an esd clamp on the data lines
- three rails (1.2v, 2.5v, 3.3v), each from its own ldo stepping down from usb 5v
- ferrite beads on each rail to keep noise out
- beefed up the copper so the board can handle the current

## Why

- the whole board is powered off the usb-c
- the ice40 needs three separate voltages
- esd clamp so a bad cable or a zap cant kill the fpga
- ldos because we dont need that much power

## Screenshots

![usb](images/schematic/02-usb.png)
![power](images/schematic/03-power.png)

**Total time spent: 4 hours**

---

# August 8: schematic - fpga core

## What I did

- started the iCE40 sheet, the main fpga
- added decoupling caps on the power pins and the reset button on creset
- wired the rgb led to the up5k's rgb pins (39, 40, 41)
- added a green cdone led to show config status
- added spi flash

## Why

- the support stuff the datasheet wants
- the rgb pins are open-drain active-low, so they need a common-anode led
- cdone led so i can see at a glance whether the bitstream actually loaded
- spi flash for boot

## Screenshots

![fpga](images/schematic/04-fpga.png)

**Total time spent: 5 hours**

---

# August 9: schematic - clock, flasher, headers

## What I did

- clock sheet: 12mhz buffered oscillator
- flasher sheet: ft232h with its own eeprom to store the mpsse config
- broke the io out on two 2x12 headers with pullups on the flash cs and sclk signals

## Why

- clock deliberately boring so nothing can break
- 6 parts in clock sheet
- ft232h lets the board program itself over usb without an external programmer, the eeprom setup was the confusing part and ate most of the day
- so many pins to route on the ft232h, most of them went to test pads
- spi has di and do but we combine them into one
- headers left and right of the fpga so we can hopefully make shields soon if the project works

## Screenshots

![clock](images/schematic/05-clock.png)
![flasher](images/schematic/07-flasher.png)
![headers](images/schematic/08-headers.png)

**Total time spent: 6 hours**

---

# August 10: schematic review

## What I did

- reviewed the schematic and cleaned up unnecessary stuff
- removed some strap resistors that were included twice
- tidied up the net labels and made the whole thing presentable

## Why

- getting it clean before sending it out for external feedback
- schematic looked a bit messy

## Screenshots

![root schematic](images/schematic/01-root.png)

**Total time spent: 2 hours**

---

# August 11: pcb start

## What I did

- started the pcb, 50x70mm with m3 mounting holes 5mm from the edges
- usb-c on the bottom 50mm edge, headers to the left and right of the fpga
- fpga center-top with the ft232h below it
- started the via fanout to get the qfn signals out

## Why

- headers on both sides so shields can slot in
- usb on bottom middle, like my other boards

## Screenshots

![pcb](images/pcb-editor.png)

**Total time spent: 3 hours**

---

# August 12: firmware - rainbow proof of life

## What I did

- asked a friend to help with the verilog, never written an fpga design before
- got the icestorm flow running (yosys -> nextpnr -> icepack)
- simple rainbow demo that cycles the rgb led
- timing passes at 12mhz with plenty of headroom

## Why

- proof of life before spending money on boards, cheapest way to find out the toolchain works
- rainbow might be one of the easiest tests, cos i dont need external hardware

## Screenshots

![rainbow](images/4776-00.mp4)

**Total time spent: 2 hours**

---

# August 13: production files and fab order

## What I did

- generated the drill files for jlcpcb
- 50x70 4-layer 1.6mm board with rounded corners in purple
- used via in pad on the fpga to save space

## Why

- jlcpcb for cheap fab
- via in pad saves space (and i will regret it later)

## Screenshots

![board render](images/board-render.png)

**Total time spent: 1 hour**

---

# August 13: schematic review - external feedback

## What I did

- sent the schematic out for review
- fixed r3/r4 (usb data resistors): 5.1k -> 22
- added the missing decoupling caps on a couple of parts
- added 10k pullups on flash cs and sclk (r23/r24)
- updated the bom with lcsc part numbers

## Why

- r3/r4 were 5.1k by accident
- power sequencing delay: fine for now, becomes an issue with bigger fpgas
- 10k cs pullups to prevent accidental chip selection

## Screenshots

![editor](images/pcb-editor.png)

**Total time spent: 3 hours**

---

# August 25: through-hole vias out of pads

## What I did

- finally came back to the via in pad problem
- swapped the fpga footprint to one with a smaller exposed pad, 5.6x5.6 down to 3.5x3.5
- shouldnt affect fpga performance too much
- re-fanned the fpga with the vias moved out of the pad and into the pad ring

## Why

- jlcpcb charges extra for via in pad and it's a pain for assembly
- smaller exposed pad means the vias can live in the pad ring instead of through the pad
- found the footprint thanks to an instagram reel rabbit hole
- cleaner traces = less clutter

## Screenshots

![pcb editor](images/pcb-editor.png)

**Total time spent: 4 hours**