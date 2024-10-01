import 'dart:async';
import 'dart:convert';

import '../../forms/categoryForm.dart';
import 'products.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
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

  void _clearSelectedCategory() {
    setState(() {
      _selectedCategory = null;
    });
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
    final String baseURL = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/categories';
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
              /// Botón para cargar más datos
              ElevatedButton(
                onPressed: loadItems,
                child: Text('Cargar más datos'),
              ),
              SizedBox(width: 10),
              /// Botón para abrir el modal
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return CategoryForm();
                    },
                  ).then((_){
                    //agregar cerrar xd
                  });
                },
                child: Text('Crear Categoriaa'),
              ),
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
                            top: MediaQuery.of(context).size.width * 0.01,
                            bottom: MediaQuery.of(context).size.width * 0.01,
                            left: MediaQuery.of(context).size.width * 0.01,
                            right: MediaQuery.of(context).size.width * 0.01,
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
                                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02,right: MediaQuery.of(context)
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
                                                return Text('Error al cargar la imagen');
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          child: Text(
                                              "${item['category']}",
                                              style: TextStyle(
                                                color: Color(0xFF4F2263),
                                                fontSize: MediaQuery.of(context).size.height * 0.017,
                                              )
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                              ),
                            );
                          },
                        );
                      }
                    ),
                  ),
                ),
              ),
            ) : Expanded(
              child: Products(selectedCategory: _selectedCategory!, onBack: _clearSelectedCategory),
          )
        ],
      ),
    );
  }
}
