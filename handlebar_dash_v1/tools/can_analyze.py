#!/usr/bin/env python3
"""Work out the bike's CAN messages from a phase-1 log (firmware/can_logger, or any candump -l log).

    python3 tools/can_analyze.py canlog_001.log                 # every ID: rate, length, which bytes change
    python3 tools/can_analyze.py canlog_001.log --speed         # find the speed: fields that follow the GPS speed
    python3 tools/can_analyze.py canlog_001.log --marks         # what changed around each marker (button press)
    python3 tools/can_analyze.py canlog_001.log --field 1A0:2:2:le --csv out.csv   # one field over time

A "field" is ID:first byte:number of bytes:byte order (le = low byte first, be = high byte first).
Standard library only.
"""
import argparse, bisect, collections, csv, math, re, sys

FRAME = re.compile(r"^\((\d+\.\d+)\)\s+\S+\s+([0-9A-Fa-f]+)#(R|[0-9A-Fa-f]*)")
GPS = re.compile(r"^# GPS (\d+\.\d+) kmh=([\d.]+) fix=(\d)")
MARK = re.compile(r"^# MARK (\d+\.\d+) (\d+)")


def load(path):
    frames, gps, marks = [], [], []
    with open(path, errors="replace") as f:
        for line in f:
            m = FRAME.match(line)
            if m:
                data = b"" if m.group(3) == "R" else bytes.fromhex(m.group(3))
                frames.append((float(m.group(1)), int(m.group(2), 16), data))
                continue
            m = GPS.match(line)
            if m and m.group(3) == "1":
                gps.append((float(m.group(1)), float(m.group(2))))
                continue
            m = MARK.match(line)
            if m:
                marks.append((float(m.group(1)), int(m.group(2))))
    return frames, gps, marks


def by_id(frames):
    d = collections.defaultdict(list)
    for t, i, data in frames:
        d[i].append((t, data))
    return d


def summary(frames):
    d = by_id(frames)
    span = (frames[-1][0] - frames[0][0]) or 1
    print(f"{len(frames)} frames, {len(d)} IDs, {span:.0f} s\n")
    print(f"{'ID':>8} {'Hz':>6} {'len':>4}  bytes that change (number of different values)")
    for i in sorted(d):
        rows = d[i]
        lens = sorted({len(x) for _, x in rows})
        n = max(lens)
        changes = []
        for b in range(n):
            vals = {x[b] for _, x in rows if len(x) > b}
            changes.append(f"b{b}:{len(vals)}" if len(vals) > 1 else f"b{b}:-")
        print(f"{i:>8X} {len(rows) / span:6.1f} {','.join(map(str, lens)):>4}  {'  '.join(changes)}")


def value(data, start, size, order):
    if len(data) < start + size:
        return None
    b = data[start:start + size]
    return int.from_bytes(b, "little" if order == "le" else "big")


def gps_at(gps_t, gps_v, t):
    """GPS speed at time t, interpolated; None outside the GPS readings or across a gap over 2 s."""
    k = bisect.bisect_left(gps_t, t)
    if k == 0 or k >= len(gps_t):
        return None
    t0, t1 = gps_t[k - 1], gps_t[k]
    if t1 - t0 > 2.0:
        return None
    return gps_v[k - 1] + (gps_v[k] - gps_v[k - 1]) * (t - t0) / (t1 - t0)


def fit(xs, ys):
    """Pearson r and the straight line y = a*x + b."""
    n = len(xs)
    mx, my = sum(xs) / n, sum(ys) / n
    sxx = sum((x - mx) ** 2 for x in xs)
    syy = sum((y - my) ** 2 for y in ys)
    sxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    if sxx == 0 or syy == 0:
        return 0.0, 0.0, 0.0
    a = sxy / sxx
    return sxy / math.sqrt(sxx * syy), a, my - a * mx


