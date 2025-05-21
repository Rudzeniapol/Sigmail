import 'package:flutter/material.dart';

void main() => runApp(MyApp());
Color appBarColor = Color.fromARGB(255, int.parse('3B', radix: 16),int.parse('4F', radix: 16), int.parse('68', radix: 16));
Color backColor = Color.fromARGB(255, int.parse('33', radix: 16),int.parse('44', radix: 16), int.parse('5B', radix: 16));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Пример AppBar',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: Builder(
          builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
                color: Colors.white,
              ),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Введите текст...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontWeight: FontWeight.w700, fontSize: 18),
              )
            : Text('Sigmail', style: TextStyle(color: Colors.white, fontStyle:FontStyle.normal, fontWeight: FontWeight.w700),),
        actions: [
          _isSearching
              ? IconButton(
                  icon: Icon(Icons.close),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: backColor,
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('Меню', style: TextStyle(color: Colors.white),),
            ),
            ListTile(
              title: Text('Пункт 1', style: TextStyle(color: Colors.white),),
            ),
            ListTile(
              title: Text('Пункт 2', style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('sss')
      ),
    );
  }
}