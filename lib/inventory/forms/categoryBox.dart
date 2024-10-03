import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryBox extends StatefulWidget {
  const CategoryBox({super.key});

  @override
  State<CategoryBox> createState() => _CategoryBoxState();
}

class _CategoryBoxState extends State<CategoryBox> {

  List<String> categories = [
    'Crema',
    'Botox',
    'Loquesea',
  ];

  String ? categorySel;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
          isExpanded: true,
      hint: const Text('Categoria del producto'),
      value: categorySel,
          items: categories.map((nameCategory) {
            return DropdownMenuItem(
                value: nameCategory,
                child: Align(
                  alignment: Alignment.centerLeft,//esta alineacion es para las opciones
                  child: Text(
                    nameCategory,
                  ),
                ));
          }).toList(),
        onChanged: (selection) {
          setState(() {
            categorySel = selection;
          });
        },
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFF4F2263),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.black54,
              width: 1.5,
            ),
          ),
        ),
        style: const TextStyle(fontSize: 18, color: Color(0xFF48454C)),
        icon: const Icon(Icons.arrow_drop_down),
          selectedItemBuilder: (BuildContext context) {
            return categories.map((String nameCategory) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    nameCategory,
                    style: const TextStyle(
                      color: Colors.black
                    ),
                  ),
                ],
              );
            }).toList();
          },
      );
  }
}
