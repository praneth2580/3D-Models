# Power and USB data path

## Block diagram

```text
Bike USB socket or 12 V -> 5 V USB supply (ignition-switched, fused)
        |
        |  USB-C lead (removable)
        v
        (or from a future "smart base" module: see the last section)
[DOCK]  waterproof panel-mount USB-C socket (lower rider-facing edge, beside the key)
        |   CC1, CC2 -> 5.1 kOhm to GND each (so a USB-C charger turns VBUS on)
        |
        +-- VBUS_IN -> USB power switch (current-limited, active-low enable) -> VBUS pin
        |                     ^
        |                     +-- DET pin (100 kOhm pull-up to VBUS_IN)
        +-- D+ / D- -> ESD protection array -> D+ / D- pins
        +-- GND -> GND pin
        |
        |   5-pin spring-loaded (pogo) block in the ledge face
        |   ~~~ case slides down onto the pins, then the cam lock is turned ~~~
        |   5-pad flat target board in the case bottom face
        v
[CASE]  pad board: DET pad tied to GND pad
        |   VBUS, D+, D-, GND -> 4 wires through the potted wire hole
        v
        cable runs in the raceway under the phone to the side USB-C bay
        right-angle USB-C plug (with 56 kOhm Rp, CC to VBUS) -> phone
```

## Contact pinout (looking at the ledge face, left to right)

| Pin | Net | Notes |
|---|---|---|
| 1 | DET | Case side: tied to GND. Dock side: pulled up, and enables VBUS when pulled low. |
| 2 | VBUS +5 V | Live only while docked. Choose pins rated for at least 2 A, or use two pins in parallel. |
| 3 | D+ | Keep paired with D−, with short, equal lengths. |
| 4 | D− | |
| 5 | GND | |

**Why DET sits next to VBUS:** if rain bridges the bare pins while the case is removed, DET is most likely to short to VBUS. That keeps it pulled **high**, so the power switch stays off. A bridge from DET to GND would need water across the whole row.

**Alignment:** the pads should be at least 2 mm wide and 3 mm tall, along the case thickness. That covers the rail play in X and Z. The pins and pads mate along the slide direction, so they press together without dragging sideways.

## Dock electronics (in the ledge cavity)

- **USB-C panel socket (SELECT).**
  - Use an IP67 panel-mount socket with a cap.
  - Fit a 5.1 kΩ resistor from CC1 to GND and another from CC2 to GND. Without them, a USB-C charger will not switch on 5 V.
  - A USB-A-to-C lead from a USB-A bike socket works either way.
- **USB power switch.**
  - Use any small high-side USB power switch IC with an active-low enable, a current limit of about 1.5–2 A, and reverse-current blocking.
  - DET goes to the enable pin with a 100 kΩ pull-up to VBUS_IN.
  - A P-MOSFET and a resistor also work, but give no current limit.
- **ESD protection:** a low-capacitance USB ESD diode array on D+/D−, because the pins are exposed.
- **Wiring:** keep D+/D− as a short twisted pair from the socket to the pin block. Pot or conformal-coat the board, and seal the lid with foam.

## Case side

The easiest way to build the case-side cable correctly:

1. Buy a good **USB-A to right-angle USB-C** cable.
2. Cut it about 6–8 cm from the C plug.
3. Solder its four wires (red VBUS, white D−, green D+, black GND, plus the shield to GND) to the pad board.

That kind of cable's C plug already contains the 56 kΩ pull-up the phone needs to treat the cable as a power source and charge from it. A bare USB-C plug board without it may not charge the phone at all.

Then:
- Tie the DET pad to the GND pad on the pad board.
- Pot the pad board into its pocket, and the wire hole into the USB bay, with epoxy. This is the only opening through the case wall, so seal it well.

## Data: what to expect

- With this cable arrangement the phone is always the USB **device**. Data only works if whatever plugs into the dock socket is a USB **host**, for example a small computer or head unit. Treat the bike's own USB socket as **power-only** unless you have proved otherwise.
- USB 2.0 over short pogo pins usually works at full speed, and often at high speed (480 Mbit/s), but this is not guaranteed. Test it with the actual pins before relying on it.

## Bring-up checklist

1. Bench-power the dock socket. The VBUS pin must read 0 V with the case removed.
2. Short DET to GND by hand. VBUS should switch on and the current limit should work.
3. Dock the case with the phone. Check that the phone charges, and check the charging current.
4. If you need data, connect a USB host to the dock socket and check the phone enumerates. Then wiggle the case and dock/undock 20 times.
5. Spray the empty dock with the case removed, then dry it and repeat steps 1–3.

## Future smart base (Arduino, speakers, ...)

The base plate is a separate module, so it can later become an electronics box. The cleanest way to connect it:

- **Power:**
  - The bike feeds the smart base.
  - The smart base feeds the dock's USB-C socket through a short USB-C lead routed through the Ø14 mm hole in the base.
  - The smart base can then switch the phone's charging off when it gets hot, using a temperature sensor and a load switch.
- **Audio:** the phone can reach the base's speakers over Bluetooth to an audio board. That avoids adding more pins to the dock connector.
- **Data:** if the smart base contains a USB **host** (for example a Raspberry Pi-class board, or a microcontroller with USB host support), it can talk to the phone over the same D+/D− path. A plain Arduino Uno/Nano cannot act as a USB host without an add-on.
- **Spare contacts:** if more signals are needed through the dock later, choose a pogo/target pair with more contacts now. Extra unused pins cost almost nothing, while changing the connector means reprinting the case and receiver.
