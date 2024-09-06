import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alphabet_list_view/alphabet_list_view.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../forms/clientForm.dart';
import '../../styles/AppointmentStyles.dart';
import 'clientInfo.dart';

// Define el modelo de datos para los nombres
class Person {
  String name;
  String tag;

  Person(this.name) : tag = name.isNotEmpty ? name[0].toUpperCase() : '#';
}

class ClientDetails extends StatefulWidget {
  final void Function(
      bool,
      ) onHideBtnsBottom;  const ClientDetails({super.key, required this.onHideBtnsBottom});

  @override
  State<ClientDetails> createState() => _ClientDetailsState();
}

class _ClientDetailsState extends State<ClientDetails> {

  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;
  bool platform = false;
  double previousOffset = 0;

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
          setState(() {
            print('estoy en clientdetails');
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

  void _onFinishedAddClient(int initScreen, bool forShowBtnAfterAddclient) {
    setState(() {
    });
  }

  void _onHideBtnsBottom(bool hideBtnsBottom) {
    setState(() {
    });
  }

  List<String> nombres = [
    'Alan Alcolea', 'Banana Barrios', 'Colin Colon', 'Dorito Duran', 'Ector Eslobaco',
    'Facundo Ferros', 'Galo Galindo', 'Hector Horacio', 'Ignacion Indigp', 'Juan Jocoso',
    'Karmelo Kokoro', 'Luis Lomo', 'Mario Mono', 'Noe Nala', 'Ñoño Ñari', 'Orlando Olgon',
    'Puerto Pablo', 'Query Quando', 'Ross Roma', 'Saul Sosa', 'Tulip Taran', 'Umberto Ugly',
    'Victor Vazquez', 'Waldos Wall', 'Xari Xool', 'Yarizta Yale', 'Zarita Zolin'
  ];

  late List<AlphabetListViewItemGroup> _alphabetizedData;
  late ScrollController scrollController;

  Future<void> addClient() async {
    return showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: Container(
                  color: Colors.black54.withOpacity(0.3),
                ),
              ),
              ClientForm(
                    onHideBtnsBottom: _onHideBtnsBottom,
                    onFinishedAddClient: _onFinishedAddClient),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(onScroll);
    _alphabetizedData = _createAlphabetizedData(nombres);
    keyboardVisibilityController = KeyboardVisibilityController();
    Platform.isIOS ? platform = false : platform = true;
    checkKeyboardVisibility();
    super.initState();
  }

  @override
  void dispose() {
    keyboardVisibilitySubscription.cancel();
    super.dispose();
  }

  void onScroll(){
    double currentoffset = scrollController.offset;
    if(currentoffset > previousOffset){
      setState(() {
        hideKeyBoard();

      });
    }else if(currentoffset < previousOffset){

    }
    previousOffset = currentoffset;
  }

  // Create alphabetized data
  List<AlphabetListViewItemGroup> _createAlphabetizedData(List<String> names) {
    final Map<String, List<Person>> data = {};

    for (String name in names) {
      Person person = Person(name);
      final String tag = person.tag;
      if (!data.containsKey(tag)) {
        data[tag] = [];
      }
      data[tag]!.add(person);
    }

    // Sort each list of names
    data.forEach((key, value) {
      value.sort((a, b) => a.name.compareTo(b.name));
    });

    // Sort keys and create list of AlphabetListViewItemGroup
    final sortedKeys = data.keys.toList()..sort();
    final List<AlphabetListViewItemGroup> groups = sortedKeys.map((key) {
      return AlphabetListViewItemGroup(
        tag: key,
        children: data[key]!.map((person) => ListTile(
                  onTap: () {
                    print('hola ${person.name}');
                    Navigator.push(context,
                      CupertinoPageRoute(
                        builder: (context) => ClientInfo(),
                      ),
                    );
                  },
                  title: Container(
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(person.name),
                  ),
                  subtitle: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('9999 XXXX XXXX'),
                          Text('correogen@gmail.com'),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        height: 2,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4F2263),
                        ),
                      ),
                    ],
                  ),)).toList(),
      );
    }).toList();
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final AlphabetListViewOptions options = AlphabetListViewOptions(
      listOptions: ListOptions(
        listHeaderBuilder: (context, symbol) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.only(left: 6.0, top: 6, bottom: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4F2263),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(symbol, style: const TextStyle(color: Colors.white, fontSize: 20),),
          );
        }



      ),
      scrollbarOptions: ScrollbarOptions(
        jumpToSymbolsWithNoEntries: true,
        symbolBuilder: (context, symbol, state) {
          final color = switch (state) {
            AlphabetScrollbarItemState.active => Colors.white,
            AlphabetScrollbarItemState.deactivated => const Color(0xFF4F2263),
            _ => const Color(0xFF4F2263).withOpacity(0.6)};

          return Container(
            padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(100),
              ),
              color: state == AlphabetScrollbarItemState.active
                  ? const Color(0xFF4F2263).withOpacity(0.3)
                  : null,
            ),
            child: Center(
              child: FittedBox(
                child: Text(
                  symbol,
                  style: TextStyle(color: color, fontSize: 30),
                ),
              ),
            ),
          );
        },
      ),
      overlayOptions: OverlayOptions(
        //showOverlay: true,
        overlayBuilder: (context, symbol){
          return Container(
            alignment: Alignment.center,
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black.withOpacity(0.4),
            ),
            child: Text(symbol, style: const TextStyle(color: Colors.white, fontSize: 100),),
          );
        }
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.025,
                  right: MediaQuery.of(context).size.width * 0.045,
                ),
                child: FieldsToWrite(
                  preffixIcon: Icon(
                    CupertinoIcons.search,
                    size: MediaQuery.of(context).size.width * 0.07,
                  ),
                  labelText: 'Buscar...',
                  readOnly: false,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.025,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    addClient();
                  });
                },
                icon: Icon(Icons.person_add_alt_outlined,
                    size: MediaQuery.of(context).size.width * 0.11),
              ),
            ),
          ],
        ),
        Expanded(child: Container(
          margin: EdgeInsets.only(top: 20),
          child: AlphabetListView(
            scrollController: scrollController,
            items: _alphabetizedData,
            options: options,
          ),
        ),)
      ],
    );


  }
}
