# Dial combination lock (demo)

A **fully mechanical** combination lock for the dock, with **one dial**, like a safe: no key and no power. The dial is numbered 0–9, and your code is **4, 5 or 6 digits**. It comes in its own lock cartridge, so it fits the same lock bay as the store-bought cam lock and the printed lock (`lock_type = "dial"`). The dock, the lock cover, the steel bolt and the strike are unchanged.

> **A demo / concept.** It is checked in CAD, but not printed or tested. A patient person can feel out the code of a printed dial lock, so treat it as a deterrent, and keep the store lock for the best security.

![The dial and the button on the side of the pod](images/dl_side.png)

![The cartridge lowered out of the lock bay](images/dl_exploded.png)

Watch it work in `video/lock_demo.mp4`: its third part shows the wheels cut in half, the fence, the latch and the button.

## Using it

- **To unlock:** dial the code like a safe. With the example code 3-7-1-9:
  1. turn **right** (clockwise) a few turns, and stop at **3**;
  2. turn **left**, past 7 once, and stop at **7** the second time;
  3. turn **right**, stop at **1**;
  4. turn **left**, stop at **9**.

  With the last digit, the **button pops out** and the bolt drops. Slide the case off.
- **The rule for any length:** for an N-digit code, turn right for the 1st digit, passing it N−1 times and stopping on the Nth. Then go left for the 2nd, passing it N−2 times. Keep alternating; for the last digit, turn straight to it. The index mark is the small triangle at the dial's left side.
- **To lock:**
  1. Dock the case.
  2. **Press the button in** and hold it. Its ramp lifts the bolt into the case.
  3. While holding it, **spin the dial a full turn or more**.
  4. Let go. The button stays in: locked.
- **While it's open,** the wheels are held at the code, so the dial only turns freely for less than a turn.

## How it works

- **Dial, spindle and drive cam:** the dial turns a spindle through a fixed tube in the face plate. At the spindle's rear end is the drive cam.
- **Wheels:** one per digit, turning freely on the tube.
  - Each wheel and the cam have small pins (**flies**) on their faces. Turning the dial, the cam picks up the first wheel after nearly a turn, that wheel picks up the next, and so on. That's why each digit needs one fewer turn than the one before, as on a safe.
  - Each wheel has one **notch** in its rim. Where the notch sits on the wheel sets that wheel's digit.
- **Fence:** a bar under the wheels, pushed up by a small spring.
  - When every notch is at the bottom (only with the right code), the fence rises 1.5 mm into them.
  - Its front end carries the **latch tooth**, which sits in a notch in the button's bar and holds the button in. Rising, it lets go.
- **Button:**
  - The button's spring pushes it out, and the lifter's spring pulls the bolt down.
  - Pressed in, the button's 40° ramp lifts the lifter's pin 7 mm, and with it the bolt.
  - Turning the dial then moves a wheel. The notch's sloped side pushes the fence down, and the tooth drops back into the button's notch.
- **The lifter** carries the same steel bolt, on the same arm as the store lock's yoke.
  - **Locked, its pin sits on the button bar's flat top.** Pushing the bolt down presses straight down on the bar, so it can't push the button out.

## Parts

STLs are in [`dial_lock/`](dial_lock/), made with the example code `[3, 7, 1, 9]`. Print your own wheels with your code.

| Part | File | Qty | How to print |
|---|---|---|---|
| Cartridge | `dl_cartridge.stl` | 1 | Standing on its bottom face, as it sits in the dock. It includes the fixed tube the wheels turn on. It replaces `lock_cartridge` |
| Wheels | `dl_wheel_1.stl` … `dl_wheel_4.stl` (or `dl_wheels.stl`) | 1 each | Flat, 100 % infill, 0.12–0.16 mm layers. **They differ** (each notch is in a different place): wheel 1 is the front one, next to the dial |
| Spindle with drive cam | `dl_spindle.stl` | 1 | On its side, 100 % infill, PETG or PA12 |
| Dial | `dl_dial.stl` | 1 | Face down, fine layers so the numbers come out |
| Fence with latch | `dl_fence.stl` | 1 | On its bottom, 100 % infill |
| Button (bar) | `dl_plunger.stl` | 1 | On its bottom, 100 % infill |
| Lifter | `dl_lifter.stl` | 1 | Standing on its pin and beam, 100 % infill. It replaces `lock_yoke` |

