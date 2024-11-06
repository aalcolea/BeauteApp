import 'dart:convert';

import 'package:beaute_app/inventory/stock/utils/listenerBlurr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../kboardVisibilityManager.dart';
import '../themes/colors.dart';
import 'package:http/http.dart' as http;
import 'products/views/products.dart';

class Seeker extends StatefulWidget {

  final void Function(
      bool,
      ) onShowBlur;
  final Listenerblurr listenerblurr;

  const Seeker({super.key, required this.onShowBlur, required this.listenerblurr,});

  @override
  State<Seeker> createState() => _SeekerState();
}

class _SeekerState extends State<Seeker> {

  late KeyboardVisibilityManager keyboardVisibilityManager;
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  double? screenWidth;
  bool hasMoreItems = true;
  final String baseURL = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/categories';
  late int selectedCategoryId;
  String? _selectedCategory;

  @override
  void initState() {
    keyboardVisibilityManager = KeyboardVisibilityManager();
    loadFirstItems();
    widget.listenerblurr.registrarObservador((newValue){

    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityManager.dispose();
    super.dispose();
  }

  int limit = 6;
  int offset = 0;
  List<Map<String, dynamic>> items = [];
  Future<void> loadFirstItems() async{
    try{
      setState(() {
        items.clear();
        offset = 0;
        hasMoreItems = true;
      });
      List<Map<String, dynamic>> fetchedItems = await fetchItems(limit: limit, offset: offset);
      setState(() {
        items = fetchedItems;
        offset += limit;
      });
      _ensureAddCatAtTheEnd();
    }catch(e){
      print('Error al cargar los items $e');
    }
  }
  Future<void> loadItems() async{
    if (!hasMoreItems) return;
    try{
      List<Map<String, dynamic>> fetchedItems = await fetchItems(limit: limit, offset: offset);
      setState(() {
        // Only add new items that don't already exist in the items list
        for (var newItem in fetchedItems) {
          bool exists = items.any((item) => item['id'] == newItem['id']);
          if (!exists) {
            items.add(newItem);
          }
        }

        if (fetchedItems.length < limit) {
          hasMoreItems = false; // No more items to load
        }
        offset += limit;
      });
      _ensureAddCatAtTheEnd();
      print(offset);
    }catch(e){
      print('Error al cargar mas productos $e');
    }
  }

  void _clearSelectedCategory() {
    setState(() {
      _selectedCategory = null;
    });
  }

  void _ensureAddCatAtTheEnd() {
    items.removeWhere((item) => item['category'] == 'addCat');
    for (int i = 5; i <= items.length; i += 6) {
      items.insert(i, {'category': 'addCat', 'id': 'addCat'});
    }
    if (items.length % 6 != 0) {
      items.add({'category': 'addCat', 'id': 'addCat'});
    }
  }

  Future<List<Map<String, dynamic>>> fetchItems({int limit = 6, int offset = 0}) async{
    final response = await http.get(Uri.parse(baseURL + '?limit=$limit&offset=$offset'));
    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item){
        return {
          'id' : item['id'],
          'category': item['nombre'],
          'image': item['foto'],
        };
      }).toList();
    }else{
      throw Exception('Error al obtener datos de la API');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    int itemsPerPage = 6;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Stack(
        children: [
          Container(
            color: AppColors.whiteColor,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.047),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.0),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        CupertinoIcons.back,
                        size: MediaQuery.of(context).size.width * 0.08,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      'Buscar',
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
                Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.02,
                            left: MediaQuery.of(context).size.width * 0.03,
                            bottom: MediaQuery.of(context).size.width * 0.025,
                            top: MediaQuery.of(context).size.width * 0.005
                          ),
                          child: Container(
                            color: Colors.transparent,
                            height: MediaQuery.of(context).size.width * 0.105,//37
                            child: TextFormField(
                              controller: searchController,
                              focusNode: focusNode,
                              autofocus: true,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Buscar producto...',
                                hintStyle: TextStyle(
                                    color: AppColors.primaryColor.withOpacity(0.2)
                                ),
                                prefixIcon: Icon(Icons.search, color: AppColors.primaryColor.withOpacity(0.2)),
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
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                  child: Text(
                    'Categorias',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: screenWidth! < 370.00
                          ? MediaQuery.of(context).size.width * 0.07
                          : MediaQuery.of(context).size.width * 0.075,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.01),
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (items.length / itemsPerPage).ceil(),
                      itemBuilder: (context, pageIndex) {
                        int startIndex = pageIndex * itemsPerPage;
                        int endIndex = startIndex + itemsPerPage - 1;
                        if (endIndex > items.length) {
                          endIndex = items.length;
                        }
                        var currentPageItems = items.sublist(startIndex, endIndex);
                        return GridView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisExtent: MediaQuery.of(context).size.width * 0.5
                            ),
                            itemCount: currentPageItems.length,
                            itemBuilder: (context, index) {
                              var item = currentPageItems[index];
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedCategoryId = item['id'];
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => Products(selectedCategory: item['category'].toString(), onBack: _clearSelectedCategory, selectedCategoryId: selectedCategoryId, onShowBlur: widget.onShowBlur,listenerblurr: widget.listenerblurr),
                                      ),
                                    );
                                  });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color: AppColors.whiteColor,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.blackColor.withOpacity(0.3),
                                              offset: const Offset(4, 4),
                                              blurRadius: 5,
                                              spreadRadius: 0.1,
                                            )
                                          ],
                                        ),
                                        height: MediaQuery.of(context).size.width * 0.35,
                                        width: MediaQuery.of(context).size.width * 0.4,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                item['image'],
                                                fit: BoxFit.contain,
                                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  } else {
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                            : null,
                                                      ),
                                                    );
                                                  }
                                                },
                                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                                  return const Text('Error al cargar la imagen');
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Text(
                                          "${item['category']}",
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: MediaQuery.of(context).size.height * 0.017,
                                          )
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                        );
                      }
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                  child: Text(
                    'Productos',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: screenWidth! < 370.00
                          ? MediaQuery.of(context).size.width * 0.07
                          : MediaQuery.of(context).size.width * 0.075,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          )
        ],
      )
    );
  }
}
