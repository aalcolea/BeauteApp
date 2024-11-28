import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../themes/colors.dart';
import '../../../../agenda/utils/showToast.dart';
import '../../../../agenda/utils/toastWidget.dart';

class CategoryService {
  final String baseURL = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/categories'; //'http://192.168.101.140:8080/api/categories';//

  Future<bool> updateCategoryInfo({required context, required int idCategory, required String name}) async{
    final url = Uri.parse(baseURL + '/$idCategory');

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor ingresa el nombre de la categoría")),
      );
    }

    try{
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nombre': name,
        }),
      );
      if(response.statusCode == 200){
        Navigator.of(context).pop(true);
        print('Categoría actualizada con éxito');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.08,
                bottom: MediaQuery.of(context).size.width * 0.08,
                left: MediaQuery.of(context).size.width * 0.02,
              ),
              content: Text('Categoría editada exitosamente',
                style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: MediaQuery.of(context).size.width * 0.045),)),
        );
        return true;
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.08,
                bottom: MediaQuery.of(context).size.width * 0.08,
                left: MediaQuery.of(context).size.width * 0.02,
              ),
              content: Text('Revise conexión a internet e intente de nuevo',
                style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: MediaQuery.of(context).size.width * 0.045),)),
        );
        throw Exception('Error al crear la categoría');
      }
    }catch(e){
      print('Error al editar la categoría');
      throw Exception('Error al modificar la categoría: $e');
    }
  }
}