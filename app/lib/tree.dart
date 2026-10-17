/// Study tree: one sakura for all your reviews, growing from a seedling to the Moon.
/// The camera stands 6 m from the tree and looks level, so the tree keeps its size on
/// screen while the landscape, clouds, Earth and Moon are drawn at their real distances.
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show TableUpdateQuery, Variable;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'db.dart';
import 'theme.dart';

/// Height in metres after [n] reviews: 1 cm a card, plus an exponential term that
/// reaches the Moon after about three years at 150 reviews a day.
double treeHeight(int n) => n <= 0 ? 0 : 0.01 * n + 0.5 * (math.pow(10, n / 18000) - 1);

String fmtHeight(double m) {
  if (m < 1) return '${(m * 100).round()} cm';
  if (m < 1000) return m < 10 ? '${m.toStringAsFixed(1)} m' : '${m.round()} m';
  final k = m / 1000;
  return k < 10 ? '${k.toStringAsFixed(1)} km' : '${_thousands(k.round())} km';
}

String _thousands(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

const _moon = 384400e3;
const milestones = [
  (1.0, '1 m'), (10.0, '10 m'), (100.0, '100 m'), (1e3, '1 km'), (1e4, '10 km'), (1e5, '100 km'), //
  (1e6, '1,000 km'), (1e7, '10,000 km'), (1e8, '100,000 km'), (_moon, 'The Moon'),
];

typedef TreeCounts = ({int total, int today, int recent});

/// All reviews, today's (after the rollover hour), and the last 14 days' (for "next in N days").
Future<TreeCounts> loadTreeCounts() async {
  final today = dayStart();
  int secs(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;
  final r = (await db.customSelect(
    'SELECT COUNT(*) AS n, SUM(reviewed_at >= ?1) AS t, SUM(reviewed_at >= ?2) AS r FROM review_logs WHERE deleted = 0',
    variables: [Variable(secs(today)), Variable(secs(today.subtract(const Duration(days: 14))))],
  ).get())
      .first;
  return (total: r.read<int>('n'), today: r.read<int?>('t') ?? 0, recent: r.read<int?>('r') ?? 0);
}

Stream<TreeCounts> watchTreeCounts() async* {
  yield await loadTreeCounts();
  await for (final _ in db.tableUpdates(TableUpdateQuery.onTable(db.reviewLogs))) {
    yield await loadTreeCounts();
  }
}

class TreePage extends StatefulWidget {
  const TreePage({super.key, required this.active});

  /// The tab is showing: the tree sprouts again each time it becomes active.
  final bool active;

  @override
  State<TreePage> createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> with SingleTickerProviderStateMixin {
  final _w = _World();
  final _clock = Stopwatch()..start();
  late final Ticker _ticker = createTicker((_) => _w.tick(_clock.elapsedMicroseconds / 1e6));
  StreamSubscription<TreeCounts>? _sub;
  TreeCounts? _c;

  @override
  void initState() {
    super.initState();
    _sub = watchTreeCounts().listen((c) {
      final old = _c;
      setState(() => _c = c);
      if (!widget.active) return;
      if (old == null) {
        _sprout();
      } else if (c.total > old.total) {
        _w.play([(_w.h, math.max(treeHeight(c.total), 0.03), 1.6)]);
      }
    });
    if (widget.active) _ticker.start();
  }

  @override
  void didUpdateWidget(TreePage old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _ticker.start();
      _sprout();
    } else if (!widget.active && old.active) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ticker.dispose();
    _w.dispose();
    super.dispose();
  }

  /// Sprout from the soil to where the tree stood this morning, then glide up through today's growth.
  void _sprout() {
    final c = _c;
    if (c == null) return;
    final h = math.max(treeHeight(c.total), 0.03), y = treeHeight(c.total - c.today);
    _w.play(y > 0.05 && h > y * 1.0001 ? [(0.03, y, 2.2), (y, h, 1.8)] : [(0.03, h, 2.2)]);
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      body: GestureDetector(
        onTap: _sprout,
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _Scene(_w, top))),
          if (c != null) _Hud(_w, c),
        ]),
      ),
    );
  }
}

/// The scene frozen at [height] metres.
@visibleForTesting
Widget treeSceneAt(double height) => CustomPaint(painter: _Scene(_World()..h = height, 0));

class _Hud extends StatelessWidget {
  const _Hud(this.w, this.c);
  final _World w;
  final TreeCounts c;

  @override
  Widget build(BuildContext context) {
    final label = ts(10, w: 500, color: C.text2).copyWith(letterSpacing: 1.6);
    final value = ts(15, w: 500).copyWith(fontFeatures: const [ui.FontFeature.tabularFigures()]);
    final small = ts(11, color: C.text2);
    final h = treeHeight(c.total), y = treeHeight(c.total - c.today);
    final next = milestones.where((m) => m.$1 > h * 1.0001).firstOrNull;
    String? days;
    if (next != null && c.recent > 0) {
      var lo = c.total, hi = 10000000;
      while (hi - lo > 1) {
        final m = (lo + hi) >> 1;
        treeHeight(m) >= next.$1 ? hi = m : lo = m;
      }
      final d = ((hi - c.total) / (c.recent / 14)).ceil();
      days = d == 1 ? '1 day' : '$d days';
    }
    Widget cell(String l, Widget v, int flex) => Expanded(
          flex: flex,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: label), const SizedBox(height: 3), v]),
        );
    Widget line(String a, String? b) => Text.rich(
          TextSpan(text: a, children: [if (b != null) TextSpan(text: ' · $b', style: small)]),
          style: value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x80080610), Color(0x00080610)]),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 32, 26),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            cell('HEIGHT', ListenableBuilder(listenable: w, builder: (_, _) => Text(fmtHeight(w.h), style: value)), 4),
            cell('GREW TODAY', line('+${fmtHeight(h - y)}', '${c.today} cards'), 5),
            cell('NEXT', line(next?.$2 ?? 'Past the Moon', days), 5),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- animation state

