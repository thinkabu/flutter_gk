import 'package:cloud_firestore/cloud_firestore.dart';

// CREATE
class DatabaseMethods {
  Future addProductDetails(
      Map<String, dynamic> productInfoMap, String idsanpham) async {
    return await FirebaseFirestore.instance
        .collection("Product")
        .doc(idsanpham)
        .set(productInfoMap);
  }
// READ
  Future<Stream<QuerySnapshot>> getProductDetails() async{
    return await FirebaseFirestore.instance.collection("Product").snapshots();
  }
// UPDATE
  Future updateProductDetails(String idsanpham, Map<String, dynamic> updateInfoMap) async{
    return await FirebaseFirestore.instance.collection("Product").doc(idsanpham).update(updateInfoMap);
  }
// DELETE
  Future deleteProductDetails(String idsanpham) async{
    return await FirebaseFirestore.instance.collection("Product").doc(idsanpham).delete();
  }
}