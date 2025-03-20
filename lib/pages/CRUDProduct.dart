import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gk/pages/AddProduct.dart';
import 'package:flutter_gk/service/database.dart';

class Crudproduct extends StatefulWidget {
  const Crudproduct({super.key});

  @override
  State<Crudproduct> createState() => _CrudproductState();
}

class _CrudproductState extends State<Crudproduct> {

  TextEditingController productTypeController = new TextEditingController();
  TextEditingController productPriceController = new TextEditingController();

  Stream? ProductStream;

  getOnTheLoad()async{
    ProductStream = await DatabaseMethods().getProductDetails();
    setState(() {

    });
  }

  @override
  void initState() {
    getOnTheLoad();
    super.initState();
  }

  Widget allProductDetails(){
    return StreamBuilder(
        stream: ProductStream,
        builder: (context, AsyncSnapshot snapshot){
          return snapshot.hasData? ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index){
                DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Row(

                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Product Type: "+documentSnapshot["loaisanpham"],
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Product Price: "+documentSnapshot["gia"]+"\$",
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  productTypeController.text = documentSnapshot["loaisanpham"];
                                  productPriceController.text = documentSnapshot["gia"];
                                  EditProductDetail(documentSnapshot["idsanpham"]);
                                },
                                  child: Icon(Icons.edit, color: Colors.amber,)),
                              GestureDetector(
                                onTap: ()async{
                                  await DatabaseMethods().deleteProductDetails(documentSnapshot["idsanpham"]);
                                },
                                  child: Icon(Icons.delete, color: Colors.red,)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }): Container();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProduct()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20, top: 30, right: 20 ),
        child: Column(
          children: [
            Expanded(child: allProductDetails()),
          ],
        ),
      ),
    );
  }

  Future EditProductDetail(String id) => showDialog(context: context, builder: (context) => AlertDialog(
    content: Container(
      margin: EdgeInsets.only(top: 10,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      "Edit",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      " Product",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Icon(Icons.cancel),
              ),
            ],
          ),
          SizedBox(height: 20,),
          Text(
            "Product Type:",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(8)),
            child: TextField(
              controller: productTypeController,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Product Price:",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(8)),
            child: TextField(
              controller: productPriceController,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: ElevatedButton(
                onPressed: () async {
                  Map<String, dynamic> updateInfoMap = {
                    "id" : id,
                    "loaisanpham": productTypeController.text,
                    "gia": productPriceController.text,
                    "hinhanh": null,
                  };
                  await DatabaseMethods().updateProductDetails(id,updateInfoMap).then((value) {
                    Navigator.pop(context);
                  }) ;
                },
                child: Text(
                  "Update",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
          )
        ],
      ),
    ),
  ));
}
