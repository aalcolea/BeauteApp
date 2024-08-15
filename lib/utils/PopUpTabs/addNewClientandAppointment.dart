import 'package:flutter/material.dart';
import 'package:beaute_app/models/clientModel.dart';

class AddClientAndAppointment extends StatefulWidget {
  final String clientNamefromAppointmetForm;
  final VoidCallback onConfirm;
  final void Function(
    String,
    String,
    int,
  ) onSendDataToAppointmentForm;

  const AddClientAndAppointment(
      {super.key,
      required this.clientNamefromAppointmetForm,
      required this.onConfirm,
      required this.onSendDataToAppointmentForm});

  @override
  State<AddClientAndAppointment> createState() =>
      _AddClientAndAppointmentState();
}

class _AddClientAndAppointmentState extends State<AddClientAndAppointment> {
  final TextEditingController _clientNamefromAppointmetForm =
      TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  Client? _selectedClient;

  @override
  void initState() {
    super.initState();
    _clientNamefromAppointmetForm.text = widget.clientNamefromAppointmetForm;
    numberController.text = '9991974946';
    emailController.text = 'fly@fly';
  }

  void onSendDataToAppointmentForm() {
    setState(() {
      widget.onSendDataToAppointmentForm(
        _clientNamefromAppointmetForm.text,
        emailController.text,
        int.parse(numberController.text),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.02,
          right: MediaQuery.of(context).size.width * 0.02,
          top: MediaQuery.of(context).size.width * 0.01,
          bottom: MediaQuery.of(context).size.width * 0.085,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nuevo cliente',
                  style: TextStyle(
                    color: const Color(0xFF4F2263),
                    fontSize: MediaQuery.of(context).size.width * 0.075,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF4F2263),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.035,
                  bottom: MediaQuery.of(context).size.width * 0.02),
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.02,
                horizontal: MediaQuery.of(context).size.width * 0.02,
              ),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: const Color(0xFF4F2263),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Nombre del cliente:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextFormField(
              controller: _clientNamefromAppointmetForm,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03),
                hintText: 'Nombre completo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onTap: () {},
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.035,
                  bottom: MediaQuery.of(context).size.width * 0.02),
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.02,
                horizontal: MediaQuery.of(context).size.width * 0.02,
              ),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: const Color(0xFF4F2263),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'No. Celular:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextFormField(
              controller: numberController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03),
                hintText: 'No. Celular',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onTap: () {},
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.035,
                  bottom: MediaQuery.of(context).size.width * 0.02),
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.02,
                horizontal: MediaQuery.of(context).size.width * 0.02,
              ),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: const Color(0xFF4F2263),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Correo electrónico:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width * 0.07),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03),
                  hintText: 'Correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onTap: () {},
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onSendDataToAppointmentForm();
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                elevation: 8,
                surfaceTintColor: Colors.white,
                splashFactory: InkRipple.splashFactory,
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.0225,
                    horizontal: MediaQuery.of(context).size.width * 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: const BorderSide(color: Color(0xFF4F2263), width: 2),
                ),
                backgroundColor: Colors.white,
              ),
              child: Text(
                textAlign: TextAlign.center,
                'Agregar cliente \n y crear cita',
                style: TextStyle(
                  color: const Color(0xFF4F2263),
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
