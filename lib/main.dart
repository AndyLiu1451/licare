import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_pet_log/config/router/app_router.dart'; // 稍后创建
import 'package:plant_pet_log/config/theme/app_theme.dart';
import 'package:plant_pet_log/services/notification_service.dart'; // 稍后创建

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 移除这里的初始化代码:
  // final notificationService = NotificationService(ProviderContainer()); // 移除
  // await notificationService.initialize();                         // 移除

  runApp(
    const ProviderScope(
      // ProviderScope 必须在 runApp 内部
      child: MyApp(),
    ),
  );

  // 移除这里的 reschedule 调用:
  // ProviderScope.containerOf(...) // 移除
}

// 在 MyApp 或某个地方定义一个全局 Key 用于获取 context (如果需要在 main 中调用 reschedule)
final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerStatefulWidget {
  // 1. 改为 ConsumerStatefulWidget
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState(); // 2. 创建 State
}

class _MyAppState extends ConsumerState<MyApp> {
  // 3. 创建 State 类

  @override
  void initState() {
    super.initState();
    // 4. 在 initState 中初始化通知服务 (确保只执行一次)
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // 使用 ref.read 获取服务实例并初始化
    // read 只获取一次，不会监听变化，适合初始化
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize();
      print('Notification Service Initialized.');

      // 初始化后，重新调度提醒 (确保数据库可用后执行)
      await notificationService.rescheduleAllActiveReminders();
      print('Reminders Rescheduled on App Start.');
    } catch (e) {
      print('Error initializing notifications or rescheduling: $e');
      // 可以考虑显示错误提示或记录日志
    }
  }

  @override
  Widget build(BuildContext context) {
    // 监听 GoRouter Provider，需要传入 navigatorKey
    final goRouter = ref.watch(goRouterProvider(navigatorKey));

    return MaterialApp.router(
      title: '植宠日志',
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      routerConfig: goRouter, // 使用 routerConfig
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
