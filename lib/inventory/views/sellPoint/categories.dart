import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';
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
  }

  @override
  void dispose() {
    keyboardVisibilitySubscription.cancel();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> items = [
    {
      'category': 'Bloqueadores',
      'image': 'assets/imgLog/categoriesImgs/bloqueador.png'
    },
    {'category': 'Botox', 'image': 'assets/imgLog/categoriesImgs/botox.png'},
    {
      'category': 'Cremas antiarrugas',
      'image': 'assets/imgLog/categoriesImgs/cremaAnt.png'
    },
    {
      'category': 'Cremas hidratantes',
      'image': 'assets/imgLog/categoriesImgs/cremaHidr.png'
    },
    {
      'category': 'Jeringas',
      'image': 'assets/imgLog/categoriesImgs/jeringas.png'
    },
    {'category': 'Jirafas', 'image': 'assets/imgLog/categoriesImgs/jirafa.png'},
    {
      'category': 'Sandwiches',
      'image': 'assets/imgLog/categoriesImgs/sandwich.png'
    },
    {'category': 'Balones', 'image': 'assets/imgLog/categoriesImgs/balon.png'},
    {
      'category': 'Jeringas',
      'image': 'assets/imgLog/categoriesImgs/jeringas.png'
    },
    {'category': 'Jirafas', 'image': 'assets/imgLog/categoriesImgs/jirafa.png'},
    {
      'category': 'Sandwiches',
      'image': 'assets/imgLog/categoriesImgs/sandwich.png'
    },
    {'category': 'Balones', 'image': 'assets/imgLog/categoriesImgs/balon.png'},
    {
      'category': 'Bloqueadores',
      'image': 'assets/imgLog/categoriesImgs/bloqueador.png'
    },
    {'category': 'Botox', 'image': 'assets/imgLog/categoriesImgs/botox.png'},
    {
      'category': 'Cremas antiarrugas',
      'image': 'assets/imgLog/categoriesImgs/cremaAnt.png'
    },
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
                        );
                      },
                    ),
                  ),
                ),
              ) : Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.purple,
            ),
          )
        ],
      ),
    );
  }
}