class _World extends ChangeNotifier {
  double h = 0.03, t = 0, dt = 0, _t0 = 0, _prev = 0.03, nextShoot = 0;
  final _segs = <(double, double, double)>[];
  final ripples = <double>[];
  final burst = <_Bit>[];
  final shooting = <(double, double, double, double)>[];
  final petals = [for (var i = 0; i < 16; i++) _Petal(i)];
  final rnd = math.Random();

  /// Plays height segments (from, to, seconds) back to back, eased in log height.
  void play(List<(double, double, double)> segs) {
    _segs
      ..clear()
      ..addAll(segs);
    _t0 = t;
    _prev = segs.first.$1;
  }

  void tick(double now) {
    dt = (now - t).clamp(0.0, 0.1);
    t = now;
    var e = t - _t0, playing = false;
    for (final (a, b, d) in _segs) {
      if (e < d) {
        h = math.exp(_lerp(math.log(a), math.log(b), _io(e / d)));
        playing = true;
        break;
      }
      e -= d;
      h = b;
    }
    if (playing) {
      for (final (m, _) in milestones) {
        if (_prev < m && h >= m) {
          ripples.add(t);
          for (var k = 0; k < 12; k++) {
            final a = rnd.nextDouble() * 6.28, s = 30 + rnd.nextDouble() * 60;
            burst.add(_Bit(math.cos(a) * s, math.sin(a) * s - 30, k % 3, rnd.nextDouble() * 6));
          }
        }
      }
    }
    _prev = h;
    notifyListeners();
  }
}

class _Bit {
  _Bit(this.vx, this.vy, this.c, this.p);
  double x = 0, y = 0, vx, vy, life = 1;
  final int c;
  final double p;
}

class _Petal {
  _Petal(int i) {
    final r = math.Random(i + 200);
    life = r.nextDouble();
    c = r.nextInt(3);
    p = r.nextDouble() * 6;
  }
  late double life, p;
  late int c;
  double x = 0, y = 0;
  bool placed = false;
}

// ---------------------------------------------------------------- helpers

double _cl(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);
double _io(double t) => t < .5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
double _eo(double t) => 1 - math.pow(1 - t, 3).toDouble();
double _lerp(double a, double b, double t) => a + (b - a) * t;
Color _hex(int v) => Color(0xFF000000 | v);
Color _mix(Color a, Color b, double t) => Color.lerp(a, b, _cl(t))!;
Color _al(Color c, double a) => c.withValues(alpha: _cl(a));

const _vh = 760.0, _f = 420.0, _yh = _vh * 0.6, _d0 = 6.0, _s = _f / _d0, _hf = 4.5, _eye = 1.6, _r = 6371e3;
const _trunk = Color(0xFF1A1226);
final _blc = [_hex(0xf7d3e2), _hex(0xeab3cc), _hex(0xd8b6ef), _hex(0xc995b8)];

/// Sky colours by log10(camera altitude): (at, top, horizon).
const _sky = [
  (0.0, 0x2f2554, 0xf2b8a0), (2.75, 0x2f2554, 0xf2b8a0), (3.3, 0x2d2352, 0xc28aa6), (3.9, 0x2d2352, 0x7a5a9a), //
  (4.25, 0x0d1230, 0x2a3a78), (4.6, 0x070a1c, 0x17224d), (5.05, 0x02030a, 0x0a1030), (9.5, 0x02030a, 0x05081a),
];

(Color, Color) _skyAt(double l) {
  var i = 0;
  while (i < _sky.length - 2 && l > _sky[i + 1].$1) {
    i++;
  }
  final a = _sky[i], b = _sky[i + 1], t = _cl((l - a.$1) / (b.$1 - a.$1));
  return (_mix(_hex(a.$2), _hex(b.$2), t), _mix(_hex(a.$3), _hex(b.$3), t));
}

// ---------------------------------------------------------------- tree model (px at full size, base at 0, y up)

class _Br {
  _Br(this.p, this.u, this.a, this.len, this.w, this.b, this.d, this.ph, this.bend);
  final int p, d;
  final double u, a, len, w, b, ph, bend;
  bool tip = false;
}

class _Clump {
  _Clump(this.i, this.u, this.r, this.b, this.c, this.sp);
  final int i;
  final double u, r, b;
  final List<(double, double, double)> c; // puffs: x, y, radius (× r)
  final List<(double, double, double, double)> sp; // loose blossoms: x, y, radius, colour
}

final (List<_Br>, List<_Clump>) _model = () {
  final r = math.Random(21), br = <_Br>[];
  double n() => r.nextDouble();
  int add(int p, double u, double a, double len, double w, double b, int d) {
    br.add(_Br(p, u, a, len, w, b, d, n() * 6, (n() - 0.5) * 0.5));
    return br.length - 1;
  }

  var p = add(-1, 0, 0.03, 62, 13, 0, 0);
  p = add(p, 1, -0.07, 46, 11, 0.04, 0);
  p = add(p, 1, 0.06, 34, 9.5, 0.08, 0);
  void limb(int par, double u, double a, double len, double w, double b, int d) {
    final i = add(par, u, a, len, w, b, d);
    if (d >= 4) {
      br[i].tip = true;
      return;
    }
    final k3 = d == 1 ? 3 : 2;
    for (var k = 0; k < k3; k++) {
      final off = (k - (k3 - 1) / 2) * (k3 == 3 ? 0.5 : 0.62) + (n() - 0.5) * 0.25;
      limb(i, 1, (a * 0.8 + off).clamp(-1.3, 1.3), len * (0.64 + n() * 0.12), w * 0.62, b + 0.08, d + 1);
    }
    if (d >= 2 && n() < 0.7) {
      br[add(i, 0.45 + n() * 0.2, a + (n() < 0.5 ? -1 : 1) * (0.6 + n() * 0.3), len * 0.42, w * 0.5, b + 0.1, 4)].tip = true;
    }
  }

  limb(p, 1, -0.8, 66, 7, 0.12, 1);
  limb(p, 1, 0, 74, 7.5, 0.11, 1);
  limb(p, 1, 0.82, 64, 7, 0.13, 1);
  final cl = <_Clump>[];
  for (var i = 0; i < br.length; i++) {
    final b = br[i];
    if (!b.tip && b.d != 3) continue;
    cl.add(_Clump(i, b.tip ? 1 : 0.55, b.tip ? 13 + n() * 7 : 9 + n() * 5, b.b + 0.05, [
      for (var k = 0; k < 5; k++) ((n() - 0.5) * 1.3, (n() - 0.5) * 0.9, 0.5 + n() * 0.45),
    ], [
      for (var k = 0; k < 7; k++)
        () {
          final a = n() * 6.28, d = 0.85 + n() * 0.45;
          return (math.cos(a) * d, math.sin(a) * d * 0.8, 0.07 + n() * 0.06, n());
        }(),
    ]));
  }
  return (br, cl);
}();

