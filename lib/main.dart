
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gk/navbar/NavBar.dart';
import 'package:flutter_gk/pages/CRUDProduct.dart';
import 'package:flutter_gk/pages/ProductList.dart';
import 'package:flutter_gk/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  String title = "Product List"; // Tiêu đề mặc định
  var currentPage = DrawerSections.productList; // Product List làm mặc định

  signout()async{
    await FirebaseAuth.instance.signOut();
  }

  // Hàm để thay đổi nội dung body dựa trên section được chọn
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
        return signout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(
        onSectionSelected: (section) {
          setState(() {
            currentPage = section;

            // Cập nhật tiêu đề tương ứng
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

          Navigator.pop(context); // Đóng drawer
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(title, style: TextStyle(
          color: Colors.lightBlueAccent,
          fontWeight: FontWeight.bold,
        ),),
        centerTitle: true,
      ),
      body: _buildBody(), // Hiển thị nội dung dựa trên section
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
