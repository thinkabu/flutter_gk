import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gk/pages/AddProduct.dart';
import 'package:flutter_gk/service/database.dart';
import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class Crudproduct extends StatefulWidget {
  const Crudproduct({super.key});

  @override
  State<Crudproduct> createState() => _CrudproductState();
}

class _CrudproductState extends State<Crudproduct> {
  TextEditingController productTypeController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  Stream? ProductStream;
  File? _image;
  String? imageBase64; // Lưu trữ hình ảnh Base64 từ Firestore
  final ImagePicker _picker = ImagePicker();

  getOnTheLoad() async {
    ProductStream = await DatabaseMethods().getProductDetails();
    setState(() {});
  }

  @override
  void initState() {
    getOnTheLoad();
    super.initState();
  }

  // Hàm kiểm tra xem chuỗi có phải là Base64 hợp lệ không
  bool _isBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imageBase64 = _convertImageToBase64(
            _image); // Cập nhật imageBase64 khi chọn hình mới
      });
    }
  }

  // Hàm xóa hình ảnh
  void _removeImage() {
    setState(() {
      _image = null;
      imageBase64 = null; // Xóa cả imageBase64 khi xóa hình ảnh
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
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => AddProduct())),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20, top: 20, right: 20),
        child: Column(children: [Expanded(child: allProductDetails())]),
      ),
    );
  }

  Widget allProductDetails() {
    return StreamBuilder(
      stream: ProductStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
                  String imageData = documentSnapshot["hinhanh"] ?? "";

                  return Container(
                    margin: EdgeInsets.only(bottom: 15),
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: imageData.isEmpty || !_isBase64(imageData)
                                  ? Center(child: Text("Không có hình ảnh"))
                                  : Image.memory(
                                      base64Decode(imageData),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                            child: Text("Lỗi tải hình ảnh"));
                                      },
                                    ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Loại sản phẩm: " +
                                        documentSnapshot["loaisanpham"],
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Giá sản phẩm: " +
                                        documentSnapshot["gia"] +
                                        "\$",
                                    style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    productTypeController.text =
                                        documentSnapshot["loaisanpham"];
                                    productPriceController.text =
                                        documentSnapshot["gia"];
                                    // Khởi tạo imageBase64 và _image khi mở dialog chỉnh sửa
                                    setState(() {
                                      imageBase64 = documentSnapshot["hinhanh"];
                                      _image =
                                          null; // Đặt _image về null để không hiển thị hình mới ngay lập tức
                                    });
                                    EditProductDetail(
                                        documentSnapshot["idsanpham"]);
                                  },
                                  child: Icon(Icons.edit, color: Colors.amber),
                                ),
                                // Thêm: Xác nhận trước khi xóa sản phẩm
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Xác nhận xóa"),
                                        content: Text(
                                            "Bạn có muốn xóa sản phẩm '${documentSnapshot["loaisanpham"]}' không?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("Hủy",
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await DatabaseMethods()
                                                  .deleteProductDetails(
                                                      documentSnapshot[
                                                          "idsanpham"]);
                                              Navigator.pop(
                                                  context); // Đóng dialog xác nhận
                                            },
                                            child: Text("Xóa",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Future EditProductDetail(String id) => showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          // Sử dụng StatefulBuilder để cập nhật trạng thái trong dialog
          builder: (context, setState) {
            // Thêm setState cho dialog
            return AlertDialog(
              content: Container(
                margin: EdgeInsets.only(top: 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text("Sửa",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                Text(" Sản phẩm",
                                    style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(Icons.cancel)),
                        ],
                      ),
                      SizedBox(height: 20),
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
                            decoration:
                                InputDecoration(border: InputBorder.none)),
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
                        child: _image != null
                            ? Image.file(_image!, fit: BoxFit.cover)
                            : imageBase64 != null && _isBase64(imageBase64!)
                                ? Image.memory(
                                    base64Decode(imageBase64!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                          child: Text("Lỗi tải hình ảnh"));
                                    },
                                  )
                                : Center(child: Text("Chưa chọn hình ảnh")),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final XFile? pickedFile = await _picker
                                    .pickImage(source: ImageSource.gallery);
                                if (pickedFile != null) {
                                  setState(() {
                                    _image = File(pickedFile.path);
                                    imageBase64 = _convertImageToBase64(
                                        _image); // Cập nhật imageBase64
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize:
                                    Size(120, 40), // Giảm kích thước nút
                                padding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                              child: Text("Chọn hình ảnh"),
                            ),
                          ),
                          if (_image != null ||
                              (imageBase64 != null && _isBase64(imageBase64!)))
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _image = null;
                                    imageBase64 = null; // Xóa hình ảnh
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  minimumSize:
                                      Size(120, 40), // Giảm kích thước nút
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                ),
                                child: Text("Xóa hình ảnh"),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            Map<String, dynamic> updateInfoMap = {
                              "idsanpham": id,
                              "loaisanpham": productTypeController.text,
                              "gia": productPriceController.text,
                              "hinhanh":
                                  imageBase64, // Lưu hình ảnh đã cập nhật
                            };
                            // Thêm: Đóng dialog ngay lập tức trước khi cập nhật
                            Navigator.pop(context);
                            // Thực hiện cập nhật
                            await DatabaseMethods()
                                .updateProductDetails(id, updateInfoMap)
                                .then((value) {
                              setState(() {
                                _image = null; // Reset _image sau khi cập nhật
                                imageBase64 =
                                    null; // Reset imageBase64 sau khi cập nhật
                              });
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            minimumSize: Size(120, 40), // Giảm kích thước nút
                            padding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: Text("Cập nhật",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
}
