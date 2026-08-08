# FPGA_Board

A compact USB-powered FPGA development board built around a **Lattice iCE40 UltraPlus**, with an on-board FT232H USB flasher, SPI flash boot memory, and a 2×24 pin I/O header. Designed from scratch in KiCad 10.

---

## Key Features

- **FPGA** - Lattice iCE40 UltraPlus `ICE40UP5K-SG48ITR` (QFN-48, 7×7mm, 0.5mm pitch)
  - 5280 LUTs, 1.2V core
  - On-die RGB LED drive currents (RGB0/RGB1/RGB2)
- **On-board USB flasher** - FT232H (LQFP-48) with 93LC56BT config EEPROM and 12 test points
- **SPI flash** - W25Q128JVS 16MB boot memory (SOIC-8)
- **USB-C** - USB 2.0 receptacle with USBLC6-2SC6 ESD protection
- **Power** - 5V USB input, TLV757 LDOs for 1.2V / 2.5V / 3.3V, 74AUC2G240 level translators
- **Clocking** - Seiko Epson SG-210STF 12MHz oscillator buffered through 74AUC2G240
- **I/O** - 2×24 (2.54mm) pin header breakout of IOB/IOT pins, RGB + green status LEDs, reset button
- **Boot modes** - SPI flash master mode, or TinyFPGA BX-compatible bootloader mode via strap resistors
- **4-layer, 50×70mm PCB** with rounded corners

---

## Why I made it

The iCE40 UltraPlus packs a serious amount of logic into a tiny QFN-48 package, and the open-source Yosys/nextpnr/iceStorm toolchain makes it a great FPGA to build around. I wanted a small, self-contained board that could be programmed over USB without extra hardware — so it carries its own FT232H-based flasher and SPI flash for configuration, and exposes the FPGA's I/O on standard 2.54mm headers.

---

## Power Architecture

```
USB VBUS (5V)
    │
    ├── FB3 (ferrite) ───► 5V rail
    │                        │
    │                        ├── TLV75712 ───► 1.2V (FPGA core VCC)
    │                        │
    │                        ├── TLV75725 ───► 2.5V (VPP / VCCIO)
    │                        │
    │                        └── TLV75733 ───► 3.3V (VCCIO, FT232H, flash, sensors)
    │
    └── USBLC6-2SC6 ESD protection
```

All three LDOs are TLV757 SOT-23-5 parts fed from the USB 5V rail. 74AUC2G240 buffers translate between the 3.3V and 1.2V domains on the FPGA control/clock paths. The FT232H and flash run from 3.3V.

---

## Schematic Organization

The design is split into hierarchical KiCad schematic sheets:

| Sheet    | File                    | Description                                    | Main Components                          |
| -------- | ----------------------- | ---------------------------------------------- | ---------------------------------------- |
| Root     | FPGA_Board.kicad_sch    | Hierarchical connections and system overview   | Sub-sheet hierarchy                       |
| USB      | usb.kicad_sch           | USB-C input                                    | USB-C receptacle, USBLC6, CC resistors   |
| Power    | power.kicad_sch         | Voltage regulation                             | TLV75712/25/33, 74AUC2G240               |
| FPGA     | fpga.kicad_sch          | Main FPGA, flash, LEDs, reset                  | ICE40UP5K, W25Q128, RGB LED, status LED  |
| Clock    | clock.kicad_sch         | System clock                                   | SG-210STF 12MHz, 74AUC2G240              |
| Config   | config.kicad_sch        | Boot-mode selection straps                     | R16–R18 0Ω resistors                     |
| Flasher  | flasher.kicad_sch       | USB programming bridge                        | FT232H, 93LC56BT, test points            |
| Headers  | headers.kicad_sch       | I/O breakout                                   | 2×24 pin header                          |

---

## Boot Modes

Configuration source is selected with 0-ohm strap resistors (see `config.kicad_sch`):

- **SPI flash (default):** the FPGA boots directly from the on-board W25Q128 SPI flash in master SPI mode.
- **TinyFPGA BX mode:** for USB-uploaded bitstreams. Requires the flash to hold the TinyFPGA bootloader; the FT232H is switched onto the FPGA's SPI pins by moving the strap resistors.

