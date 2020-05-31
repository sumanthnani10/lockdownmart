import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lockdownmart/screens/list.dart';
import 'package:lockdownmart/screens/order.dart';
import 'package:lockdownmart/screens/shoppage.dart';
import 'package:lockdownmart/services/push_nofitications.dart';
import 'package:google_maps_webservice/places.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic> user;
  final formKey = GlobalKey<FormState>();
  bool uploadingDetails = false, gotDetails = false, takingDetails = true;
  PushNotificationsManager _pushNotificationsManager;
  int c = 0;

  TextEditingController mailcont = new TextEditingController();
  TextEditingController namecont = new TextEditingController();
  GoogleMapController map;
  LatLng custLoc;
  Marker custMarker;
  Circle custCircle;
  Position position;
  String custAddress;
  double north, east, west, south;
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController addressEditor = new TextEditingController();
  List shops;

  bool uploadingLocation;

  @override
  void initState() {
    super.initState();
    custLoc = null;
    uploadingLocation = false;
    user = new Map<String, dynamic>();
    _pushNotificationsManager = new PushNotificationsManager();
    _pushNotificationsManager.init();
    getDetails();
    custMarker = Marker(
        markerId: MarkerId("Customer"),
        position: new LatLng(17.406622914697873, 78.48532670898436),
        draggable: true,
        onDragEnd: (newPos) {
          moveCamera(newPos);
        });
    custCircle = Circle(
        circleId: CircleId('Customer'),
        center: new LatLng(17.406622914697873, 78.48532670898436),
        strokeColor: Colors.green,
        radius: 3000,
        strokeWidth: 2);
  }

  Future<void> getCurrentLocation() async {
    if (custLoc != null) {
      moveToLocation(custLoc);
    } else {
      print(await Geolocator().checkGeolocationPermissionStatus());
      position = await Geolocator().getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          locationPermissionLevel: GeolocationPermission.locationWhenInUse);
      custLoc = new LatLng(position.latitude, position.longitude);
      moveToLocation(new LatLng(position.latitude, position.longitude));
    }
  }

  moveCamera(LatLng latLng) async {
    map.animateCamera(CameraUpdate.newCameraPosition(
        new CameraPosition(target: latLng, zoom: 15)));
    print("1234567890");
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    custAddress = placemark.elementAt(0).name +
        ',' +
        placemark.elementAt(0).subLocality +
        ',' +
        placemark.elementAt(0).subAdministrativeArea +
        ',' +
        placemark.elementAt(0).locality +
        ',' +
        placemark.elementAt(0).administrativeArea;
    addressEditor.text = custAddress;
  }

  moveToLocation(LatLng latLng) async {
    Marker marker = Marker(
        position: new LatLng(latLng.latitude, latLng.longitude),
        markerId: custMarker.markerId,
        draggable: true,
        onDragEnd: (newPos) {
          moveCamera(newPos);
        });
    custMarker = marker;
    custCircle = Circle(
        circleId: CircleId('Customer'),
        center: new LatLng(latLng.latitude, latLng.longitude),
        strokeColor: Colors.green,
        radius: 3000,
        strokeWidth: 2);
    if (c == 0) {
      setState(() {
        c = 1;
      });
    }
    map.moveCamera(CameraUpdate.newCameraPosition(
        new CameraPosition(target: latLng, zoom: 12.5)));
    print(latLng.toString() + custMarker.position.toString());
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    custAddress = placemark.elementAt(0).name +
        ',' +
        placemark.elementAt(0).subLocality +
        ',' +
        placemark.elementAt(0).subAdministrativeArea +
        ',' +
        placemark.elementAt(0).locality +
        ',' +
        placemark.elementAt(0).administrativeArea;
    addressEditor.text = custAddress;
  }

  Future<Null> locselect(
      Prediction p, GlobalKey<ScaffoldState> homeScaffoldKey) async {
    if (p != null) {
      PlacesDetailsResponse detailsResponse = await GoogleMapsPlaces(
              apiKey: "AIzaSyD3Mp-nbpxvDIUmjL9MWCDil6AypsFcCVQ")
          .getDetailsByPlaceId(p.placeId);
      custLoc = new LatLng(detailsResponse.result.geometry.location.lat,
          detailsResponse.result.geometry.location.lng);
      moveToLocation(new LatLng(detailsResponse.result.geometry.location.lat,
          detailsResponse.result.geometry.location.lng));
      setState(() {
        custAddress = p.description;
        addressEditor.text = custAddress;
      });
    }
  }

  void getDetails() {
    FirebaseAuth.instance.currentUser().then((usr) {
      user['uid'] = usr.uid;
      user['Mobile'] = usr.phoneNumber;
      Firestore.instance
          .collection('Customers')
          .document(usr.uid)
          .get()
          .then((det) async {
        if (det.data == null) {
          if (this.mounted) {
            setState(() {
              takingDetails = true;
            });
            showModalBottomSheet(
                context: context,
                elevation: 8,
                isScrollControlled: true,
                isDismissible: false,
                enableDrag: false,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8))),
                builder: (context) {
                  return buildModal();
                });
          }
        } else {
          //print(det.data);
          if (det.data['Order-Details'] != null) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Order()));
          } else {
            user = det.data;
            user['uid'] = usr.uid;
            if (user['Location'] != null) {
              north = user['Location']['Lat'] + (3.1 / 6378) * (180 / pi);
              east = user['Location']['Long'] + (3.2 / 6378) * (180 / pi);
              west = user['Location']['Long'] - (3.2 / 6378) * (180 / pi);
              south = user['Location']['Lat'] - (3.1 / 6378) * (180 / pi);
              /*double dis = await Geolocator().distanceBetween(user['Location']['Lat'], user['Location']['Long'], north, user['Location']['Long']);
            print(dis.toString()+'north');
            dis = await Geolocator().distanceBetween(user['Location']['Lat'], user['Location']['Long'], south, user['Location']['Long']);
            print(dis.toString()+'south');
            dis = await Geolocator().distanceBetween(user['Location']['Lat'], user['Location']['Long'], user['Location']['Lat'],east);
            print(dis.toString()+'east');
            dis = await Geolocator().distanceBetween(user['Location']['Lat'], user['Location']['Long'], user['Location']['Lat'],west);
            print(dis.toString()+'west');*/
              var qwe = await Firestore.instance
                  .collection('Shops')
                  .where('Location.Long', isLessThanOrEqualTo: east)
                  .where('Location.Long', isGreaterThanOrEqualTo: west)
                  .getDocuments();
              shops = qwe.documents;
              print('${shops.length} length');
              shops.sort((a, b) => (a['Shop-Details']['Shop-Name'])
                  .compareTo(b['Shop-Details']['Shop-Name']));
              shops = List.from(shops.where((a) {
                var i = 0;
                if (a['Location']['Lat'] <= north) i++;
                if (a['Location']['Lat'] >= south) i++;
                if (i == 2) {
                  return true;
                } else {
                  return false;
                }
              }));
              print(
                  '${shops[0].data['Shop-Details']['Shop-Name']} ${shops[1].data['Shop-Details']['Shop-Name']} ${shops[2].data['Shop-Details']['Shop-Name']} qwerfghjkloiuytgfgh');
            }
            if (this.mounted) {
              setState(() {
                gotDetails = true;
                takingDetails = false;
              });
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            title: Text(
              user['Location'] != null ? 'Choose a Store' : '',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            expandedHeight: user['Location'] != null ? 200 : 100,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: FadeInImage(
                placeholder: AssetImage('assets/images/1920x1080.png'),
                image: AssetImage('assets/images/ill.png'),
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          user['Location'] != null
              ? SliverToBoxAdapter(
                  child: FlatButton(
                    onPressed: () {},
                    child: Text(
                      'Stores',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                )
              : SliverToBoxAdapter(child: Container()),
          takingDetails
              ? SliverToBoxAdapter(child: Container())
              : gotDetails
                  ? user['Location'] != null
                      ?
                      /*StreamBuilder(
                  stream: Firestore.instance
                      .collection('Shops')
                      /*.where('Location.Lat',isLessThanOrEqualTo: north)
                      .where('Location.Lat',isGreaterThanOrEqualTo: south)
                      .where('Location.Long',isLessThanOrEqualTo: east)
                      .where('Location.Long',isGreaterThanOrEqualTo: west)*/
                      .orderBy('Shop-Details.Shop-Name')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverToBoxAdapter(
                          child: LinearProgressIndicator());
                    } else {
                      if (snapshot.data.documents.length == 0) {
                        return SliverToBoxAdapter(
                            child: Text('No Shops Near You'));
                      } else {
                        return SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                var snap = snapshot.data.documents[index].data;
                                return ShopCard(
                                  snap: snap,
                                  user: user,
                                );
                              },
                              childCount: snapshot.data.documents.length,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, childAspectRatio: 0.62));
                      }
                    }
                  },
                )*/
                      SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              print(
                                  '${shops[index].data['Shop-Details']['Shop-Name']} 1234567890');
                              return ShopCard(
                                snap: shops[index].data,
                                user: user,
                              );
                            },
                            childCount: shops.length,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, childAspectRatio: 0.62))
                      : SliverToBoxAdapter(
                          child: Stack(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    'Choose Your Location',
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.green),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  FlatButton.icon(
                                      color: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(8),
                                          side: new BorderSide(
                                              color: Colors.black, width: 0.5)),
                                      onPressed: () async {
                                        Prediction p =
                                            await PlacesAutocomplete.show(
                                                context: context,
                                                apiKey:
                                                    "AIzaSyD3Mp-nbpxvDIUmjL9MWCDil6AypsFcCVQ",
                                                mode: Mode.overlay,
                                                language: "en",
                                                components: [
                                              new Component(
                                                  Component.country, "in")
                                            ]);
                                        locselect(p, homeScaffoldKey);
                                      },
                                      icon: Icon(Icons.search),
                                      label: Text("Search Your Location")),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 0),
                                    height: 250,
                                    width: 400,
                                    child: GoogleMap(
                                      key: UniqueKey(),
                                      mapType: MapType.normal,
                                      markers: {custMarker},
                                      circles: {custCircle},
                                      buildingsEnabled: true,
                                      rotateGesturesEnabled: true,
                                      zoomGesturesEnabled: true,
                                      myLocationEnabled: true,
                                      initialCameraPosition: CameraPosition(
                                          target: LatLng(17.406622914697873,
                                              78.48532670898436),
                                          zoom: 10.9),
                                      onLongPress: (lloc) {
                                        custLoc = lloc;
                                        moveToLocation(lloc);
                                        setState(() {});
                                      },
                                      onTap: (a) {
                                        moveCamera(custMarker.position);
                                        setState(() {});
                                      },
                                      onMapCreated: (GoogleMapController c) {
                                        map = c;
                                        getCurrentLocation();
                                      },
                                    ),
                                  ),
                                  FlatButton.icon(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.warning,
                                      color: Colors.red,
                                      size: 12,
                                    ),
                                    label: Text(
                                      'Orders can be placed at Stores located in 3km radius as per Govt. guidelines.',
                                      style: TextStyle(fontSize: 8),
                                    ),
                                    padding: const EdgeInsets.all(0),
                                  ),
                                  new TextFormField(
                                    maxLines: 4,
                                    controller: addressEditor,
                                    keyboardType: TextInputType.text,
                                    enabled: false,
                                    style: TextStyle(fontSize: 12),
                                    decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 16, horizontal: 16),
                                        disabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8),
                                            borderSide: new BorderSide(
                                                color: Colors.green)),
                                        labelText: 'Address',
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(8),
                                            borderSide: new BorderSide(
                                                color: Colors.amber)),
                                        fillColor: Colors.white),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  RaisedButton.icon(
                                    onPressed: () {
                                      if (custLoc != null) {
                                        setState(() {
                                          uploadingLocation = true;
                                          uploadLoc();
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.check),
                                    label: Text('Submit'),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    color: Colors.greenAccent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  )
                                ],
                              ),
                            ),
                            uploadingLocation
                                ? Container(
                                    height: 300,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          CircularProgressIndicator(),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text('Updating your Location')
                                        ],
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        ))
                  : SliverToBoxAdapter(child: LinearProgressIndicator())
        ],
      ),
    );
  }

  Widget buildModal() {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Wrap(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        'Welcome!',
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Fill Your Details',
                        style: TextStyle(fontSize: 24, color: Colors.green),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Form(
                            key: formKey,
                            child: Column(
                              children: <Widget>[
                                new TextFormField(
                                  controller: namecont,
                                  enabled: !uploadingDetails,
                                  maxLines: 1,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  validator: (cname) {
                                    if (cname.isEmpty) {
                                      return "Please enter your Your Name.";
                                    } else {
                                      user['Name'] = cname;
                                      return null;
                                    }
                                  },
                                  onEditingComplete: () {
                                    FocusScope.of(context).nextFocus();
                                  },
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                      labelText: 'Name',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: Colors.green)),
                                      fillColor: Colors.white),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                new TextFormField(
                                  controller: mailcont,
                                  maxLines: 1,
                                  enabled: !uploadingDetails,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.done,
                                  validator: (cmail) {
                                    if (cmail.isEmpty) {
                                      return "Please enter your Your Email.";
                                    } else if (EmailValidator.validate(cmail)) {
                                      user['Email'] = cmail;
                                      return null;
                                    } else {
                                      return 'Enter valid Email Id';
                                    }
                                  },
                                  onEditingComplete: () {
                                    FocusScope.of(context).nextFocus();
                                  },
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                      labelText: 'Email',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: Colors.green)),
                                      fillColor: Colors.white),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                RaisedButton.icon(
                                  onPressed: () {
                                    if (formKey.currentState.validate()) {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        uploadingDetails = true;
                                      });
                                      uploadDetails();
                                    }
                                  },
                                  icon: Icon(Icons.check),
                                  label: Text('Submit'),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  color: Colors.greenAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                )
                              ],
                            )),
                      )
                    ],
                  ),
                  uploadingDetails
                      ? Container(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CircularProgressIndicator(),
                                SizedBox(
                                  height: 4,
                                ),
                                Text('Updating your Details')
                              ],
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> uploadDetails() async {
    await Firestore.instance
        .collection('Customers')
        .document(user['uid'])
        .setData({
      'Customer-Details': {
        'Name': user['Name'],
        'Email': user['Email'],
        'Mobile': user['Mobile']
      }
    });
    setState(() {
      uploadingDetails = false;
      takingDetails = false;
    });
    Navigator.of(context).pop();
    getDetails();
  }

  Future<void> uploadLoc() async {
    await Firestore.instance
        .collection('Customers')
        .document(user['uid'])
        .updateData({
      'Location': {
        'Lat': custLoc.latitude,
        'Long': custLoc.longitude,
        'Address': custAddress
      }
    });
    setState(() {
      uploadingLocation = false;
    });
    getDetails();
  }
}

