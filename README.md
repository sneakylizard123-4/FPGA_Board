# FPGA_Board

A 50x75mm USB-powered FPGA development board built around the **Lattice iCE40 UltraPlus**, with an on-board FT232H USB programmer, SPI flash memory, and two 2×24 pin I/O headers.

---

## Key Features

- **FPGA** - Lattice iCE40 UltraPlus `ICE40UP5K-SG48ITR` (QFN-48, 7×7mm)
- **USB programmer** - FT232H (LQFP-48) 
- **SPI flash** - W25Q128JVS 16MB boot memory (SOIC-8)
- **USB-C** - USB 2.0 receptacle with USBLC6-2SC6 ESD protection
- **Power** - 5V USB input, TLV757 LDOs for 1.2V / 2.5V / 3.3V, and 74AUC2G240 level translators
- **Clocking** - 12MHz oscillator
- **I/O** - 2×24 (2.54mm) pin header breakout of IOB/IOT pins, RGB + green status LEDs, reset button
- **Boot modes** - SPI flash master mode, or TinyFPGA bootloader mode via strap resistors
- **4-layer, 50×70mm PCB** with rounded corners and m3 mounting holes

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

All three LDOs are fed from the USB 5V rail. buffers translate between the 3.3V and 1.2V domains on the FPGA control/clock paths.

---

## Schematic Organization

The design is split into hierarchical KiCad schematic sheets:

| Sheet    | File                    | Description                                    | Main Components                          |
| -------- | ----------------------- | ---------------------------------------------- | ---------------------------------------- |
| Root     | FPGA_Board.kicad_sch    | Hierarchical connections and system overview   | Main sheet                               |
| USB      | usb.kicad_sch           | USB-C input                                    | USB-C receptacle, USBLC6, CC resistors   |
| Power    | power.kicad_sch         | Power regulation                               | TLV75712/25/33                           |
| FPGA     | fpga.kicad_sch          | Main FPGA, flash, LEDs, reset                  | ICE40UP5K, W25Q128, RGB LED, status LED  |
| Clock    | clock.kicad_sch         | System clock                                   | SG-210STF 12MHz, 74AUC2G240              |
| Config   | config.kicad_sch        | Boot-mode selection straps                     | R16–R18 0Ω resistors                     |
| Flasher  | flasher.kicad_sch       | USB programming bridge                         | FT232H, 93LC56BT, test points            |
| Headers  | headers.kicad_sch       | I/O breakout headers                           | 2×24 pin headers                         |

---

## Boot Modes

Configuration source is selected with 0-ohm strap resistors (see `config.kicad_sch`):

- **SPI flash (default):** the FPGA boots directly from the on-board W25Q128 SPI flash.
- **TinyFPGA BX mode:** for USB-uploaded bitstreams. Requires the flash to hold the TinyFPGA bootloader; the FT232H is switched onto the FPGA's SPI pins by moving the strap resistors.

See the notes on `tinyfpga.kicad_sch` for the exact strap changes.

---

## PCB Design

- 4 copper layers
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
| R5,R8,R9,R11–R13 | 10k         | 6   | 0603      | Pull-ups                            |
| R7        | 1k                 | 1   | 0603      | LED / bias                          |
| R14       | 2.2k               | 1   | 0603      | FT232H                              |
| R15       | 12k                | 1   | 0603      | FT232H                              |
| R16–R21   | 0Ω                 | 7   | 0603      | Boot-mode straps                    |
| R22       | 100Ω               | 1   | 0603      | Series resistor                     |
| TP1–TP12  | Test points        | 12  | 1.0×1.0mm | Probe points                        |

---

## Toolchain

The iCE40 family uses the open-source FPGA flow:

- Synthesis: [Yosys](https://github.com/YosysHQ/yosys)
- Place & route: [nextpnr](https://github.com/YosysHQ/nextpnr)
- Bitstream + programming: [Project IceStorm](https://github.com/YosysHQ/icestorm) (`iceprog`)

---

## Images

### PCB Layout

![PCB editor](images/pcb-editor.png)

### Schematic

![Root](images/schematic/01-root.png)
![USB](images/schematic/02-usb.png)
![Power](images/schematic/03-power.png)
![FPGA](images/schematic/04-fpga.png)
![Clock](images/schematic/05-clock.png)
![Config](images/schematic/06-config.png)
![Flasher](images/schematic/07-flasher.png)
![Headers](images/schematic/08-headers.png)

### 3D Render

![Board render](images/board-render.png)
<video src="kicad/Renders/260808_111839/FPGA_Board.mp4" controls></video>

---

## Fabrication

Order spec (JLCPCB):

| Item | Spec |
|------|------|
| Thickness | 1.6 mm |
| Surface finish | Lead-free HASL |
| Stencil | Top side, 100 × 150 mm no-framework |
| Cost | PCB $20, stencil $18 |


---

## Project Status

- [x] System architecture
- [x] Schematic design
- [x] PCB layout
- [x] Manufacturing files / DRC sign-off
- [x] BOM sourcing
- [ ] Board fab + bring-up

---

*KiCad project files live in [kicad/](kicad/).*

## Credits 

- Adafruit for neopixel gif