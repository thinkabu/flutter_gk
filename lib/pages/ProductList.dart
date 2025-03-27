import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gk/service/database.dart';

class Productlist extends StatefulWidget {
  const Productlist({super.key});

  @override
  State<Productlist> createState() => _ProductlistState();
}

class _ProductlistState extends State<Productlist> {
  Stream? ProductStream;
  String searchQuery = ""; // Biến lưu từ khóa tìm kiếm
  String sortOption = "none"; // Biến lưu kiểu sắp xếp: "none", "asc", "desc"
  final TextEditingController _searchController = TextEditingController();

  getOnTheLoad() async {
    ProductStream = await DatabaseMethods().getProductDetails();
    setState(() {});
  }

  @override
  void initState() {
    getOnTheLoad();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  // Hàm lọc sản phẩm dựa trên từ khóa tìm kiếm
  List<DocumentSnapshot> filterProducts(List<DocumentSnapshot> docs) {
    if (searchQuery.isEmpty) {
      return docs; // Nếu không có từ khóa tìm kiếm, trả về toàn bộ danh sách
    }
    return docs.where((doc) {
      String loaiSanPham = doc["loaisanpham"]?.toString().toLowerCase() ?? "";
      return loaiSanPham.contains(searchQuery.toLowerCase());
    }).toList();
  }

  // Hàm sắp xếp sản phẩm dựa trên giá
  List<DocumentSnapshot> sortProducts(List<DocumentSnapshot> docs) {
    List<DocumentSnapshot> sortedDocs =
        List.from(docs); // Tạo bản sao danh sách

    if (sortOption == "asc") {
      // Sắp xếp tăng dần theo giá
      sortedDocs.sort((a, b) {
        double priceA = double.tryParse(a["gia"]?.toString() ?? "0") ?? 0;
        double priceB = double.tryParse(b["gia"]?.toString() ?? "0") ?? 0;
        return priceA.compareTo(priceB);
      });
    } else if (sortOption == "desc") {
      // Sắp xếp giảm dần theo giá
      sortedDocs.sort((a, b) {
        double priceA = double.tryParse(a["gia"]?.toString() ?? "0") ?? 0;
        double priceB = double.tryParse(b["gia"]?.toString() ?? "0") ?? 0;
        return priceB.compareTo(priceA);
      });
    }
    // Nếu sortOption là "none", không sắp xếp, trả về danh sách đã lọc
    return sortedDocs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(left: 20, top: 10, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // TextField tìm kiếm
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm loại sản phẩm...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    searchQuery = "";
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // Nút sắp xếp
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.sort,
                      color: sortOption == "none" ? Colors.grey : Colors.blue,
                    ),
                    onSelected: (value) {
                      setState(() {
                        sortOption = value;
                      });
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "none",
                        child: Text("Mặc định"),
                      ),
                      PopupMenuItem(
                        value: "asc",
                        child: Text("Giá: Tăng dần"),
                      ),
                      PopupMenuItem(
                        value: "desc",
                        child: Text("Giá: Giảm dần"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Danh sách sản phẩm
            Expanded(child: allProductDetails()),
          ],
        ),
      ),
    );
  }

  Widget allProductDetails() {
    return StreamBuilder(
      stream: ProductStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        // Lọc danh sách sản phẩm dựa trên từ khóa tìm kiếm
        List<DocumentSnapshot> filteredDocs =
            filterProducts(snapshot.data.docs);

        // Sắp xếp danh sách sản phẩm đã lọc dựa trên giá
        List<DocumentSnapshot> sortedDocs = sortProducts(filteredDocs);

        return sortedDocs.isEmpty
            ? Center(child: Text("Không tìm thấy sản phẩm nào"))
            : ListView.builder(
                itemCount: sortedDocs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot = sortedDocs[index];
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
                              height: 100,
                              width: 100,
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
                                        color: Colors.red,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
      },
    );
  }
}
