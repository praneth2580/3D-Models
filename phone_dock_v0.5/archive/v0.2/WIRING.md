# Power and USB data interface

## Functional block diagram

```text
Meteor 12 V battery / ignition-switched feed
        |
        +-- Fuse near source
        |
        +-- Reverse-polarity + transient protection
        |
        +-- Automotive-rated 12 V -> 5 V regulator
        |       (current limit set to connector rating)
        |
        +-- USB host / charging interface
        |
        +-- VBUS switch controlled by DOCK_DETECT
                |
                +-- Keyed blind-mate cartridge in handlebar receiver
                        ||  2 mm draw-in stroke when key is turned
                +-- Matching cartridge in rear shoe
                        |
                        +-- Short shielded USB 2.0 pigtail
                                |
                                +-- IP-rated cable gland through phone case
                                        |
                                        +-- Phone's USB-C / Micro-USB connector
```

## Four-wire USB 2.0 map

| Pin | Net | Routing notes |
|---|---|---|
| 1 | VBUS +5 V | Current-limited, switched only after dock lock is detected |
| 2 | D− | Route with D+ as a matched differential pair |
| 3 | D+ | Route with D− as a matched differential pair |
| 4 | GND | Low-impedance return; maintain a continuous reference |
| Shell | Shield | Follow the connector manufacturer's grounding/shielding instructions |
| Auxiliary | DOCK_DETECT | Optional fifth contact or sealed microswitch; not a USB signal pin |

For USB 2.0 high-speed operation, use a manufactured cable/connector assembly designed for USB 2.0. Keep D+ and D− together, shielded and impedance-controlled (nominal 90 Ω differential). Avoid long untwisted pigtails, stubs and improvised solder joints in the data pair.

## Power path requirements

- Use an ignition-switched feed so the dock cannot drain the battery while parked.
- Put the fuse close to the battery/source.
- Use reverse-polarity and automotive transient protection ahead of the DC-DC converter.
- Use an automotive-rated converter with regulated 5 V output and a current limit no higher than the connector's rating.
- Do not assume a factory USB charging socket provides USB data. Treat it as power-only unless data-host functionality is verified.
- Do not assume that a 5 V converter is a USB host. The bike-side source must contain or connect to a USB host if the phone is to enumerate as a USB device.

## Dock sequencing

1. The phone cradle slides into the receiver while the electrical cartridges remain separated by the 2 mm pre-seat gap.
2. The keyed draw-cam engages the metal striker and pulls the cradle inward approximately 2 mm.
3. The cartridges mate axially. The dock-detect contact/switch enables VBUS only after full seating and lock engagement.
4. To remove the cradle, unlock first. The draw-cam releases the 2 mm stroke and separates the connector halves before the rails slide out.
5. Fit a sealed dust/water cap to the exposed connector on the receiver whenever the phone case is removed.

The 2 mm stroke and pocket dimensions are CAD placeholders. Choose the blind-mate connector first, then update the pockets, guides and cam stroke from its drawing. The connector must support USB 2.0 data, the required charging current, repeated mating and the actual axial alignment tolerance. A generic pogo-pin block is not a validated substitute for a USB 2.0 connector.

## USB role and charging test

Before making the harness permanent, test the exact phone with the chosen host and cable:

- Does the phone enumerate as a USB device?
- Can it transfer files or expose the intended data interface while charging?
- Does the phone reject the host/charging arrangement or limit current?
- Does the phone maintain the link while the connector is gently moved?
- Does the phone reconnect cleanly after repeated dock/undock cycles?

USB-C role and charging behaviour depends on the phone, cable and host implementation. A plain 5 V feed is not enough to guarantee simultaneous charging and data.