typedef _Seg = ({double sx, double sy, double ex, double ey, double mx, double my, double w});

/// Branches and blossom clumps at growth [g] (0..1): each branch stretches out after its parent.
({List<_Seg?> segs, List<(double, double, double, _Clump)> clumps, double top, double topX}) _geo(double g, double t) {
  final segs = <_Seg?>[];
  var top = 0.0, topX = 0.0;
  for (final b in _model.$1) {
    final len = b.len * _eo(_cl((g - b.b) / 0.3));
    final q = b.p >= 0 ? segs[b.p] : null;
    if (len <= 0.01 || (b.p >= 0 && q == null)) {
      segs.add(null);
      continue;
    }
    final sx = q == null ? 0.0 : q.sx + (q.ex - q.sx) * b.u, sy = q == null ? 0.0 : q.sy + (q.ey - q.sy) * b.u;
    final a = b.a + math.sin(t * 0.6 + b.ph) * 0.02 * b.d, ex = sx + math.sin(a) * len, ey = sy + math.cos(a) * len;
    segs.add((
      sx: sx, sy: sy, ex: ex, ey: ey, //
      mx: (sx + ex) / 2 + math.cos(a) * len * b.bend * 0.3, my: (sy + ey) / 2 - math.sin(a) * len * b.bend * 0.3,
      w: b.w * (0.35 + 0.65 * _cl((g - b.b) / 0.4)),
    ));
    if (ey > top) (top, topX) = (ey, ex);
  }
  final clumps = <(double, double, double, _Clump)>[];
  for (final c in _model.$2) {
    final q = segs[c.i], bl = _cl((g - c.b) / 0.25);
    if (q == null || bl <= 0) continue;
    final x = q.sx + (q.ex - q.sx) * c.u, y = q.sy + (q.ey - q.sy) * c.u, r = c.r * _eo(bl);
    clumps.add((x, y, r, c));
    if (y + r * 0.6 > top) (top, topX) = (y + r * 0.6, x);
  }
  return (segs: segs, clumps: clumps, top: math.max(top, 0.5), topX: topX);
}

// ---------------------------------------------------------------- world objects (metres)

class _Layer {
  _Layer(this.d, this.amp, this.wl, this.base, int col, int seed) : col = _hex(col) {
    final r = math.Random(seed * 131);
    ph = [r.nextDouble() * 6, r.nextDouble() * 6, r.nextDouble() * 6];
  }
  final double d, amp, wl, base;
  final Color col;
  late final List<double> ph;
  double z(double x) =>
      base + amp * (0.5 + 0.3 * math.sin(x / wl * 6.28 + ph[0]) + 0.14 * math.sin(x / wl * 15.1 + ph[1]) + 0.06 * math.sin(x / wl * 37 + ph[2]));
}

final _layers = [
  _Layer(120e3, 900, 30e3, 500, 0xa07fae, 1), _Layer(25e3, 650, 8e3, 150, 0x83649a, 2), //
  _Layer(8e3, 280, 2.6e3, 40, 0x6a4f84, 3), _Layer(2.5e3, 100, 800, 8, 0x4d3a66, 4),
  _Layer(600, 28, 200, 0, 0x3a2c50, 5), _Layer(70, 2.2, 45, 0, 0x2e2342, 6), _Layer(40, 0.5, 20, 0, 0x2a1f3d, 7),
];

typedef _Cloud = ({double d, double z, double w, double x0, double v});
final List<_Cloud> _clouds = () {
  final r = math.Random(4);
  return [
    for (var i = 0; i < 45; i++)
      () {
        final d = math.exp(_lerp(math.log(3000), math.log(2.2e6), r.nextDouble()));
        return (d: d, z: 1300 + r.nextDouble() * 1400, w: (d * (0.04 + r.nextDouble() * 0.1)).clamp(220.0, 8e4), x0: (r.nextDouble() - 0.5) * d * 1.3, v: 3 + r.nextDouble() * 6);
      }(),
  ]..sort((a, b) => b.d.compareTo(a.d));
}();

final _grass = () {
  final r = math.Random(3);
  return [
    for (var i = 0; i < 110; i++)
      () {
        final d = 2.4 + math.pow(r.nextDouble(), 1.6) * 28;
        return (d: d, x: (r.nextDouble() - 0.5) * d * 1.05, h: 0.12 + r.nextDouble() * 0.22, p: r.nextDouble() * 6);
      }(),
  ]..sort((a, b) => b.d.compareTo(a.d));
}();

final _fallen = () {
  final r = math.Random(8);
  return [
    for (var i = 0; i < 34; i++)
      () {
        final d = 4.6 + r.nextDouble() * 4;
        return (d: d, x: (r.nextDouble() - 0.5) * 3.6 * (0.3 + r.nextDouble() * 0.7), c: r.nextInt(3), p: (r.nextDouble() - 0.5) * 0.6);
      }(),
  ];
}();

