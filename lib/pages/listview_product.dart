import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:project_erp/model/product.dart';
import 'package:project_erp/pages/product_information.dart';
import 'package:project_erp/pages/product_screen.dart';

class ListViewProduct extends StatefulWidget {

  @override
  _ListViewProductState createState() => _ListViewProductState();
}

final productReference = FirebaseDatabase.instance.reference().child('product');


class _ListViewProductState extends State<ListViewProduct> {

  List<Product> items;
  StreamSubscription<Event> _onProductAddedSubsription;
  StreamSubscription<Event> _onProductChangeSubsription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    items= new List();
    _onProductAddedSubsription = productReference.onChildAdded.listen(_onProductAdded);
    _onProductChangeSubsription = productReference.onChildAdded.listen(_onProductChange);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _onProductChangeSubsription.cancel();
    _onProductAddedSubsription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       title: 'Productos Db',
       home: Scaffold(
         appBar: AppBar(
           title: Text('Producto información'),
           centerTitle: true,
           backgroundColor: Colors.deepPurple,
         ),
         body: Center(
           child: ListView.builder(
             itemCount: items.length,
             padding: EdgeInsets.only(top:12.0),
             itemBuilder: (context,i){
              return Column(
                children: <Widget>[
                  Divider(height: 7.0,),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          title: Text('${items[i].name}',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 21.0
                            ),
                          ),
                          subtitle: Text('${items[i].description}',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 21.0
                            ),
                          ),
                          leading: Column(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.amberAccent,
                                radius: 17.0,
                                child:  Text('${i+1}',
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 21.0
                                          ),
                                ),
                              )
                            ],
                          ),
                        onTap: ()=>_navigateToProductInformation(context,items[i]),
                        )
                      ),
                      IconButton(
                          icon: Icon(Icons.delete,color:Colors.red),
                          onPressed: ()=>_deleteProduct(context,items[i],i),
                      ),
                      IconButton(
                          icon: Icon(Icons.edit,color:Colors.blueAccent),
                          onPressed: ()=>_navigateToProduct(context,items[i]),
                      )
                    ],
                  )
                ],
              ); 
             },
          ),
         ),
         floatingActionButton: FloatingActionButton(
           child: Icon(Icons.add,color: Colors.white,),
           backgroundColor: Colors.deepOrangeAccent,
           onPressed: ()=>_createNewProduct(context),
          ),
       ),
    );
  }

  void _onProductAdded(Event event){
    setState(() {
      items.add(new Product.fromSnapShot(event.snapshot));
    });
  }

  void _onProductChange(Event event){
    var oldProductValue = items.singleWhere((product)=>product.id== event.snapshot.key);
    setState(() {
      items[items.indexOf(oldProductValue)] = new Product.fromSnapShot(event.snapshot);
    });
  }

  void _deleteProduct(BuildContext context ,Product product,int position) async{
    await productReference.child(product.id).remove().then((_){ 
      setState(() {
        items.removeAt(position);
      });
    });
  }

  void _navigateToProductInformation(BuildContext context ,Product product) async {
    await Navigator.push(context, 
      MaterialPageRoute(builder: (context)=>ProductScreen(product)),
    );
  }

  void _navigateToProduct(BuildContext context ,Product product) async{
    await Navigator.push(context, 
      MaterialPageRoute(builder: (context)=>ProductInformation(product)),
    );
  }

  void _createNewProduct(BuildContext context) async{
    await Navigator.push(context, 
      MaterialPageRoute(builder: (context)=>ProductScreen(Product(null,'','','','',''))),
    ); 
  }

}