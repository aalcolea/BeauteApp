import 'package:flutter/material.dart';

class AddAppointmentModal {
  static void showAddAppointmentModal(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //aqui falta anadir campos del furmulario, pero para eso necesito crear clientes
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Client ID',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa un ID';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {

                    }
                  },
                  child: Text('Crear Cita'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
