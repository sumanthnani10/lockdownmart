import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'list.dart';

class ShopPage extends StatefulWidget {
  final shop, user;

  ShopPage({@required this.shop, @required this.user});

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage>
    with SingleTickerProviderStateMixin {
  var shop;

  @override
  void initState() {
    super.initState();
    shop = widget.shop;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(shop['Shop-Id']);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'LockDown Mart',
          style: TextStyle(fontFamily: 'Logo', color: Colors.black),
        ),
        centerTitle: true,
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
                bottomRight: Radius.circular(8),
                bottomLeft: Radius.circular(8))),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Hero(
                    tag: shop['Shop-Details']['Shop-Name'],
                    child: FadeInImage(
                      image: /*NetworkImage(shop['Shop-Details']['Shop-Image'])*/ NetworkImage(
                          'https://images.pond5.com/4k-storefront-blank-posters-day-footage-073377394_prevstill.jpeg'),
                      placeholder: AssetImage('assets/images/1920x1080.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Text(
                shop['Shop-Details']['Shop-Name'],
                style: TextStyle(fontSize: 24),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    shop['Shop-Details']['Shop-Type'],
                    style: TextStyle(fontSize: 14),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: Colors.green,
                      ),
                      Text(
                        '2 km',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                shop['Shop-Details']['Address'],
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.visible,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: RaisedButton.icon(
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                                  shop: shop,
                                  user: widget.user,
                                )));
                  },
                  icon: Icon(Icons.shopping_basket),
                  label: Text(
                    'Order Here',
                    style: TextStyle(fontSize: 16),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1506919258185-6078bba55d2a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2015&q=80' /*shop['Keeper-Details']['Keeper-Image']*/)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        shop['Keeper-Details']['Keeper-Name'],
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        shop['Keeper-Details']['Mobile'],
                        style: GoogleFonts.poppins(fontSize: 12),
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
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 300,
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: new GoogleMap(
                  key: UniqueKey(),
                  mapType: MapType.normal,
                  markers: {
                    new Marker(
                      markerId: MarkerId("Shop"),
                      position: new LatLng(
                          shop['Location']['Lat'], shop['Location']['Long']),
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
                          shop['Location']['Lat'], shop['Location']['Long']),
                      zoom: 15),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