final _stars = () {
  final r = math.Random(9);
  return [for (var i = 0; i < 240; i++) (x: r.nextDouble(), y: r.nextDouble() * _vh, p: r.nextDouble() * 6, s: r.nextDouble() < 0.12 ? 1.7 : (r.nextDouble() < 0.5 ? 1.1 : 0.8))];
}();

/// Chongqing, 3.5 km out on the right: a hill city with Raffles City at the river tip.
final _city = () {
  final r = math.Random(12), out = <({double x, double w, double h, int ty, List<(double, double)> lights})>[];
  var x = 700.0;
  while (x < 2900) {
    final w = 22 + r.nextDouble() * 40, env = math.exp(-math.pow((x - 1500) / 850, 2)), h = 35 + env * (110 + r.nextDouble() * 190) + r.nextDouble() * 45;
    out.add((x: x, w: w, h: h, ty: r.nextDouble() < 0.22 ? 1 : (r.nextDouble() < 0.3 ? 2 : 0), lights: [for (var i = 0; i < 3 + h ~/ 30; i++) (r.nextDouble(), r.nextDouble())]));
    x += w * (0.5 + r.nextDouble() * 0.6);
  }
  return out;
}();
double _cqBase(double x) => 120 + 60 * math.sin(x / 520 + 1) + 25 * math.sin(x / 190);

// ---------------------------------------------------------------- painter

class _Scene extends CustomPainter {
  _Scene(this.w, this.topPad) : super(repaint: w);
  final _World w;
  final double topPad;

  @override
  bool shouldRepaint(_Scene old) => old.w != w || old.topPad != topPad;

