//iyana Halliburton

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Calc {
  double? acc;
  String input = '0';
  String? op;
  bool waiting = false;
  bool result = false;
  String? error;
  String? message;

  String get display => error ?? input;
 
  String get pendingLine {
    if (acc != null && op != null) {
      return '${_fmt(acc!)} ${symbol(op!)}';
    }
    return '';
  } 

  static String symbol(String o) {
    if (o == 'x') return '×';
    if (o == '/') return '÷';
    if (o == '-') return '−';
    return o;
  } 

  double get _val {
      if (input.endsWith('.')) {
        return double.parse('${input}0');
      }
      return double.parse(input);
    }

  void clearAll() {
      acc = null;
      input = '0';
      op = null;
      waiting = false;
      result = false;
      error = null;
      message = null;
    }

    void digit(String d) {
    message = null;
    if (error != null || result) {clearAll();
    }
    if (waiting) {
      input = d;
      waiting = false;
    } else if (input.length < 12) {
      if (input == '0') {
          input = d;
      } else {
            input = input + d;
      }
    }
}
  void decimal() {
    message = null;
    if (error != null || result) 
    { clearAll();}
    if (waiting) {
      input = '0.';
      waiting = false;
    } else if (!input.contains('.')) {
      input += '.';
    }
  }
 
  void toggleSign() {
    message = null;
    if (error != null || waiting) return; 
    if (_val == 0) return; 
    if (input.startsWith('-')) {
      input = input.substring(1);
    } else {
      input = '-$input';
    }
  }
 
  void operator(String o) {
    message = null;
    if (error != null) return;
    if (result) {
      result = false;
      acc = _val;
      op = o;
      waiting = true;
      return;
    }
    if (op != null && waiting) {
      op = o; 
      return;
    }
    if (op != null) {
      final r = _apply(acc!, op!, _val);
      if (r == null) return;
      acc = r;
      input = _fmt(r);
    } else {
      acc = _val;
    }
    op = o;
    waiting = true;
  }
 
  void equals() {
    message = null;
    if (error != null || op == null) return;
    if (waiting) {
      message = 'Enter digit'; 
      return;
    }
    final r = _apply(acc!, op!, _val);
    if (r == null) return;
    input = _fmt(r);
    acc = null;
    op = null;
    waiting = false;
    result = true;
  }
 
  double? _apply(double a, String o, double b) {
    double result;
    switch (o) {
      case '+':
        result = a + b;
        break;
      case '-':
        result = a - b;
        break;
      case 'x':
        result = a * b;
        break;
      default:
        if (b == 0) return _fail('Cannot divide by zero');
        result = a / b;
    }
    if (result.isNaN || result.isInfinite) {
      return _fail('Answer too big');
    }
    return result;
  }
 
  double? _fail(String message) {
    error = message;
    acc = null;
    op = null;
    input = '0';
    waiting = false;
    result = false;
    return null;
  }
 
  static String _fmt(double r) {
    if (r == r.truncateToDouble() && r.abs() < 1e12) {
      return r.toInt().toString();
    }
    String s = r.toStringAsFixed(8);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s;
    }
}


class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 211, 14, 162),
          brightness: Brightness.dark,
      ),
    ),
    home: const CalcPage(title: 'Calculator'),
    );
  }
}
enum OpKind 
  {digit, 
  operator, 
  action, 
  equals}
 
class Operate{
  final String label;
  final String semantic;
  final VoidCallback onTap;
  final OpKind kind;
  final int flex;
  const Operate(this.label, this.semantic, this.onTap, this.kind,
      {this.flex = 1});
}

class CalcPage extends StatefulWidget {
  const CalcPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> {
    final Calc calc = Calc();

  void _do(VoidCallback action){
  setState(action);
}
 
  Operate _digit(String d) =>
      Operate(d, d, () => _do(() => calc.digit(d)), OpKind.digit);
 
  Operate _op(String o, String name) => Operate(
      Calc.symbol(o), name, () => _do(() => calc.operator(o)),
      OpKind.operator);

  Operate _zeroKey() {
    return Operate('0', '0', () => _do(() => calc.digit('0')), OpKind.digit,
        flex: 3);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    final rows = <List<Operate>>[
      [
        Operate('AC', 'All clear', () => _do(calc.clearAll), OpKind.action),
        Operate('±', 'Toggle positive negative', () => _do(calc.toggleSign),
            OpKind.action),
        _op('/', 'Divide'),
        _op('x', 'Multiply'),
      ],
      [_digit('7'), _digit('8'), _digit('9'), _op('-', 'Subtract')],
      [_digit('4'), _digit('5'), _digit('6'), _op('+', 'Add')],
      [
        _digit('1'),
        _digit('2'),
        _digit('3'),
        Operate('=', 'Equals', () => _do(calc.equals), OpKind.equals),
      ],
      [
      _zeroKey(),
        Operate('.', 'Decimal point', () => _do(calc.decimal), OpKind.digit),
      ],
    ];
 
    final isError = calc.error != null;
    String helperText = '';
    if (calc.message != null) {
      helperText = calc.message!;
    } else if (isError) {
      helperText = 'Clear';
    }
    
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(calc.pendingLine,
                        style: Theme.of(context).textTheme.titleLarge),
                    Semantics(
                      liveRegion: true,
                      child: FittedBox(
                         fit: BoxFit.scaleDown,
                        child: Text(
                          calc.display,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: isError ? 36 : 64,
                            fontWeight: FontWeight.w300,
                            color: isError
                                ? Theme.of(context).colorScheme.error
                                : null,
                          ),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 20,
                      child: Text(helperText,
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    for (final row in rows)
                      Expanded(
                        child: Row(
                          children: [
                            for (final key in row)
                              Expanded(
                                flex: key.flex,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: CalcButton(spec: key),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }
}


class CalcButton extends StatelessWidget {
  final Operate spec;
  const CalcButton({super.key, required this.spec});
 
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    if (spec.kind == OpKind.digit) {
      bg = colors.surfaceContainerHighest;
      fg = colors.onSurface;
    } else if (spec.kind == OpKind.operator) {
      bg = colors.secondaryContainer;
      fg = colors.onSecondaryContainer;
    } else if (spec.kind == OpKind.action) {
      bg = colors.tertiaryContainer;
      fg = colors.onTertiaryContainer;
    } else {
      bg = colors.primary;
      fg = colors.onPrimary;
    }
    return Semantics(
      button: true,
      label: spec.semantic,
      excludeSemantics: true,
      child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: spec.onTap,
            child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(spec.label,
                      style: TextStyle(fontSize: 28, color: fg),
                ),
              ),
            ),
          ),
        ),
    );
  }
}