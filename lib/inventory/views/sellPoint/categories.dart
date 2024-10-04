import 'dart:async';
import 'dart:convert';
import 'dart:ui';

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
  final void Function(
      bool,
      ) onShowBlur;

  const Categories({super.key, required this.onHideBtnsBottom, required this.onShowBlur});

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
  List<String> selectedCategories = [];
  bool isSelecting = false;

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

  void toggleSelection(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
        if (selectedCategories.isEmpty) {
          isSelecting = false; // Salir del modo de selección si no hay ninguna seleccionada
        }
      } else {
        selectedCategories.add(category);
        isSelecting = true; // Activar el modo de selección
      }
    });
    print("Selected Categories: $selectedCategories");
    print("Is Selecting: $isSelecting");
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
  int limit = 5;
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
          _selectedCategory == null
              ? Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.05),
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
                          endIndex = items.length;
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
                            return item['category'] == null ?
                            InkWell(
                              onTap: () {
                                if (isSelecting) {

                                } else {
                                  widget.onShowBlur(true);
                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.transparent,
                                    builder: (BuildContext context) {
                                      return CategoryForm();
                                    },
                                  ).then((_){
                                    widget.onShowBlur(false);
                                  });
                                }
                              },
                              child: Card(
                                color: Colors.transparent,
                                shadowColor: Colors.transparent,
                                child: Padding(
                                    padding: EdgeInsets.only(
                                        left: MediaQuery.of(context).size.width * 0.02,
                                        right: MediaQuery.of(context).size.width * 0.02
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            padding: const EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black54.withOpacity(0.3),
                                                  offset: const Offset(4, 4),
                                                  blurRadius: 5,
                                                  spreadRadius: 0.1,
                                                )
                                              ],
                                            ),
                                            height: MediaQuery.of(context).size.width * 0.35,
                                            width: MediaQuery.of(context).size.width * 0.5,
                                            child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Icon(
                                                  CupertinoIcons.add,
                                                  color: const Color(0xFF4F2263).withOpacity(0.3),
                                                  size: MediaQuery.of(context).size.width * 0.15,
                                                )
                                            )
                                        ),
                                      ],
                                    )
                                ),
                              ),
                            ) : InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelecting) {
                                    if (selectedCategories.contains(item['category'])) {
                                      selectedCategories.remove(item['category']);
                                      if (selectedCategories.isEmpty) {
                                        isSelecting = false;
                                      }
                                    } else {
                                      selectedCategories.add(item['category']);
                                    }
                                  } else {
                                    _selectedCategory = item['category'];
                                  }
                                });
                                print("${item['category']}");
                              },
                              onLongPress: () {
                                toggleSelection(item['category']);
                                print('Long Pressed on: ${item['category']}');
                              },
                              child: Card(
                                  color: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: MediaQuery.of(context).size.width * 0.02,
                                        right: MediaQuery.of(context).size.width * 0.02
                                    ),
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
                                                color: Colors.black54.withOpacity(0.3),
                                                offset: const Offset(4, 4),
                                                blurRadius: 5,
                                                spreadRadius: 0.1,
                                              )
                                            ],
                                          ),
                                          height: MediaQuery.of(context).size.width * 0.35,
                                          width: MediaQuery.of(context).size.width * 0.5,
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
                                              Visibility(
                                                visible: selectedCategories.contains(item['category']) ? true : false,
                                                child: Container(
                                                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.01, left: MediaQuery.of(context).size.width * 0.01),
                                                  alignment: Alignment.topLeft,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54.withOpacity(0.5),
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(
                                                      color: Color(0xFF4F2263),
                                                      width: MediaQuery.of(context).size.width * 0.01
                                                    )
                                                  ),
                                                  height: MediaQuery.of(context).size.width * 0.4,
                                                  width: MediaQuery.of(context).size.width * 0.5,
                                                  child: Icon(
                                                    CupertinoIcons.check_mark_circled,
                                                    color: Color(0xFF4F2263),
                                                  ),
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
                                                color: const Color(0xFF4F2263),
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
          ),
          if (isSelecting) Container(
            height: MediaQuery.of(context).size.height * 0.05,
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.62, bottom: MediaQuery.of(context).size.width * 0.01),
            child: Row(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      selectedCategories.clear();
                      isSelecting = false;
                    });
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.cancel),
                  heroTag: null,
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    print('Eliminar seleccionados');
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.delete, color: Colors.red,),
                  heroTag: null,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
