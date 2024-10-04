import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryBox extends StatefulWidget {
  final int borderType;
  const CategoryBox({super.key, required this.borderType});

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
      hint: widget.borderType == 2 ? Text('Categoria del producto', style: TextStyle(
        color: const Color(0xFF4F2263).withOpacity(0.5),
      ),) : const Text('Categoria del producto'),
      value: categorySel,
          items: categories.map((nameCategory) {
            return DropdownMenuItem(
                value: nameCategory,
                child: Align(
                  alignment: Alignment.centerLeft,
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
      //
      //
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02,
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
