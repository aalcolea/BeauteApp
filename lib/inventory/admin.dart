import 'dart:ui';

import 'package:beaute_app/inventory/forms/productForm.dart';
import 'package:beaute_app/inventory/views/sellPoint/categories.dart';
import 'package:beaute_app/inventory/views/sellPoint/cart.dart';
import 'package:beaute_app/inventory/views/sellPoint/scanBarCode.dart';
import 'package:beaute_app/views/navBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:soundpool/soundpool.dart';
class adminInv extends StatefulWidget {
  const adminInv({super.key});

  @override
  State<adminInv> createState() => _adminInvState();
}

class _adminInvState extends State<adminInv> {

  bool _showBlurr = false;
  bool isDocLog = false;
  String currentScreen = "inventario";
  double? screenWidth;
  double? screenHeight;
  int _selectedScreen = 1;
  bool _hideBtnsBottom = false;
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool showScaner = false;
  String? scanedProd;
  Soundpool? pool;

  void _onHideBtnsBottom(bool hideBtnsBottom) {
    setState(() {
      _hideBtnsBottom = hideBtnsBottom;
    });
  }

  Future<void> soundScaner() async {
    Soundpool pool = Soundpool.fromOptions(options: SoundpoolOptions.kDefault);
    int soundId = await rootBundle.load('assets/sounds/store_scan.mp3').then((ByteData soundData){
      return pool.load(soundData);
    });
    int streamId = await pool.play(soundId);
  }

  void _onShowBlur(bool showBlur){
    setState(() {
      _showBlurr = showBlur;
    });
  }

  void onShowScan(bool closeScan){
    setState(() {
      showScaner = closeScan;
    });
  }

  void onScanProd(String? resultScanedProd){
    setState(() {
      scanedProd = resultScanedProd;
      showScaner = false;
      soundScaner();
    });
  }

  void _onItemSelected(int option){
    setState(() {
      print(option);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: navBar(onItemSelected: _onItemSelected, onShowBlur: _onShowBlur, isDoctorLog: isDocLog, currentScreen: currentScreen),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.04),
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.045,
                    right: MediaQuery.of(context).size.width * 0.025,
                    bottom: MediaQuery.of(context).size.width * 0.005
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _selectedScreen == 1
                                ? 'Inventario'//'$scanedProd'//
                                : _selectedScreen == 2
                                ? 'Venta'
                                : '',
                            style: TextStyle(
                              color: const Color(0xFF4F2263),
                              fontSize: screenWidth! < 370.00
                                  ? MediaQuery.of(context).size.width * 0.078
                                  : MediaQuery.of(context).size.width * 0.082,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(context,
                                CupertinoPageRoute(
                                  builder: (context) => ProductForm(),
                                ),
                              );
                            },
                            icon: Icon(
                              CupertinoIcons.add_circled_solid,
                              color: Color(0xFF4F2263),
                              size: MediaQuery.of(context).size.width * 0.1,
                            ),
                          ),
                          Builder(builder: (BuildContext context) {
                            return IconButton(
                              onPressed: () {
                                Scaffold.of(context).openEndDrawer();
                              },
                              icon: SvgPicture.asset(
                                'assets/imgLog/navBar.svg',
                                colorFilter: const ColorFilter.mode(Color(0XFF4F2263), BlendMode.srcIn),
                                width: MediaQuery.of(context).size.width * 0.105,
                              ),
                            );
                          }),
                        ],
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.045, left: MediaQuery.of(context).size.width * 0.045, bottom: MediaQuery.of(context).size.width * 0.025),
                        child: SizedBox(
                          height: showScaner ? MediaQuery.of(context).size.width * 0.18 : 37,//37
                          child: showScaner ? ScanBarCode(onShowScan: onShowScan, onScanProd: onScanProd) : TextFormField(
                            controller: searchController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Buscar producto...',
                              hintStyle: TextStyle(
                                  color: Color(0xFF4F2263).withOpacity(0.2)
                              ),
                              prefixIcon: Icon(Icons.search, color: Color(0xFF4F2263).withOpacity(0.2)),
                              suffixIcon: InkWell(
                                  onTap: () {
                                    setState(() {
                                      showScaner == false ? showScaner = true : showScaner = false;
                                    });
                                  },
                                  child: Icon(CupertinoIcons.barcode_viewfinder, color: Color(0xFF4F2263))
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: const Color(0xFF4F2263).withOpacity(0.2), width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: const Color(0xFF4F2263).withOpacity(0.2), width: 2.0),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15)
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF4F2263),
                          width: 2.5,
                      )),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, MediaQuery.of(context).size.width * 0.012),
                        ),
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(0, MediaQuery.of(context).size.width * -0.025),
                        )
                      ]
                    ),
                    child: Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.0,
                        bottom: MediaQuery.of(context).size.width * 0.02,
                        left: MediaQuery.of(context).size.width * 0.02,
                        right: _selectedScreen == 1
                            ? MediaQuery.of(context).size.width * 0.0
                            : MediaQuery.of(context).size.width * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _buildBody(),
                    ),
                  ),
                ),
                Visibility(
                  visible: !_hideBtnsBottom,
                  child: Container(
                    margin: EdgeInsets.only(
                        bottom: screenWidth! < 391
                            ? MediaQuery.of(context).size.width * 0.055
                            : MediaQuery.of(context).size.width * 0.02),
                    child: Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                setState(() {
                                  _selectedScreen = 1;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: SvgPicture.asset(
                                  'assets/imgLog/inv.svg',
                                  colorFilter: _selectedScreen == 1
                                      ? ColorFilter.mode(const Color(0xFF4F2263), BlendMode.srcIn)
                                      : ColorFilter.mode(const Color(0xFF4F2263).withOpacity(0.2), BlendMode.srcIn),
                                  width: MediaQuery.of(context).size.width * 0.12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.005,
                          height: MediaQuery.of(context).size.width * 0.15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1),
                            color: Color(0xFF4F2263).withOpacity(0.2),
                          ),
                        ),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                setState(() {
                                  if (mounted) {
                                    _selectedScreen = 2;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SvgPicture.asset(
                                  'assets/imgLog/cart.svg',
                                  colorFilter: _selectedScreen == 2
                                      ? ColorFilter.mode(const Color(0xFF4F2263), BlendMode.srcIn)
                                      : ColorFilter.mode(const Color(0xFF4F2263).withOpacity(0.2), BlendMode.srcIn),
                                  width: MediaQuery.of(context).size.width * 0.12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: _showBlurr,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(
                color: Colors.black54.withOpacity(0.3),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedScreen) {
      case 1:
        return Categories(onHideBtnsBottom: _onHideBtnsBottom, onShowBlur: _onShowBlur);
      case 2:
        return Cart(onHideBtnsBottom: _onHideBtnsBottom);
      case 3:
        return Container(
          color: Colors.green,
        );
      default:
        return Container(
          color: Colors.yellow,
        );
    }
  }

}
