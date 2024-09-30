import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
class Categories extends StatefulWidget {

  final void Function(
      bool,
      ) onHideBtnsBottom;

  const Categories({super.key, required this.onHideBtnsBottom});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {

  late StreamSubscription<bool> keyboardVisibilitySubscription;
  late KeyboardVisibilityController keyboardVisibilityController;
  bool visibleKeyboard = false;
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  String? _selectedCategory;

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
          setState(() {
            visibleKeyboard = visible;
            widget.onHideBtnsBottom(visibleKeyboard);
          });
        });
  }

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }

  void _onHideBtnsBottom(bool hideBtnsBottom) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
    loadFirstItems();
    print(offset);
  }

  @override
  void dispose() {
    keyboardVisibilitySubscription.cancel();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }
  ///test alan functiosn
  ///init tiene una function
  ///TODO ESTO IRA A UN SERVICIO
  int limit = 6;
  int offset = 0;
  List<Map<String, dynamic>> items = [];
  Future<void> loadFirstItems() async{
    try{
      List<Map<String, dynamic>> fetchedItems = await fetchItems(limit: limit, offset: offset);
      setState(() {
        items = fetchedItems;
        offset += limit;
      });
    }catch(e){
      print('Error al cargar los items $e');
    }
  }
  Future<void> loadItems() async{
    try{
      List<Map<String, dynamic>> fetchedItems = await fetchItems(limit: limit, offset: offset);
      setState(() {
        items.addAll(fetchedItems);
        offset += limit;
      });
      print(offset);
    }catch(e){
      print('Error al cargar mas productos $e');
    }
  }
  Future<List<Map<String, dynamic>>> fetchItems({int limit = 6, int offset = 0}) async{
    final String baseURL = 'http://192.168.101.139:8080/api/categories';
    final response = await http.get(Uri.parse(baseURL + '?limit=$limit&offset=$offset'));
    if(response.statusCode ==200){
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item){
        return {
          'category': item['nombre'],
          'image': item['foto'],
        };
      }).toList();
    }else{
      throw Exception('Error al obtener datos de la API');
    }
  }
