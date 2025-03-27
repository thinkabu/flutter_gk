import 'package:flutter/material.dart';
import 'package:flutter_gk/service/database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController productTypeController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Thêm hàm xóa hình ảnh
  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  String? _convertImageToBase64(File? image) {
    if (image == null) return null;
    final bytes = image.readAsBytesSync();
    return base64Encode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Thêm",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Text(" Sản phẩm",
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20, top: 30, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Loại sản phẩm:",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8)),
                child: TextField(
                    controller: productTypeController,
                    decoration: InputDecoration(border: InputBorder.none)),
              ),
              SizedBox(height: 10),
              Text("Giá sản phẩm:",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8)),
                child: TextField(
                  controller: productPriceController,
                  decoration: InputDecoration(border: InputBorder.none),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 20),
              Text("Hình ảnh sản phẩm:",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8)),
                child: _image == null
                    ? Center(child: Text("Chưa chọn hình ảnh"))
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text("Chọn hình ảnh"),
                  ),
                  // Thêm nút xóa hình ảnh, chỉ hiển thị khi có hình ảnh
                  if (_image != null)
                    ElevatedButton(
                      onPressed: _removeImage,
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text("Xóa hình ảnh"),
                    ),
                ],
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (productTypeController.text.isEmpty ||
                        productPriceController.text.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "Vui lòng điền đầy đủ các trường bắt buộc",
                          backgroundColor: Colors.red);
                      return;
                    }

                    String id = randomAlphaNumeric(10);
                    String? imageBase64 = _convertImageToBase64(_image);

                    Map<String, dynamic> productInfoMap = {
                      "idsanpham": id,
                      "loaisanpham": productTypeController.text,
                      "gia": productPriceController.text,
                      "hinhanh": imageBase64,
                    };

                    await DatabaseMethods()
                        .addProductDetails(productInfoMap, id)
                        .then((value) {
                      Fluttertoast.showToast(
                        msg: "Thông tin sản phẩm đã được tải lên thành công",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      productTypeController.clear();
                      productPriceController.clear();
                      setState(() => _image = null);
                    }).catchError((error) {
                      Fluttertoast.showToast(
                          msg: "Lỗi khi tải sản phẩm: $error",
                          backgroundColor: Colors.red);
                    });
                  },
                  child: Text("Thêm",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
