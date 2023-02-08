import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_getx/camera_widget.dart';
import 'package:learn_getx/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dbHelper = DatabaseHelper();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dbHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        // This is the theme of your application.
        primarySwatch: Colors.blue,
      ),
      // ignore: prefer_const_constructors
      home: MyHomePage(
        title: 'My App',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Future<void> getImageList() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    // prefs.setString("app-name", "my-app");
    // imageFiles? = await prefs.getStringList("imageFiles");
    List<String> myList = (prefs.getStringList('imageFiles') ?? <String>[]);
  }

  Future<void> clearLastItem() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    // prefs.setString("app-name", "my-app");
    // imageFiles? = await prefs.getStringList("imageFiles");
    List<String> myList = (prefs.getStringList('imageFiles') ?? <String>[]);

    String remove = prefs.getString("removeFile") ?? '';
    myList.remove(remove);
    prefs.setStringList('imageFiles', myList);
  }

  @override
  void initState() {
    super.initState();
    // getImageList();
  }

  void _incrementCounter() {
    getImageList();
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 1, 10, 1),
            child: Card(
              shadowColor: Colors.black,
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: ListTile(
                  title: Text('Diaogue Box'),
                  subtitle: Text('click here to open a dialogue box'),
                  onTap: (() {
                    Get.defaultDialog(
                      buttonColor: Colors.orange,
                      title: 'Are you sure about exit',
                      content: Text(''),
                      titlePadding: const EdgeInsets.all(10),
                      onConfirm: () {
                        Get.back();
                      },
                    );
                  }),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 1, 10, 1),
            child: Card(
              shadowColor: Colors.black,
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: ListTile(
                  title: Text('Bottomsheet'),
                  subtitle: Text('click here to open a botton sheet'),
                  onTap: (() {
                    Get.bottomSheet(Container(
                      child: Column(children: [
                        ListTile(
                          title: Text('Dark Theme'),
                          onTap: () {
                            Get.changeTheme(ThemeData.dark());
                          },
                        ),
                        ListTile(
                          title: Text('Light Theme'),
                          onTap: () {
                            Get.changeTheme(ThemeData.light());
                          },
                        ),
                      ]),
                    ));
                  }),
                ),
              ),
            ),
          ),
          const Text(
            'You have pushed the button this many times:',
          ),
          Text(
            '$_counter',
            style: Theme.of(context).textTheme.headline4,
          ),
          TextButton(
              onPressed: () {
                _counter = 0;
                clearLastItem();
                setState(() {});
              },
              child: const Text('Clear')),
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CameraExampleHome(
                            width: 130,
                            height: 40,
                          )),
                );
              },
              child: const Text('Navigate to Camera Screen'))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}