  @override
  void paint(Canvas canvas, Size size) {
    final k0 = size.height / _vh, W = size.width / k0, cx = W / 2, spread = math.max(1.0, W / 390);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(k0);
    final h = w.h, t = w.t, dt = w.dt, hc = math.max(_eye, h - (_hf - _eye)), l10 = math.log(hc) / math.ln10;
    final (skyTop, hz) = _skyAt(l10);
    double px(double x, double d) => cx + _f * x / d;
    double py(double z, double d) => _yh + _f * (hc - z + d * d / (2 * _r)) / d;
    double hazeK(double d) => 0.86 * (1 - math.exp(-d / (25e3 * (1 + hc / 3000))));
    final tD = math.tan(math.acos(_r / (_r + hc)));
    double limbY(double x) => _yh + _f * tD * math.sqrt(1 + math.pow((x - cx) / _f, 2));
    final lY = limbY(cx);
    final fill = Paint(), line = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    void circle(double x, double y, double r, Color c) => canvas.drawCircle(Offset(x, y), r, fill..color = c);
    void oval(double x, double y, double rx, double ry, Color c, [double rot = 0]) {
      fill.color = c;
      if (rot == 0) return canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: rx * 2, height: ry * 2), fill);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), fill);
      canvas.restore();
    }

    void shaded(Shader s, void Function() draw) {
      fill.shader = s;
      draw();
      fill.shader = null;
    }

    // sky
    shaded(ui.Gradient.linear(Offset.zero, Offset(0, math.max(lY, 40)), [skyTop, _mix(skyTop, hz, 0.5), hz], [0, 0.6, 1]),
        () => canvas.drawRect(Rect.fromLTWH(0, 0, W, _vh), fill));

    // stars and shooting stars
    final sa = _cl((l10 - 4.3) / 0.7);
    if (sa > 0) {
      for (final s in _stars) {
        if (s.y > lY) continue;
        fill.color = _al(const Color(0xFFF0ECFF), sa * (0.55 + 0.45 * math.sin(t * 1.3 + s.p)) * (s.s > 1 ? 1 : 0.75));
        canvas.drawRect(Rect.fromLTWH(s.x * W, s.y, s.s, s.s), fill);
      }
      if (t > w.nextShoot) {
        w.shooting.add((w.rnd.nextDouble() * W * 0.8 + W * 0.1, w.rnd.nextDouble() * _vh * 0.35 + 80, t, 0.5 + w.rnd.nextDouble() * 0.3));
        w.nextShoot = t + 3 + w.rnd.nextDouble() * 5;
      }
      for (final (x0, y0, t0, a) in w.shooting) {
        final p = (t - t0) / 0.9;
        if (p > 1 || p < 0) continue;
        final dx = math.cos(a), dy = math.sin(a), hx = x0 + dx * p * 160, hy = y0 + dy * p * 160;
        line
          ..strokeWidth = 1.1
          ..shader = ui.Gradient.linear(Offset(hx, hy), Offset(hx - dx * 70, hy - dy * 70), [_al(Colors.white, (1 - p) * 0.8 * sa), _al(Colors.white, 0)]);
        canvas.drawLine(Offset(hx, hy), Offset(hx - dx * 70, hy - dy * 70), line);
        line.shader = null;
      }
      w.shooting.removeWhere((s) => t - s.$3 > 1);
    }

    // sun: fixed direction just above the horizon, gone once the sky turns dark
    final sunA = 1 - _cl((l10 - 3.2) / 0.6);
    if (sunA > 0) {
      final c = Offset(cx + 92, _yh - 44);
      shaded(ui.Gradient.radial(c, 200, [_al(const Color(0xFFFFDCC4), 0.5 * sunA), _al(const Color(0xFFFFC8B4), 0)]),
          () => canvas.drawRect(Rect.fromLTWH(0, 0, W, _vh), fill));
      circle(c.dx, c.dy, 19, _al(_hex(0xffe7d6), sunA));
    }

    // moon: fixed direction, real angular size (×3) so it grows as you close in
    {
      final dist = math.max(_moon - h, 1.9e6), ang = math.asin(math.min(0.97, 1737e3 / dist));
      final r = (3 * _f * math.tan(ang)).clamp(4.0, 260.0), mx = cx + 150, my = _yh - 300, ma = 0.45 + 0.55 * _cl(l10 / 4.5);
      const moonC = Color(0xFFE8E4DA);
      shaded(ui.Gradient.radial(Offset(mx, my), r * 1.5 + 10, [_al(moonC, 0.25 * ma), _al(moonC, 0.25 * ma), _al(moonC, 0)], [0, r / (r * 1.5 + 10), 1]),
          () => canvas.drawCircle(Offset(mx, my), r * 1.5 + 10, fill));
      circle(mx, my, r, _al(moonC, ma));
      if (r > 8) {
        canvas.save();
        canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(mx, my), radius: r)));
        for (final (a, b, rr) in const [(-0.55, -0.3, 0.2), (-0.25, 0.25, 0.26), (-0.7, 0.35, 0.12), (-0.4, -0.65, 0.1), (-0.15, -0.2, 0.08), (0.35, 0.5, 0.14), (0.5, -0.35, 0.1)]) {
          circle(mx + a * r, my + b * r, rr * r, _al(const Color(0xFF9691A0), 0.2 * ma));
        }
        shaded(ui.Gradient.linear(Offset(mx - r, 0), Offset(mx + r * 0.3, 0), [_al(const Color(0xFF1E1C32), 0.6 * ma), _al(const Color(0xFF1E1C32), 0)], [0, 0.55]),
            () => canvas.drawRect(Rect.fromLTWH(mx - r, my - r, 2 * r, 2 * r), fill));
        canvas.restore();
      }
    }

    // Earth below the limb, with a thin atmosphere glow from high up
    if (lY < _vh + 10) {
      final limb = Path()..moveTo(-5, limbY(-5));
      for (var x = 0.0; x <= W + 5; x += 5) {
        limb.lineTo(x, limbY(x));
      }
      final land = Path.from(limb)
        ..lineTo(W + 5, _vh + 5)
        ..lineTo(-5, _vh + 5)
        ..close();
      shaded(ui.Gradient.linear(Offset(0, lY), Offset(0, lY + 260), [_mix(_hex(0x8a76a8), hz, 0.55), _mix(_hex(0x3e3160), hz, 0.25), _hex(0x1d1733)], [0, 0.3, 1]),
          () => canvas.drawPath(land, fill));
      final ga = _cl((l10 - 4.2) / 0.6);
      if (ga > 0) {
        for (final (lw, c) in [(14.0, _al(const Color(0xFF7896FF), 0.12 * ga)), (5.0, _al(const Color(0xFF96AFFF), 0.3 * ga)), (1.4, _al(const Color(0xFFC8D7FF), 0.75 * ga))]) {
          canvas.drawPath(limb.shift(Offset(0, -lw * 0.3)), line
            ..strokeWidth = lw
            ..color = c);
        }
      }
    }

    // world objects, far to near
    var ci = 0;
    void cloudsTo(double d) {
      for (; ci < _clouds.length && _clouds[ci].d >= d; ci++) {
        final c = _clouds[ci], span = c.d * 1.3 * spread, x = (c.x0 * spread + t * c.v + span / 2) % span - span / 2;
        final sx = px(x, c.d), sy = py(c.z, c.d), sw = _f * c.w / c.d;
        if (sw < 2.5 || sy < -60 || sy > _vh + 60 || sx < -sw || sx > W + sw) continue;
        final k = hazeK(c.d), fl = hc > c.z ? math.max(0.3, 1 - (hc - c.z) / 6000) : 1.0;
        canvas.save();
        canvas.translate(0, sy);
        canvas.scale(1, fl);
        _cloud(canvas, fill, sx, 0, sw, _mix(_hex(0xfbe3e8), hz, k * 0.65), _mix(_hex(0xc398b8), hz, k * 0.7));
        canvas.restore();
      }
    }

    for (final L in _layers) {
      if (L.d == 25e3) {
        cloudsTo(35e3);
        _fuji(canvas, fill, px, py, hz, hazeK(35e3) * 0.8);
      }
      cloudsTo(L.d);
      final gy = py(L.base + L.amp, L.d);
      if (gy > _vh + 5) continue;
      final k = hazeK(L.d);
      final ridge = Path()..moveTo(-5, _vh + 5);
      for (var sx = -5.0; sx <= W + 5; sx += 4) {
        ridge.lineTo(sx, py(L.z((sx - cx) * L.d / _f), L.d));
      }
      ridge
        ..lineTo(W + 5, _vh + 5)
        ..close();
      shaded(
        L.d == 40
            ? ui.Gradient.linear(Offset(0, gy), const Offset(0, _vh), [_mix(L.col, hz, 0.42), _mix(L.col, hz, 0.14), L.col], [0, 0.35, 1])
            : ui.Gradient.linear(Offset(0, gy), Offset(0, gy + 240), [_mix(L.col, hz, k), _mix(_hex(0x1f1836), hz, k * 0.35)]),
        () => canvas.drawPath(ridge, fill),
      );
      if (L.d == 8e3) {
        cloudsTo(3500);
        _chongqing(canvas, fill, px, py, hz, hazeK(3500), t);
      }
      if (L.d == 70) _torii(canvas, fill, px(-21, 70), py(L.z(-21), 70) + 1.5, _f / 70 * 8, hz);
      if (L.d == 40) {
        // stone lantern 15 m out
        const d = 15.0, s = _f / d;
        final lx = px(5.6, d), ly = py(0, d);
        if (ly - 1.4 * s < _vh) {
          fill.color = _mix(_hex(0x2a1d3c), hz, 0.06);
          canvas.drawRect(Rect.fromLTWH(lx - 0.09 * s, ly - 0.75 * s, 0.18 * s, 0.75 * s), fill);
          canvas.drawRect(Rect.fromLTWH(lx - 0.24 * s, ly - 1.05 * s, 0.48 * s, 0.3 * s), fill);
          canvas.drawRect(Rect.fromLTWH(lx - 0.18 * s, ly - 0.12 * s, 0.36 * s, 0.12 * s), fill);
          canvas.drawPath(Path()..moveTo(lx - 0.36 * s, ly - 1.05 * s)..lineTo(lx, ly - 1.4 * s)..lineTo(lx + 0.36 * s, ly - 1.05 * s)..close(), fill);
          fill.color = const Color(0xF2FFD6A0);
          canvas.drawRect(Rect.fromLTWH(lx - 0.12 * s, ly - 1.0 * s, 0.24 * s, 0.17 * s), fill);
          shaded(ui.Gradient.radial(Offset(lx, ly - 0.92 * s), 1.2 * s, [const Color(0x52FFC896), const Color(0x00FFC896)]),
              () => canvas.drawCircle(Offset(lx, ly - 0.92 * s), 1.2 * s, fill));
        }
        // petals on the ground, then grass
        final pa = _cl((h - 0.8) / 2);
        if (pa > 0) {
          for (final q in _fallen) {
            final sx = px(q.x, q.d), sy = py(0, q.d), k = _f / q.d;
            if (sy <= _vh + 4) oval(sx, sy, 0.05 * k, 0.018 * k, _al(_blc[q.c], 0.65 * pa), q.p);
          }
        }
        line.color = _hex(0x4b3a66);
        for (final q in _grass) {
          if (q.d < _d0 - 0.5) continue;
          final sx = px(q.x * spread, q.d), sy = py(0, q.d), hg = _f * q.h / q.d;
          if (sy > _vh + 5) continue;
          line.strokeWidth = math.max(0.8, _f * 0.012 / q.d);
          canvas.drawPath(
              Path()
                ..moveTo(sx, sy)
                ..quadraticBezierTo(sx + 1, sy - hg * 0.6, sx + hg * 0.25 + math.sin(t * 1.2 + q.p) * hg * 0.12, sy - hg),
              line);
        }
      }
    }

    // ------------------------------------------------ tree
    final hm = math.min(h, _hf), gg = math.pow(hm / _hf, 0.7).toDouble(), g = _geo(gg, t);
    final sc = _s * hm / g.top, tipY = _yh + _s * (hc - h), baseY = tipY + _s * hm, yB = _yh + _s * hc;
    double tx(double x) => cx + x * sc;
    double ty(double y) => baseY - y * sc;
    final dark = _cl((l10 - 3.9) / 0.6);
    if (yB < _vh + 20) oval(cx, yB + 2, math.max(4, 150 * sc * _cl(gg * 1.6)), math.max(1.5, 7 * sc), const Color(0x59120A1C));

    // trunk below the crown, down to the ground or off screen, with little twigs that scroll past
    final yEnd = math.min(yB, _vh + 20);
    if (h > _hf && yEnd > baseY) {
      final w0 = 13 * sc * 0.5;
      double wf(double y) => w0 + math.min(y - baseY, 600) * 0.008;
      final trunk = Path()..moveTo(cx - wf(baseY - 4), baseY - 4);
      for (var y = baseY - 4; y <= yEnd; y += 6) {
        trunk.lineTo(cx - wf(y), y);
      }
      trunk
        ..lineTo(cx - wf(yEnd), yEnd)
        ..lineTo(cx + wf(yEnd), yEnd);
      for (var y = yEnd; y >= baseY - 4; y -= 6) {
        trunk.lineTo(cx + wf(y), y);
      }
      canvas.drawPath(trunk..close(), fill..color = _trunk);
      if (dark > 0) {
        canvas.drawLine(Offset(cx + wf(baseY + 20), baseY + 20), Offset(cx + wf(yEnd), yEnd), line
          ..strokeWidth = 0.8
          ..color = _al(const Color(0xFFCDBCFF), 0.3 * dark));
      }
      const q = 400.0, z0 = 1.2, step = 46.0;
      double f(double z) => q * math.log(1 + z / z0);
      final fh = f(h);
      for (var k = (fh / step).floor(); k >= 0; k--) {
        final zk = z0 * (math.exp(k * step / q) - 1);
        if (zk < _hf * 1.05) break;
        final y = baseY + fh - f(zk);
        if (y < baseY + 10) continue;
        if (y > yEnd) break;
        final r = math.Random(k * 7919 + 5), sd = k.isOdd ? 1 : -1, len = 10 + r.nextDouble() * 10, a = 0.7 + r.nextDouble() * 0.4;
        final x0 = cx + sd * wf(y) * 0.8, ex = x0 + sd * math.sin(a) * len, ey = y - math.cos(a) * len;
        canvas.drawLine(Offset(x0, y), Offset(ex, ey), line
          ..strokeWidth = 2
          ..color = _trunk);
        for (var i = 2 + r.nextInt(4); i > 0; i--) {
          circle(ex + (r.nextDouble() - 0.5) * 9, ey + (r.nextDouble() - 0.5) * 7, 1.3 + r.nextDouble() * 1.5, _blc[r.nextInt(3)]);
        }
      }
    }

    // crown: back blossom layer, branches, front layers
    final cc = [for (final (x, y, r, c) in g.clumps) (tx(x), ty(y), r * sc, c)];
    for (final (x, y, r, c) in cc) {
      for (final (qx, qy, qr) in c.c) {
        circle(x + qx * r + 0.18 * r, y + qy * r + 0.2 * r, qr * r, _hex(0xc48ab3));
      }
    }
    final seed = _cl(1 - gg / 0.14);
    line.color = seed > 0 ? _mix(_trunk, _hex(0x7d9b7a), seed) : _trunk;
    for (final q in g.segs) {
      if (q == null) continue;
      line.strokeWidth = math.max(0.8, q.w * sc);
      canvas.drawPath(Path()..moveTo(tx(q.sx), ty(q.sy))..quadraticBezierTo(tx(q.mx), ty(q.my), tx(q.ex), ty(q.ey)), line);
    }
    if (seed > 0) {
      final s2 = (h * _s * 0.35).clamp(2.0, 7.0), x = tx(g.topX), y = ty(g.top);
      for (final sd in const [-1, 1]) {
        oval(x + sd * s2 * 0.7, y + s2 * 0.15, s2 * 0.75, s2 * 0.35, _al(_hex(0x8fb08a), seed), sd * -0.4);
      }
    }
    for (final (x, y, r, c) in cc) {
      for (final (qx, qy, qr) in c.c) {
        circle(x + qx * r, y + qy * r, qr * r * 0.9, _hex(0xe3a3c2));
      }
    }
    for (final (x, y, r, c) in cc) {
      for (final (qx, qy, qr) in c.c) {
        circle(x + qx * r - 0.18 * r, y + qy * r - 0.22 * r, qr * r * 0.55, _hex(0xf5c9dc));
      }
    }
    for (final (x, y, r, c) in cc) {
      for (final (qx, qy, qr, col) in c.sp) {
        circle(x + qx * r, y + qy * r, math.max(0.6, qr * r), _blc[col < 0.45 ? 0 : (col < 0.75 ? 1 : (col < 0.93 ? 2 : 3))]);
      }
    }

    // falling petals
    if (cc.length > 4) {
      for (final p in w.petals) {
        p.life += dt * 0.18;
        if (p.life >= 1 || !p.placed) {
          if (p.placed) p.life = 0;
          p.placed = true;
          final c = cc[w.rnd.nextInt(cc.length)];
          p.x = c.$1 + (w.rnd.nextDouble() - 0.5) * c.$3;
          p.y = c.$2;
        }
        final l = p.life, a = 0.85 * math.min(1, l * 5) * (1 - _cl((l - 0.7) / 0.3));
        oval(p.x + math.sin(t * 0.9 + p.p) * 8 - l * 30, p.y + l * 170 * math.max(0.5, sc), 2.4, 1.3, _al(_blc[p.c], a), t * 0.9 + p.p);
      }
    }

    // glowing tip, milestone ripples and blossom bursts
    {
      final o = Offset(tx(g.topX), ty(g.top) - 2), pu = 0.5 + 0.5 * math.sin(t * 1.8);
      shaded(ui.Gradient.radial(o, 22 + pu * 4, [const Color(0xB3ECE0FF), const Color(0x40D2BEFF), const Color(0x00C8B4FF)], [0, 0.35, 1]),
          () => canvas.drawCircle(o, 28, fill));
      circle(o.dx, o.dy, 2.4, const Color(0xFFF8F4FF));
      for (final t0 in w.ripples) {
        final p = (t - t0) / 1.4;
        if (p > 1 || p < 0) continue;
        canvas.drawCircle(o, 10 + 70 * _io(p), line
          ..strokeWidth = 1.4 * (1 - p) + 0.4
          ..color = _al(const Color(0xFFE1D2FF), (1 - p) * 0.6));
      }
      w.ripples.removeWhere((t0) => t - t0 > 1.4);
      for (final b in w.burst) {
        b.vy += 40 * dt;
        b.x += b.vx * dt;
        b.y += b.vy * dt;
        b.life -= dt * 0.7;
        if (b.life > 0) oval(o.dx + b.x, o.dy + b.y, 3, 1.7, _al(_blc[b.c], b.life), t * 2 + b.p);
      }
      w.burst.removeWhere((b) => b.life <= 0);
    }

    // progress to the Moon on the right edge
    {
      final rx = W - 12, y0 = 96 + topPad / k0, y1 = _vh - 24;
      double pos(double v) => y1 - (y1 - y0) * _cl((math.log(math.max(v, 0.03)) - math.log(0.03)) / (math.log(_moon) - math.log(0.03)));
      line.strokeCap = StrokeCap.butt;
      canvas.drawLine(Offset(rx, y0), Offset(rx, y1), line
        ..strokeWidth = 1
        ..color = const Color(0x38CDC4EA));
      line.color = const Color(0x80CDC4EA);
      for (final (v, _) in milestones) {
        canvas.drawLine(Offset(rx - 3, pos(v)), Offset(rx, pos(v)), line);
      }
      canvas.drawLine(Offset(rx, y1), Offset(rx, pos(h)), line
        ..strokeWidth = 1.6
        ..color = const Color(0xFFCDBFFF));
      circle(rx, pos(h), 2.6, const Color(0xFFF1EBFF));
      circle(rx, y0 - 8, 3.2, const Color(0xFFE8E4DA));
    }
    canvas.restore();
  }
}