///termian test alan functions

  List<Map<String, dynamic>> itemsTest = [
    {'category': 'Bloqueadores', 'image': 'assets/imgLog/categoriesImgs/bloqueador.png'},
    {'category': 'Botox', 'image': 'assets/imgLog/categoriesImgs/botox.png'},
    {'category': 'Cremas antiarrugas', 'image': 'assets/imgLog/categoriesImgs/cremaAnt.png'},
    {'category': 'Cremas hidratantes', 'image': 'assets/imgLog/categoriesImgs/cremaHidr.png'},
    {'category': 'Jeringas', 'image': 'assets/imgLog/categoriesImgs/jeringas.png'},
    {'category': 'Jirafas', 'image': 'assets/imgLog/categoriesImgs/jirafa.png'},
    {'category': 'Sandwiches', 'image': 'assets/imgLog/categoriesImgs/sandwich.png'},
    {'category': 'Balones', 'image': 'assets/imgLog/categoriesImgs/balon.png'},
    {'category': 'Jeringas', 'image': 'assets/imgLog/categoriesImgs/jeringas.png'},
    {'category': 'Jirafas', 'image': 'assets/imgLog/categoriesImgs/jirafa.png'},
    {'category': 'Sandwiches', 'image': 'assets/imgLog/categoriesImgs/sandwich.png'},
    {'category': 'Balones', 'image': 'assets/imgLog/categoriesImgs/balon.png'},
    {'category': 'Bloqueadores', 'image': 'assets/imgLog/categoriesImgs/bloqueador.png'},
    {'category': 'Botox', 'image': 'assets/imgLog/categoriesImgs/botox.png'},
    {'category': 'Cremas antiarrugas', 'image': 'assets/imgLog/categoriesImgs/cremaAnt.png'},
  ];

  List<Map<String, dynamic>> products = [
    {'product': 'Bloqueador 1', 'price': '59', 'cant': '5', 'product_id': '1'},
    {'product': 'Bloqueador 1', 'price': '59', 'cant': '5', 'product_id': '1'},
    {'product': 'Bloqueador 1', 'price': '59', 'cant': '5', 'product_id': '1'},
    {'product': 'Bloqueador 1', 'price': '59', 'cant': '5', 'product_id': '1'},
    {'product': 'Bloqueador 1', 'price': '59', 'cant': '5', 'product_id': '1'},
    {'product': 'Bloqueador 1', 'price': '59', 'cant': '5', 'product_id': '1'},
    {'product': 'Bloqueador 1', 'price': '59', 'cant': '5', 'product_id': '1'},
  ];
  @override
  Widget build(BuildContext context) {
    int itemsPerPage = 6;
    int pageCount = (items.length / itemsPerPage).ceil();
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.025,
                      left: MediaQuery.of(context).size.width * 0.025
                  ),
                  child: SizedBox(
                    height: 37,
                    child: TextFormField(
                      controller: searchController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Buscar producto...',
                        hintStyle: TextStyle(
                          color: const Color(0xFF4F2263).withOpacity(0.2),
                        ),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF4F2263)
                            .withOpacity(0.2)),
                        suffixIcon: InkWell(
                            onTap: () {
                              print('QR code');
                            },
                            child: const Icon(CupertinoIcons.barcode_viewfinder,
                                color: Color(0xFF4F2263))
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color(0xFF4F2263)
                              .withOpacity(0.2), width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              ///empeiza test alan
              ,
              ElevatedButton(
                onPressed: loadItems,
                child: Text('cargar mas datos'),
              ),
              ///termina test alan
            ],
          ),
          _selectedCategory == null
              ? Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: MediaQuery
                      .of(context)
                      .size
                      .width * 0.05),
                  child: SizedBox(
                    height: 580,
                    ///ENVOLVER EN NOTIFICATION DECIA GPT, AUN EN PRUEBAS
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                          loadItems();
                        }
                        return true;
                      },
                    child: PageView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: pageCount,
                      itemBuilder: (context, pageIndex) {
                        int startIndex = pageIndex * itemsPerPage;
                        int endIndex = startIndex + itemsPerPage;
                        if (endIndex > items.length) {
                          endIndex = items
                              .length; // Ajustar el índice si no hay más elementos
                        }
                        var currentPageItems = items.sublist(startIndex, endIndex);
                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            top: MediaQuery
                                .of(context)
                                .size
                                .width * 0.01,
                            bottom: MediaQuery
                                .of(context)
                                .size
                                .width * 0.01,
                            left: MediaQuery
                                .of(context)
                                .size
                                .width * 0.01,
                            right: MediaQuery
                                .of(context)
                                .size
                                .width * 0.01,
                          ),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemCount: currentPageItems.length,
                          itemBuilder: (context, index) {
                            var item = currentPageItems[index];
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (mounted) {
                                    _selectedCategory = "${item['category']}";
                                  }
                                });
                                print("${item['category']}");
                              },
                              child: Card(
                                  color: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.02, right: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.02),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(1),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black54.withOpacity(
                                                    0.3),
                                                offset: Offset(4, 4),
                                                blurRadius: 5,
                                                spreadRadius: 0.1,
                                              )
                                            ],
                                          ),
                                          height: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.35,
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.5,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.asset(
                                              item['image'],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),
                                    // Espacio entre imagen y texto
                                    Text(
                                        "${item['category']}",
                                        style: TextStyle(
                                          color: Color(0xFF4F2263),
                                          fontSize: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.045,
                                        )
                                    ),
                                  ],
                                ),
                              )
                          ),
                        );
                      },
                    ),
    ),
                  ),

                ),
              ),
            ),
          ) : Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF4F2263),
                          )
                      ),
                      Text(
                        '$_selectedCategory',
                        style: TextStyle(
                            fontSize: 28,
                            color: Color(0xFF4F2263)
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.01,
                        bottom: MediaQuery.of(context).size.width * 0.01,
                        left: MediaQuery.of(context).size.width * 0.01,
                        right: MediaQuery.of(context).size.width * 0.01,
                      ),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  'Producto $index',
                                  style: TextStyle(
                                    color: Color(0xFF4F2263),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Precio: 59 MXN' + ' ' + 'Cant.: 5',
                                  style: TextStyle(color: Color(0xFF4F2263)),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                              ),
                            ],
                          );
                        }
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}