See the notes on `tinyfpga.kicad_sch` for the exact strap changes.

---

## PCB Design

The PCB is a 2-layer, 1.6mm board measuring approximately 50×70mm with rounded corners.

- 2 copper layers: F.Cu / B.Cu
- Standard 0.2mm track / 0.5mm via rules, 2.54mm header pitch
- QFN-48 FPGA with exposed pad, decoupling kept close to the power pins
- USB differential pair and oscillator traces kept short and direct

---

## Bill of Materials

| Ref       | Part               | Qty | Package   | Description                         |
| --------- | ------------------ | --- | --------- | ----------------------------------- |
| U6        | ICE40UP5K-SG48ITR  | 1   | QFN-48    | iCE40 UltraPlus FPGA, 5280 LUTs     |
| U1        | FT232H             | 1   | LQFP-48   | USB-to-SPI/JTAG flasher             |
| U9        | 93LC56BT-I/OT      | 1   | SOIC-8    | FT232H config EEPROM                |
| U7        | W25Q128JVS         | 1   | SOIC-8    | 16MB SPI boot flash                 |
| U2        | USBLC6-2SC6        | 1   | SOT-23-6  | USB ESD protection                  |
| U3        | TLV75712PDBV       | 1   | SOT-23-5  | 1.2V LDO (FPGA core)                |
| U4        | TLV75725PDBV       | 1   | SOT-23-5  | 2.5V LDO                            |
| U5        | TLV75733PDBV       | 1   | SOT-23-5  | 3.3V LDO                            |
| U8        | 74AUC2G240         | 2   | —         | Dual level translator / clock buffer|
| Y2        | SG-210STF 12MHz    | 1   | 2.5×2.0mm | System oscillator                   |
| J1        | USB-C receptacle   | 1   | USB 2.0   | Power and programming input         |
| J3        | 2×24 pin header    | 1   | 2.54mm    | I/O breakout                        |
| SW1       | Push button        | 1   | —         | FPGA reset                          |
| D1        | Green LED          | 1   | 0603      | Status LED                          |
| D2        | LED_ARGB           | 1   | —         | RGB status LED                      |
| FB1–FB3   | BLM18HE152SN1D     | 3   | 0603      | Ferrite beads, power filtering      |
| C1–C22 etc| 0.1uF              | 22  | 0603      | Decoupling                          |
| C3–C34    | 10uF               | 12  | 0603      | Bulk decoupling                     |
| R1–R4     | 5.1k               | 4   | 0603      | USB-C CC pull-downs                 |
| R5,R8,R9,R11–R13 | 10k     | 6   | 0603      | Pull-ups / FT232H config            |
| R7        | 1k                 | 1   | 0603      | LED / bias                          |
| R14       | 2.2k               | 1   | 0603      | FT232H                             |
| R15       | 12k                | 1   | 0603      | FT232H                             |
| R16–R21   | 0Ω                 | 7   | 0603      | Boot-mode straps, series links      |
| R22       | 100Ω               | 1   | 0603      | Series resistor                     |
| TP1–TP12  | Test points        | 12  | 1.0×1.0mm | Probe points                        |

*Full BOM generated from the schematic; supplier part numbers TBD.*

---

## Firmware / Toolchain

The iCE40 family uses the open-source FPGA flow:

- Synthesis: [Yosys](https://github.com/YosysHQ/yosys)
- Place & route: [nextpnr](https://github.com/YosysHQ/nextpnr)
- Bitstream + programming: [Project IceStorm](https://github.com/YosysHQ/icestorm) (`icepack`, `iceprog`)
- The FT232H can be driven via its SPI/MPSSE interface (e.g. `iceprog` with an FT232H adapter) for direct flash writes.

No firmware is required — the board is purely FPGA + boot memory.

---

## Images

*Screenshots to be added — PCB layout and schematic renders pending.*

---

## Project Status

- [x] System architecture
- [x] Schematic design
- [x] PCB layout
- [ ] Manufacturing files / DRC sign-off
- [ ] BOM sourcing
- [ ] Board fab + bring-up

---

*KiCad project files live in [kicad/](kicad/).*
