# FPGA_Board firmware (ICE40UP5K)

Open-source iceStorm flow: `yosys` -> `nextpnr-ice40` -> `icepack` -> `iceprog`.

## Proof-of-life: RGB rainbow

`rtl/rainbow.v` cycles the on-board common-anode RGB LED through the color
wheel. The hue advances 25x/second, so one lap takes 10 seconds.

## Pin map

| Signal | FPGA pin | Net           | Note                          |
|--------|----------|---------------|-------------------------------|
| clk_12m| 20       | IOB_25b_G3    | 12 MHz clock                  |
| rgb_r  | 39       | RGB0          | open-drain, active low        |
| rgb_g  | 40       | RGB1          | open-drain, active low        |
| rgb_b  | 41       | RGB2          | open-drain, active low        |

The RGB LED (D1) is common-anode to 3.3 V, so its cathodes are driven
active-low directly by the FPGA. The green LED (D2) is wired to `CDONE`
(config-done indicator), not a user GPIO. SW1 pulls `CRESET` (pin 8) low.

## Build

```sh
make
```

## Program flash (iceprog)

```sh
make prog
```

`iceprog` uses the FT2232H via the SPI header (J3.2-5: FPGA_SO/FPGA_SI/
FT_SCK/FT_CS). After programming, toggle the FT_CS/MODE pins or press
SW1/cycle power to reconfigure from the W25Q128.