void _cloud(Canvas canvas, Paint fill, double x, double y, double w, Color lit, Color shade) {
  const puffs = [(-0.4, 0.02, 0.11), (-0.2, -0.03, 0.16), (0.03, -0.06, 0.2), (0.25, -0.02, 0.15), (0.44, 0.025, 0.09)];
  fill.color = shade;
  canvas.drawOval(Rect.fromCenter(center: Offset(x, y + w * 0.05), width: w * 1.24, height: w * 0.15), fill);
  for (final (a, b, r) in puffs) {
    canvas.drawCircle(Offset(x + a * w, y + b * w + w * 0.03), r * w, fill);
  }
  fill.color = lit;
  for (final (a, b, r) in puffs) {
    canvas.drawCircle(Offset(x + a * w - r * w * 0.12, y + b * w - r * w * 0.1), r * w * 0.88, fill);
  }
}

typedef _Proj = double Function(double, double);

void _fuji(Canvas canvas, Paint fill, _Proj px, _Proj py, Color hz, double k) {
  const d = 35e3, x0 = -11e3;
  double fz(double x) {
    final u = (x - x0).abs() / 15e3;
    return u < 0.035 ? 3716 : (u >= 1 ? 0 : 3776 * math.pow(1 - u, 1.7).toDouble());
  }

  if (py(3776, d) >= _vh) return;
  final m = Path()..moveTo(px(x0 - 16e3, d), py(0, d) + 2);
  for (var x = x0 - 15e3; x <= x0 + 15e3; x += 300) {
    m.lineTo(px(x, d), py(fz(x), d));
  }
  m
    ..lineTo(px(x0 + 16e3, d), py(0, d) + 2)
    ..close();
  canvas.drawPath(m, fill..color = _mix(_hex(0x5a4a7a), hz, k));
  final r = math.Random(5), snow = Path()..moveTo(px(x0 - 4.2e3, d), py(fz(x0 - 4.2e3), d));
  for (var x = x0 - 4.2e3; x <= x0 + 4.2e3; x += 300) {
    snow.lineTo(px(x, d), py(fz(x), d) - 0.3);
  }
  for (var x = x0 + 4.2e3; x >= x0 - 4.2e3; x -= 600) {
    snow.lineTo(px(x, d), py(fz(x) - (r.nextDouble() < 0.5 ? 250 : 600), d));
  }
  canvas.drawPath(snow..close(), fill..color = _mix(_hex(0xf2e8f2), hz, k * 0.8));
}

