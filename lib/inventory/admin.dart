import 'dart:ui';

import 'package:beaute_app/agenda/utils/showToast.dart';
import 'package:beaute_app/agenda/utils/toastWidget.dart';
import 'package:beaute_app/inventory/sellpoint/processStuff/salesHistory.dart';
import 'package:beaute_app/inventory/stock/utils/listenerBlurr.dart';
import 'package:beaute_app/inventory/stock/products/forms/productForm.dart';
import 'package:beaute_app/inventory/stock/categories/views/categories.dart';
import 'package:beaute_app/inventory/sellpoint/cart/views/cart.dart';
import 'package:beaute_app/inventory/scanBarCode.dart';
import 'package:beaute_app/inventory/stock/products/views/products.dart';
import 'package:beaute_app/inventory/testPrinter/printService.dart';
import 'package:beaute_app/inventory/testPrinter/test2.dart';
import 'package:beaute_app/navBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:soundpool/soundpool.dart';

import 'themes/colors.dart';

class adminInv extends StatefulWidget {
  final bool docLog;
  const adminInv({super.key, required this.docLog});

  @override
  State<adminInv> createState() => _adminInvState();
}

class _adminInvState extends State<adminInv> {
  GlobalKey<ProductsState> productsKey = GlobalKey<ProductsState>();
  PrintService printService = PrintService();
  bool _showBlurr = false;
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
  final Listenerblurr _listenerblurr = Listenerblurr();

  void changeBlurr(){
    if (productsKey.currentState != null) {
      productsKey.currentState!.removeOverlay();
    }
    _listenerblurr.setChange(false);
  }

  void onHideBtnsBottom(bool hideBtnsBottom) {
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
    if (mounted) {
      setState(() {
        _showBlurr = showBlur;
      });
    }
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

  void onShowBlurr(bool showBlurr){
    setState(() {
      _showBlurr = showBlurr;
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

  void onPrintServiceComunication(PrintService printService){
    setState(() {
      print('printAdmin');
      this.printService = printService;
    });

  }

  @override
  Widget build(BuildContext context) {
      Widget _buildBody() {
        switch (_selectedScreen) {
          case 1:
            return Categories(productsKey: productsKey, onHideBtnsBottom: onHideBtnsBottom, onShowBlur: _onShowBlur, listenerblurr: _listenerblurr);
          case 2:
            return Cart(onHideBtnsBottom: onHideBtnsBottom, printService: printService, onShowBlurr: onShowBlurr);
          default:
            return Container();
        }
      }

    return Scaffold(
      endDrawer: navBar(onItemSelected: _onItemSelected, onShowBlur: _onShowBlur, isDoctorLog: widget.docLog, currentScreen: currentScreen,
        onPrintServiceComunication: onPrintServiceComunication),
      body: Stack(
        children: [
          Container(
            color: AppColors.whiteColor,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.045,
                      right: MediaQuery.of(context).size.width * 0.025,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _selectedScreen == 1
                                ? 'Inventario'//'$scanedProd'
                                : _selectedScreen == 2
                                ? 'Venta'
                                : '',
                            style: TextStyle(
                              color: AppColors.primaryColor,
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
                          Visibility(
                            visible: _selectedScreen == 1 ? true : false,
                            child: IconButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProductForm(),
                                ),
                              );
                              if (result == true) {
                                productsKey.currentState?.refreshProducts();
                              }
                            },
                            icon: Icon(
                              CupertinoIcons.add_circled_solid,
                              color: AppColors.primaryColor,
                              size: MediaQuery.of(context).size.width * 0.1,
                            ),
                          )),
                          Visibility(
                            visible: _selectedScreen == 2 ? true : false,
                            child: IconButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SalesHistory(),
                                ),
                              );
                            },
                            icon: Icon(
                              CupertinoIcons.tickets,
                              color: AppColors.primaryColor,
                              size: MediaQuery.of(context).size.width * 0.1,
                            ),
                          ),),
                          Builder(builder: (BuildContext context) {
                            return IconButton(
                              onPressed: () {
                                Scaffold.of(context).openEndDrawer();
                              },
                              icon: SvgPicture.asset(
                                'assets/imgLog/navBar.svg',
                                colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
                                width: MediaQuery.of(context).size.width * 0.105,
                              ),
                            );
                          }),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02, left: MediaQuery.of(context).size.width * 0.02, bottom: MediaQuery.of(context).size.width * 0.025),
                          child: Container(
                            color: Colors.transparent,
                            height: showScaner ? MediaQuery.of(context).size.width * 0.3 : 40,//37
                            child: showScaner ? ScanBarCode(onShowScan: onShowScan, onScanProd: onScanProd) : TextFormField(
                              controller: searchController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Buscar producto...',
                                hintStyle: TextStyle(
                                    color: AppColors.primaryColor.withOpacity(0.2)
                                ),
                                prefixIcon: Icon(Icons.search, color: AppColors.primaryColor.withOpacity(0.2)),
                                suffixIcon: InkWell(
                                    onTap: () {
                                      setState(() {
                                        showScaner == false ? showScaner = true : showScaner = false;
                                      });
                                    },
                                    child: const Icon(CupertinoIcons.barcode_viewfinder, color: AppColors.primaryColor)
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 2.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 2.0),
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
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.01),
                    decoration: const BoxDecoration(
                      color: AppColors.bgColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)
                        ),
                        border: Border(
                            bottom: BorderSide(
                              color: AppColors.primaryColor,
                              width: 2.5,
                            )),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.width * 0.02,
                        right: _selectedScreen == 1 ? MediaQuery.of(context).size.width * 0.0 : MediaQuery.of(context).size.width * 0.02,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _buildBody(),
                    ),
                  ),
                ),
                ///botones inferiores
                Visibility(
                  visible: !_hideBtnsBottom,
                  child: Container(
                    margin: EdgeInsets.only(bottom: screenWidth! < 391
                            ? MediaQuery.of(context).size.width * 0.055
                            : MediaQuery.of(context).size.width * 0.02),
                    padding: EdgeInsets.only(top: screenWidth! < 391
                            ? MediaQuery.of(context).size.width * 0.035
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
                                      ? const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn)
                                      : ColorFilter.mode(AppColors.primaryColor.withOpacity(0.2), BlendMode.srcIn),
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
                            color: AppColors.primaryColor.withOpacity(0.2),
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
                                      ? const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn)
                                      : ColorFilter.mode(AppColors.primaryColor.withOpacity(0.2), BlendMode.srcIn),
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
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showBlurr = false;
                      changeBlurr();
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppColors.blackColor.withOpacity(0.3),
                  ),
                )
            ),
          ),
        ],
      ),);
    //}));
  }
}
