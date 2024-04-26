import 'package:flutter/material.dart';

class DoctorSelectbox extends StatefulWidget {
  const DoctorSelectbox({
    Key? key,
  }) : super(key: key);

  @override
  _DoctorSelectboxState createState() => _DoctorSelectboxState();
}

class _DoctorSelectboxState extends State<DoctorSelectbox> {
  String? selectedDr;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> listDoctor = ['Doctor1', 'Doctor2'];
    return DropdownButtonFormField<String>(
      padding: EdgeInsets.zero,
      hint: const Row(
        children: [
          Text(
            'Doctor1 ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4F2263),
            ),
          ),
        ],
      ),
      value: selectedDr,
      items: listDoctor.map((nameDr) {
        return DropdownMenuItem<String>(
          value: nameDr,
          child: Container(
            color: selectedDr == nameDr
                ? const Color(0xFF4F2263)
                : Colors.transparent,
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  size: 40,
                  color: selectedDr == nameDr
                      ? Colors.white
                      : const Color(0xFF4F2263),
                ),
                Text(
                  nameDr,
                  style: TextStyle(
                      color: selectedDr == nameDr
                          ? Colors.white
                          : const Color(0xFF4F2263),
                      fontSize: 26),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedDr = newValue;
        });
      },
      decoration: const InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.5),
        ),
      ),
      style: const TextStyle(fontSize: 26, color: Color(0xFF48454C)),
      icon: const Icon(
        Icons.arrow_drop_down,
        color: Color(0xFF4F2263),
        size: 35,
      ),
      selectedItemBuilder: (BuildContext context) {
        return listDoctor.map(
          (String item) {
            return Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFF4F2263),
                  ),
                  Text(
                    item,
                    style:
                        const TextStyle(color: Color(0xFF4F2263), fontSize: 26),
                  ),
                ],
              ),
            );
          },
        ).toList();
      },
    );
  }
}