void _chongqing(Canvas canvas, Paint fill, _Proj px, _Proj py, Color hz, double k, double t) {
  const d = 3500.0, s = _f / d;
  if (py(400, d) > _vh) return;
  final hill = Path()..moveTo(px(150, d), _vh + 5);
  for (var x = 150.0; x <= 3300; x += 40) {
    hill.lineTo(px(x, d), py(_cqBase(x) - (x < 500 ? (500 - x) * 0.25 : 0), d));
  }
  hill
    ..lineTo(px(3300, d), _vh + 5)
    ..close();
  canvas.drawPath(hill, fill..color = _mix(_hex(0x4a3868), hz, k));
  fill.color = _mix(_hex(0x33264f), hz, k * 0.9);
  final lights = <(double, double, bool)>[];
  for (final b in _city) {
    final z0 = _cqBase(b.x), x0 = px(b.x, d), w = math.max(1.2, b.w * s), top = py(z0 + b.h, d), bot = py(z0, d) + 2;
    canvas.drawRect(Rect.fromLTRB(x0 - w / 2, top, x0 + w / 2, bot), fill);
    if (b.ty == 1) {
      canvas.drawPath(Path()..moveTo(x0 - w * 0.3, top)..lineTo(x0, top - b.h * 0.14 * s)..lineTo(x0 + w * 0.3, top)..close(), fill);
    } else if (b.ty == 2) {
      canvas.drawRect(Rect.fromLTWH(x0 - w * 0.3, top - b.h * 0.06 * s, w * 0.6, b.h * 0.06 * s + 1), fill);
    }
    for (final (u, v) in b.lights) {
      lights.add((x0 + (u - 0.5) * w * 0.8, top + 2 + v * (bot - top - 4), false));
    }
    if (b.h > 230) lights.add((x0, top - (b.ty == 1 ? b.h * 0.14 * s : 0) - 1, true));
  }
  // Raffles City: four towers and the skybridge across their tops
  final z0 = _cqBase(560), tw = 40 * s;
  for (final (x, hh) in const [(470.0, 320.0), (530.0, 350.0), (590.0, 350.0), (650.0, 320.0)]) {
    final x0 = px(x, d), top = py(z0 + hh, d), bot = py(z0, d) + 2;
    canvas.drawPath(
        Path()
          ..moveTo(x0 - tw / 2, bot)
          ..lineTo(x0 - tw / 2, top + 3)
          ..quadraticBezierTo(x0, top - 2, x0 + tw / 2, top + 3)
          ..lineTo(x0 + tw / 2, bot)
          ..close(),
        fill);
  }
  canvas.drawRect(Rect.fromLTWH(px(445, d), py(z0 + 262, d), px(675, d) - px(445, d), math.max(1.5, 26 * s)), fill);
  fill.color = _al(const Color(0xFFFFE2BE), 0.7 * (1 - k));
  canvas.drawRect(Rect.fromLTWH(px(448, d), py(z0 + 250, d), px(672, d) - px(448, d), 1), fill);
  for (final (x, y, red) in lights) {
    fill.color = red
        ? _al(const Color(0xFFFF5A5A), (0.4 + 0.6 * (math.sin(t * 2.5 + x) > 0.3 ? 1 : 0)) * (1 - k))
        : _al(const Color(0xFFFFD6A0), 0.75 * (1 - k) * (0.6 + 0.4 * math.sin(t * 0.7 + x * 3)));
    canvas.drawRect(Rect.fromLTWH(red ? x - 0.6 : x, red ? y - 0.6 : y, red ? 1.3 : 1, red ? 1.3 : 1), fill);
  }
}