class ShopCard extends StatefulWidget {
  final snap, user;

  ShopCard({@required this.snap, @required this.user});

  @override
  _ShopCardState createState() => _ShopCardState();
}

class _ShopCardState extends State<ShopCard>
    with SingleTickerProviderStateMixin {
  var snap;
  Image _image;
  AnimationController _animationController;
  Animation<double> _animation;

  double elev = 0;

  @override
  void initState() {
    super.initState();
    snap = widget.snap;
    _animationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    _animation = Tween(begin: 0.0, end: 4.0).animate((_animationController));
    _animationController.addListener(() {
      setState(() {});
    });
    _image = Image.network(snap['Shop-Details']['Shop-Image']);
    _image.image
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((_, __) {
      if (mounted) {
        setState(() {
          _animationController.forward();
        });
      }
    }));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(bottom: _animation.value / 2),
        child: Card(
          elevation: _animation.value * 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.greenAccent)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Hero(
                    tag: snap['Shop-Details']['Shop-Name'],
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ShopPage(
                                        shop: snap,
                                        user: widget.user,
                                      )));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: FadeInImage(
                              image: /*NetworkImage(snap['Shop-Details']['Shop-Image'])*/ NetworkImage(
                                  'https://images.pond5.com/4k-storefront-blank-posters-day-footage-073377394_prevstill.jpeg'),
                              placeholder:
                                  AssetImage('assets/images/1920x1080.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShopPage(
                                    shop: snap,
                                    user: widget.user,
                                  )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        snap['Shop-Details']['Shop-Name'],
                        style: TextStyle(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      snap['Shop-Details']['Shop-Type'],
                      style: TextStyle(fontSize: 12, color: Colors.black38),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      snap['Keeper-Details']['Keeper-Name'],
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w200),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: RaisedButton.icon(
                    splashColor: Colors.green,
                    animationDuration: Duration(seconds: 2),
                    color: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ItemList(
                                    shop: snap,
                                    user: widget.user,
                                  )));
                    },
                    icon: Icon(Icons.shopping_basket),
                    label: Text('Order Here')),
              )
            ],
          ),
        ),
      ),
    );
  }
}
