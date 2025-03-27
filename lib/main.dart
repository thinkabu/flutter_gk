import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gk/navbar/NavBar.dart';
import 'package:flutter_gk/pages/CRUDProduct.dart';
import 'package:flutter_gk/pages/ProductList.dart';
import 'package:flutter_gk/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: wrapper(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String title = "Product List";
  var currentPage = DrawerSections.productList;

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Điều hướng về trang wrapper sau khi đăng xuất
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => wrapper()),
        (Route<dynamic> route) => false,
      );
      // Hiển thị thông báo đăng xuất thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng xuất thành công')),
      );
    } catch (e) {
      // Xử lý lỗi nếu đăng xuất thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đăng xuất: $e')),
      );
    }
  }

  Widget _buildBody() {
    switch (currentPage) {
      case DrawerSections.productList:
        return Productlist();
      case DrawerSections.crudProduct:
        return Crudproduct();
      case DrawerSections.favorite:
        return Container(
          child: Center(child: Text("Favorite Page")),
        );
      case DrawerSections.settings:
        return Container(
          child: Center(child: Text("Settings Page")),
        );
      case DrawerSections.exit:
        return FutureBuilder(
          future: _signOut(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            // Khi hoàn thành, điều hướng đã được xử lý trong _signOut
            return Container();
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(
        onSectionSelected: (section) {
          setState(() {
            currentPage = section;
            switch (section) {
              case DrawerSections.productList:
                title = "Product List";
                break;
              case DrawerSections.crudProduct:
                title = "CRUD Product";
                break;
              case DrawerSections.favorite:
                title = "Favorite";
                break;
              case DrawerSections.settings:
                title = "Settings";
                break;
              case DrawerSections.exit:
                title = "Exit";
                break;
            }
          });
          Navigator.pop(context);
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: TextStyle(
            color: Colors.lightBlueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }
}

enum DrawerSections {
  productList,
  crudProduct,
  favorite,
  settings,
  exit,
}