void _torii(Canvas canvas, Paint fill, double x, double base, double h, Color hz) {
  final pw = 0.55 * _f / 70, span = 5.6 * _f / 70;
  if (base - h >= _vh) return;
  fill.color = _mix(_hex(0xb4434f), hz, 0.18);
  for (final sd in const [-1, 1]) {
    canvas.drawRect(Rect.fromLTWH(x + sd * span / 2 - pw / 2, base - h * 0.9, pw, h * 0.9), fill);
  }
  canvas.drawRect(Rect.fromLTWH(x - h * 0.43, base - h * 0.76, h * 0.86, h * 0.05), fill);
  canvas.drawRect(Rect.fromLTWH(x - pw * 0.4, base - h * 0.9, pw * 0.8, h * 0.14), fill);
  Path beam(double hw, double y0, double sag, double hw2, double y1, double sag2) => Path()
    ..moveTo(x - hw, base - h * y0)
    ..quadraticBezierTo(x, base - h * sag, x + hw, base - h * y0)
    ..lineTo(x + hw2, base - h * y1)
    ..quadraticBezierTo(x, base - h * sag2, x - hw2, base - h * y1)
    ..close();
  canvas.drawPath(beam(h * 0.46, 0.945, 0.91, h * 0.44, 0.895, 0.87), fill);
  fill.color = _mix(_hex(0x22152c), hz, 0.15);
  canvas.drawPath(beam(h * 0.5, 1.01, 0.95, h * 0.47, 0.945, 0.905), fill);
}