def find_speed(frames, gps, top=12):
    if len(gps) < 20:
        sys.exit("Not enough GPS readings with a fix in this log (need a ride with the GPS locked).")
    if max(v for _, v in gps) < 15:
        sys.exit("The GPS speed never passes 15 km/h in this log: ride at a range of speeds and log again.")
    gps_t, gps_v = [t for t, _ in gps], [v for _, v in gps]
    results = []
    for i, rows in by_id(frames).items():
        n = max(len(x) for _, x in rows)
        for size in (1, 2):
            for start in range(0, n - size + 1):
                for order in (("le", "be") if size == 2 else ("le",)):
                    xs, ys = [], []
                    for t, data in rows[:: max(1, len(rows) // 3000)]:
                        v = value(data, start, size, order)
                        g = gps_at(gps_t, gps_v, t)
                        if v is not None and g is not None:
                            xs.append(v); ys.append(g)
                    if len(xs) < 20 or len(set(xs)) < 5:
                        continue
                    r, a, b = fit(xs, ys)
                    results.append((abs(r), r, i, start, size, order, a, b, len(xs)))
    results.sort(reverse=True)
    print("Fields that follow the GPS speed best (r = 1 is a perfect match):\n")
    print(f"{'field':>16} {'r':>7}  speed (km/h) = scale x raw + offset   samples")
    for _, r, i, start, size, order, a, b, n in results[:top]:
        print(f"{i:>8X}:{start}:{size}:{order} {r:7.4f}  {a:.5f} x raw + {b:.2f}   {n}")
    print("\nA wheel-speed field usually has r above 0.98 and a round scale (0.01, 0.05, 0.1, 1/16, 1/128 ...).")
    print("Wheel speed reads a little above GPS speed (tyre wear); the offset should be near 0.")


def around_marks(frames, marks, before_s=3.0, settle_s=0.3, after_s=2.0):
    """Bytes that held one value for before_s before the marker and another for after_s after it (once settled):
    a switch, a lamp or a mode, not a byte that changes all the time."""
    d = by_id(frames)
    for t, k in marks:
        print(f"\nMarker {k} at {t:.2f} s: bytes that were steady, then steady at a new value")
        found = False
        for i in sorted(d):
            before = [x for tt, x in d[i] if t - before_s <= tt < t]
            after = [x for tt, x in d[i] if t + settle_s <= tt < t + settle_s + after_s]
            if not before or not after:
                continue
            n = min(min(len(x) for x in before), min(len(x) for x in after))
            diff = []
            for j in range(n):
                vb, va = {x[j] for x in before}, {x[j] for x in after}
                if len(vb) == 1 and len(va) == 1 and vb != va:
                    diff.append(f"b{j}:{vb.pop():02X}->{va.pop():02X}")
            if diff:
                found = True
                print(f"  {i:>8X}  {'  '.join(diff)}")
        if not found:
            print("  (nothing: try the action again, holding it for a few seconds, and mark when you start)")


def export_field(frames, spec, out):
    i, start, size, order = spec.split(":")
    i, start, size = int(i, 16), int(start), int(size)
    rows = [(t, value(x, start, size, order)) for t, j, x in frames if j == i]
    with open(out, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["time_s", "raw"])
        w.writerows((f"{t:.6f}", v) for t, v in rows if v is not None)
    print(f"wrote {len(rows)} values to {out}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("log")
    ap.add_argument("--speed", action="store_true", help="find the fields that follow the GPS speed")
    ap.add_argument("--marks", action="store_true", help="show what changed around each marker")
    ap.add_argument("--field", help="ID:start:size:le|be, with --csv")
    ap.add_argument("--csv", help="output file for --field")
    a = ap.parse_args()
    frames, gps, marks = load(a.log)
    if not frames:
        sys.exit("No CAN frames in this file.")
    if a.speed:
        find_speed(frames, gps)
    elif a.marks:
        if not marks:
            sys.exit("No markers in this log.")
        around_marks(frames, marks)
    elif a.field:
        export_field(frames, a.field, a.csv or "field.csv")
    else:
        summary(frames)


if __name__ == "__main__":
    main()
