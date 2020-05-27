import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lockdownmart/screens/home.dart';
import 'package:url_launcher/url_launcher.dart';

class Order extends StatefulWidget {
  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
  Map<String, dynamic> user, shop, order;
  Color bg;
  bool gotDetails = false;

  String status = '';

  var subStatus = '';

  var token;

  var loading = false;

  @override
  void initState() {
    super.initState();
    bg = Colors.blue[800];
    getDetails();
  }

  Future<void> getDetails() async {
    FirebaseAuth.instance.currentUser().then((usr) {
      Firestore.instance
          .collection('Customers')
          .document(usr.uid)
          .snapshots()
          .listen((det) {
        if (this.mounted) {
          user = det.data;
          user['uid'] = usr.uid;
          print(user.toString() + 'dfvgbhjkiuytgfvb');
          if (user['Order-Details'] != null) {
            setColor(user['Order-Details']['Stage']);
            if (!gotDetails) getShop();
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          }
        }
      });
    });
  }

  void getShop() {
    Firestore.instance
        .collection('Shops')
        .document(user['Order-Details']['Shop-Id'])
        .snapshots()
        .listen((det) {
      if (this.mounted) {
        setState(() {
          shop = det.data;
          if (!gotDetails) {
            gotDetails = true;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          title: Text(
            'LockDown Mart',
            style: TextStyle(fontFamily: 'Logo', color: Colors.black),
          ),
          centerTitle: true,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8))),
        ),
        body: AnimatedContainer(
            duration: Duration(seconds: 3),
            decoration: BoxDecoration(color: bg),
            child: Stack(
              children: <Widget>[
                gotDetails
                    ? SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Card(
                                elevation: 8,
                                shadowColor: Colors.black,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 4),
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                        text: 'Order-Id : ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'LogIn'),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: user['Order-Details']
                                                  ['Order-Id'],
                                              style: TextStyle(
                                                  color: Colors.green))
                                        ]),
                                  ),
                                ),
                              ),
                              user['Order-Details']['Stage'] == 'S3'
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Card(
                                          elevation: 8,
                                          shadowColor: Colors.black,
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12.0, horizontal: 4),
                                            child: Column(
                                              children: <Widget>[
                                                Text(
                                                  'Token: ${user['Order-Details']['Token']}',
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      color: Colors.green),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  shop['Pres-Token']
                                                              .toString() ==
                                                          '0'
                                                      ? 'Present Token: 1'
                                                      : 'Present Token: ${shop['Pres-Token']}',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          )),
                                    )
                                  : Container(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Card(
                                    elevation: 8,
                                    shadowColor: Colors.black,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0, horizontal: 4),
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            status,
                                            style: TextStyle(
                                                fontSize: 24,
                                                color: Colors.green),
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            subStatus,
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Card(
                                  elevation: 8,
                                  shadowColor: Colors.black,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Text(
                                          'Order',
                                          style: GoogleFonts.comfortaa(
                                              color: Colors.green,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  '#',
                                                  style: GoogleFonts.comfortaa(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text(
                                                  'Product',
                                                  style: GoogleFonts.comfortaa(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Text('Price',
                                                style: GoogleFonts.comfortaa(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                        StreamBuilder(
                                          stream: Firestore.instance
                                              .collection('Shops')
                                              .document(user['Order-Details']
                                                  ['Shop-Id'])
                                              .collection(user['Order-Details']
                                                  ['Stage'])
                                              .document(user['Order-Details']
                                                  ['Order-Id'])
                                              .snapshots(),
                                          builder: (context, snap) {
                                            if (snap.connectionState ==
                                                ConnectionState.waiting) {
                                              return LinearProgressIndicator();
                                            } else {
                                              if (snap.data.data != null) {
                                                order = snap.data.data;
                                                return Column(
                                                  children: <Widget>[
                                                    ListView.builder(
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            order['Prod-Count'],
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 4,
                                                                    horizontal:
                                                                        2),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Text((index +
                                                                            1)
                                                                        .toString()),
                                                                    SizedBox(
                                                                      width: 8,
                                                                    ),
                                                                    Container(
                                                                      width:
                                                                          200,
                                                                      child:
                                                                          Text(
                                                                        order['Prod-' +
                                                                            (index + 1).toString()],
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Container(
                                                                  width: 80,
                                                                  child: Text(
                                                                    order['Prod-' + (index + 1).toString() + '-Price'] ==
                                                                            null
                                                                        ? '--'
                                                                        : 'Rs.' +
                                                                            order['Prod-' +
                                                                                (index + 1).toString() +
                                                                                '-Price'],
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }),
                                                    order['Stage'] == 'S2'
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 2.0),
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'Total: Rs.${order['Total']}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    RaisedButton
                                                                        .icon(
                                                                      onPressed:
                                                                          () {
                                                                        if (!loading) {
                                                                          orderResponse(
                                                                              0);
                                                                        }
                                                                      },
                                                                      icon: Icon(
                                                                          Icons
                                                                              .close),
                                                                      label: Text(
                                                                          'Reject'),
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8)),
                                                                      color: Colors
                                                                          .red,
                                                                      textColor:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 16,
                                                                    ),
                                                                    RaisedButton
                                                                        .icon(
                                                                      onPressed:
                                                                          () {
                                                                        if (!loading) {
                                                                          orderResponse(
                                                                              1);
                                                                        }
                                                                      },
                                                                      icon: Icon(
                                                                          Icons
                                                                              .check),
                                                                      label: Text(
                                                                          'Accept'),
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8)),
                                                                      color: Colors
                                                                          .green,
                                                                      textColor:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : Container()
                                                  ],
                                                );
                                              } else
                                                return Container();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Card(
                                  elevation: 8,
                                  shadowColor: Colors.black,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                            width: 148,
                                            child: AspectRatio(
                                              aspectRatio: 4 / 3,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: FadeInImage(
                                                  placeholder: AssetImage(
                                                      'assets/images/1920x1080.png'),
                                                  image: NetworkImage(
                                                      /*shop['Shop-Details']
                                                            ['Shop-Image']*/
                                                      'https://images.pond5.com/4k-storefront-blank-posters-day-footage-073377394_prevstill.jpeg'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )),
                                        Container(
                                          width: 188,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                shop['Shop-Details']
                                                    ['Shop-Name'],
                                                textAlign: TextAlign.start,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.comfortaa(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                              Text(
                                                shop['Shop-Details']
                                                    ['Shop-Type'],
                                                textAlign: TextAlign.start,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.comfortaa(
                                                    fontWeight: FontWeight.w100,
                                                    fontSize: 12),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                shop['Shop-Details']['Address'],
                                                textAlign: TextAlign.start,
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.comfortaa(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Card(
                                  elevation: 8,
                                  shadowColor: Colors.black,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              shop['Keeper-Details']
                                                  ['Keeper-Name'],
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                _makePhoneCall(
                                                    'tel:${shop['Keeper-Details']['Mobile']}');
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.phone,
                                                      size: 14,
                                                    ),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    Text(
                                                      shop['Keeper-Details']
                                                          ['Mobile'],
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Text(
                                              shop['Keeper-Details']['Email'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        CircleAvatar(
                                            radius: 60,
                                            backgroundImage: NetworkImage(
                                                'https://images.unsplash.com/photo-1506919258185-6078bba55d2a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2015&q=80' /*shop['Keeper-Details']['Keeper-Image']*/)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Card(
                                  elevation: 8,
                                  shadowColor: Colors.black,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Container(
                                    height: 200,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                    child: new GoogleMap(
                                      key: UniqueKey(),
                                      mapType: MapType.normal,
                                      markers: {
                                        new Marker(
                                          markerId: MarkerId("Shop"),
                                          position: new LatLng(
                                              shop['Location']['Lat'],
                                              shop['Location']['Long']),
                                          draggable: false,
                                        )
                                      },
                                      buildingsEnabled: true,
                                      rotateGesturesEnabled: false,
                                      zoomGesturesEnabled: false,
                                      mapToolbarEnabled: false,
                                      zoomControlsEnabled: false,
                                      initialCameraPosition: CameraPosition(
                                          target: new LatLng(
                                              shop['Location']['Lat'],
                                              shop['Location']['Long']),
                                          zoom: 15),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : LinearProgressIndicator(),
                loading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[CircularProgressIndicator()],
                        ),
                      )
                    : Container()
              ],
            )));
  }

  void setColor(String stage) {
    setState(() {
      if (stage == 'S1') {
        bg = Colors.blue[800];
        status = 'Placed Order';
        subStatus = 'Waiting for Shopkeeper to Bill your List.';
      } else if (stage == 'S2') {
        bg = Colors.indigo[800];
        status = 'Billed';
        subStatus = 'Please Respond to the Bill.';
      } else if (stage == 'S3') {
        bg = Colors.greenAccent;
        status = 'In the Queue';
        subStatus = 'Your order will be packed soon.';
      } else if (stage == 'S4') {
        bg = Colors.green[400];
        status = 'Out for Pick-Up';
        subStatus = 'Shopkeeper is waiting with your order.';
      } else {
        bg = Colors.white;
      }
    });
  }

  Future<void> orderResponse(int i) async {
    setState(() {
      loading = true;
    });
    if (i == 1) {
      await Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot value = await transaction.get(
            Firestore.instance.collection('Shops').document(order['Shop-Id']));
        token = value.data['Token'] + 1;
        await transaction.update(
            Firestore.instance.collection('Shops').document(order['Shop-Id']),
            {'Token': value.data['Token'] + 1});
      });
      print(order);
      order['Stage'] = 'S3';
      order['Token'] = token;
      order['Time'] = FieldValue.serverTimestamp();
      await Firestore.instance
          .collection('Shops')
          .document(order['Shop-Id'])
          .collection('S3')
          .document(order['Order-Id'])
          .setData(order);
      await Firestore.instance
          .collection('Shops')
          .document(order['Shop-Id'])
          .collection('S2')
          .document(order['Order-Id'])
          .delete();
      await Firestore.instance
          .collection('Customers')
          .document(user['uid'])
          .updateData(
              {'Order-Details.Token': token, 'Order-Details.Stage': 'S3'});
      setState(() {
        loading = false;
      });
    } else {
      await Firestore.instance
          .collection('Shops')
          .document(order['Shop-Id'])
          .collection('S2')
          .document(order['Order-Id'])
          .delete();
      await Firestore.instance
          .collection('Customers')
          .document(user['uid'])
          .updateData({'Order-Details': FieldValue.delete()});
      setState(() {
        loading = false;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
