import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoryBox extends StatefulWidget {
  final int borderType;
  const CategoryBox({super.key, required this.borderType});

  @override
  State<CategoryBox> createState() => _CategoryBoxState();
}

class _CategoryBoxState extends State<CategoryBox> {
  Map<String, dynamic>? categorySel;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }
  ///RECORDAR MANDAR A SERVCIO
  Future<void> fetchItems({int limit = 100, int offset = 0}) async {
    final String baseURL = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/categories';
    final response = await http.get(Uri.parse(baseURL + '?limit=$limit&offset=$offset'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      setState(() {
        items = data.map((item) {
          return {
            'id': item['id'],
            'category': item['nombre'],
            'image': item['foto'],
          };
        }).where((item) => item['category'] != null).toList();
      });
    } else {
      throw Exception('Error al obtener datos de la API');
    }
  }
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Map<String, dynamic>>(
      isExpanded: true,
      hint: widget.borderType == 2 ? Text('Categoria del producto', style: TextStyle(
        color: const Color(0xFF4F2263).withOpacity(0.5),
      ),) : const Text('Categoria del producto'),
      value: categorySel,
      items: items.map((categoryItem) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: categoryItem,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              categoryItem['category'] ?? 'Categoria Null',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      }).toList(),
      onChanged: (selectedCategory) {
        setState(() {
          categorySel = selectedCategory;
        });
      },
      decoration: InputDecoration(
        contentPadding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02,
            vertical: widget.borderType == 2 ? MediaQuery.of(context).size.width * 0.02 : 0),
        constraints: BoxConstraints(
          maxHeight: widget.borderType == 1 ? MediaQuery.of(context).size.width * 0.11 : MediaQuery.of(context).size.width * 0.5,
        ),
        focusedBorder: widget.borderType == 1 ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF4F2263),
            width: 0.7,
          ),
        ) : const OutlineInputBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: Color(0xFF4F2263),
            width: 0.7,
          ),
        ),
        enabledBorder: widget.borderType == 1 ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.black54,
            width: 1.5,
          ),
        ) : const OutlineInputBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: Colors.black54,
            width: 1.5,
          ),
        ),
      ),
      style: const TextStyle(fontSize: 18, color: Color(0xFF48454C)),
      icon: const Icon(Icons.arrow_drop_down),
      selectedItemBuilder: (BuildContext context) {
        return items.map((categoryItem) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                categoryItem['category'] ?? 'Categoria Null',
                style: const TextStyle(color: Colors.black),
              ),
            ],
          );
        }).toList();
      },
    );
  }
}
