import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lockdownmart/screens/order.dart';

class ItemList extends StatefulWidget {
  final shop, user;

  ItemList({@required this.shop, @required this.user});

  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  var shop, user;
  String sid;
  Map<String, dynamic> list;
  final formKey = GlobalKey<FormState>();
  var total = 0;
  List<TextEditingController> tc =
      new List.generate(10, (i) => new TextEditingController());

  bool placingOrder = false;

  @override
  void initState() {
    super.initState();
    shop = widget.shop;
    sid = shop['Shop-Id'];
    print(sid);
    print(shop);
    user = widget.user;

    list = new Map<String, dynamic>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: <Widget>[
              CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.white,
                    centerTitle: true,
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () {
                            if (total < 1) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Please Enter any 1 item.'),
                              ));
                            } else {
                              showAlertDialog(context);
                            }
                          },
                          child: Text('Submit'))
                    ],
                    leading: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16)),
                        side: BorderSide(color: Colors.green, width: 2)),
                    title: Text(
                      'LockDown Mart',
                      style: TextStyle(fontFamily: 'Logo', color: Colors.black),
                    ),
                    expandedHeight: 210,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16)),
                          color: Colors.lightGreenAccent,
                        ),
                        height: MediaQuery.of(context).padding.top + 66,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              shop['Shop-Details']['Shop-Name'],
                              style:
                                  TextStyle(color: Colors.black, fontSize: 24),
                            ),
                            Text(
                              shop['Keeper-Details']['Keeper-Name'],
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 20),
                            ),
                            Text(
                              shop['Shop-Details']['Shop-Type'],
                              style: TextStyle(
                                  color: Colors.black38, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 16,
                    ),
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return new Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: new TextFormField(
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            onChanged: (value) {
                              setState(() {
                                if (value != "")
                                  list['Prod-' + (index + 1).toString()] =
                                      value;
                                else
                                  list['Prod-' + (index + 1).toString()] = '';
                                total = 0;
                                for (int i = 0; i < 10; i++) {
                                  if (list['Prod-' + (i + 1).toString()] !=
                                          null &&
                                      list['Prod-' + (i + 1).toString()] !=
                                          '') {
                                    total++;
                                  } else
                                    break;
                                }
                              });
                            },
                            controller: tc[index],
                            enabled: !placingOrder,
                            onEditingComplete: () {
                              if (index != 9)
                                FocusScope.of(context).nextFocus();
                              else
                                FocusScope.of(context).unfocus();
                            },
                            textInputAction: index == 9
                                ? TextInputAction.done
                                : TextInputAction.next,
                            decoration: InputDecoration(
                                prefixText: (index + 1).toString() + '  ',
                                labelText: 'Item ${index + 1}',
                                labelStyle: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 8),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.blue)),
                                fillColor: Colors.white),
                          ));
                    },
                    childCount: 10,
                  ))
                ],
              ),
              placingOrder
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          Text('Placing your Order....')
                        ],
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  Future<void> placeOrder() async {
    list['Prod-Count'] = total;
    list['Customer-Id'] = user['uid'];
    list['Customer-Name'] = user['Customer-Details']['Name'];
    list['Customer-Phone'] = user['Customer-Details']['Mobile'];
    list['Customer-Email'] = user['Customer-Details']['Email'];
    list['Time'] = FieldValue.serverTimestamp();
    list['Shop-Id'] = sid;
    list['Stage'] = 'S1';
    await Firestore.instance
        .collection('Shops')
        .document(sid)
        .collection('S1')
        .add(list)
        .then((value) => list['Order-Id'] = value.documentID);
    await Firestore.instance
        .collection('Shops')
        .document(sid)
        .collection('S1')
        .document(list['Order-Id'])
        .updateData({'Order-Id': list['Order-Id']});
    await Firestore.instance
        .collection("Customers")
        .document(list["Customer-Id"])
        .updateData({
      "Order-Details": {
        "Stage": "S1",
        "Shop-Id": list['Shop-Id'],
        "Order-Id": list["Order-Id"]
      }
    });
    setState(() {
      placingOrder = false;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Order()));
    });
  }

  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = FlatButton(
      child: Text(
        "OK",
        style: TextStyle(color: Colors.green),
      ),
      onPressed: () {
        setState(() {
          placingOrder = true;
          Navigator.of(context).pop();
          placeOrder();
        });
      },
    );
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.all(16),
      title: Text("Are you sure?"),
      content: Text("List cannot be changed once."),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