**Bought parts (India, est.):** 3 small compression springs, all from one assortment kit (Amazon.in, or Lamington Road), about ₹100–250:

| Spring | Size |
|---|---|
| Lifter spring | 5 mm OD, about 18 mm long (works at 9–16 mm) |
| Button spring | 4 mm OD, about 17 mm long, solid at 3 mm or less |
| Fence spring | 3 mm OD, 0.3 mm wire, about 8 mm long (works at 5–6.5 mm) |

It also uses the steel bolt, the bearing block, the standard `lock_cover` and its 3 screws, as the store lock does.

**Total:** about ₹150–350 (est.): the springs, plus about 12 cm³ of printing. That's a little under the ₹270 store lock.

## Choose your code

In `dial_lock.scad`, set `dial_code`: 4, 5 or 6 digits, 0–9. The wheels follow it. With 6 digits the wheel pack just fits between the face plate and the lifter (an assert checks it). Then export the wheels:

```sh
openscad -D 'lock_type="dial"' -D 'PART="dl_wheels"' -o dl_wheels.stl phone_dock_v0.5.scad
openscad -D 'lock_type="dial"' -D 'PART="lock_cartridge"' -o dl_cartridge.stl phone_dock_v0.5.scad   # its tube length follows the code
```

The other parts don't depend on the code. Don't publish the wheels with your own code.

**How the notch angles are worked out:** the last wheel each step leaves behind trails the dial by the flies' contact angle (16.1° per wheel in the chain), in the direction you turned. `dl_gate_a()` places each notch accordingly, so the code you dial is the code you set. The lock video's script simulates the pickup and checks that dialling the code lines every notch up exactly.

## Assembly

On the bench first, then into the dock:
1. **Wheels and spindle:**
   - Slide the wheels onto the cartridge's tube from behind: wheel 1 first (it goes nearest the face plate).
   - Push the spindle through the tube from behind, cam last.
   - Press the dial onto its front end, on the flat, with 0 at the index mark when the cam's pin is at the top.
2. **Fence:** put its spring on the lock cover's position (under the fence's rear end), and fit the fence under the wheels, its tooth by the button's path.
3. **Button:** put the button spring in its channel, and slide the bar in from below, its tab against the spring and its front out through the face plate.
4. **Lifter:** press the bolt into the lifter with retaining compound. Fit its spring and the lifter, with its pin over the button's bar.
5. **Into the dock:** push the cartridge up into the bay from below, with the bolt going up through the guide in the pod's roof. Screw on the lock cover.
6. **Test:**
   - Press the button and hold it, then spin the dial a turn: let go, and the button stays in.
   - Dial the code: the button pops out and the bolt drops.
   - Try a wrong code: the button must stay in.

## Checked in CAD

These checks are built in as `PART="dl_check_*"`, run with `lock_type="dial"`. They were run on the one-piece and the modular dock, with 4- and 6-digit codes.

| Check | Result |
|---|---|
| Button, lifter, fence, spindle and wheels vs the cartridge, in 4 states: locked; code set; half out; out (`dl_check_cart`) | No overlap |
| The same parts, the dial and the bolt vs the dock (`dl_check_dock`) | No overlap |
| The parts vs each other (`dl_check_parts`) | Touching only: the latch tooth rests on the button's top while it's out |
| The parts vs the lock cover (`dl_check_cover`) | No overlap |
| **Must collide:** the fence pushed 0.5 mm up with the wheels off the code (`dl_check_scrambled`) | **Blocked** by every wheel (2.76 mm³ with 4, 4.14 mm³ with 6) |
| **Must collide:** the button pushed 0.5 mm out while latched (`dl_check_held`) | **Blocked** (0.54 mm³) |
| **Must collide:** the bolt pushed down 0.5 mm while locked (`dl_check_backdrive`) | **Blocked** (2.64 mm³): the pin sits on the flat |
| Cartridge vs the dock, in place and on its way in; pulled out 0.5 mm | No overlap; **blocked** (63.7 mm³) |
| The dialling, simulated (video script) | Dialling the code lines up every notch to within 0.5° |
| All parts | Watertight single bodies (`dl_wheels` is 4 on purpose) |

**Not checked:**
- the springs' real forces and the friction of the wheels on the tube;
- how sharply the fence's tooth lets go;
- how well a printer holds the 1.5 mm fence rise and the small flies;
- rain.
