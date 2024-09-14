import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alphabet_list_view/alphabet_list_view.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../forms/clientForm.dart';
import '../../models/clientModel.dart';
import '../../services/getClientsService.dart';
import '../../styles/AppointmentStyles.dart';
import 'clientInfo.dart';
import 'package:http/http.dart' as http;
class Person {
  String name;
  String tag;

  Person(this.name) : tag = name.isNotEmpty ? name[0].toUpperCase() : '#';
}
class DropdownDataManager {
  List<Client> clients = [];
  Future<List<Client>> fetchUser() async {
    List<Client> nombresClientes = [];
    try {
      var response = await http.get(
        Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/clientsAll'),
      );
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic> && jsonResponse['clients'] is List) {
          nombresClientes = List<Client>.from(
            jsonResponse['clients'].map((clientJson) => Client.fromJson(clientJson as Map<String, dynamic>)),
          );
          clients = List.from(jsonResponse['clients'])
              .map((clientJson) => Client.fromJson(clientJson as Map<String, dynamic>))
              .toList();
          print('Nombres de clientes: $clients');
        } else {
          print('La respuesta no contiene una lista de clientes.');
        }
      } else {
        print('Error al cargar los clientes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
    }
    return nombresClientes;
  }
}


class ClientDetails extends StatefulWidget {
  final bool isDoctorLog;
  final void Function(
    bool,
  ) onHideBtnsBottom;
  final void Function(
    bool,
  ) onShowBlur;

  const ClientDetails({super.key, required this.onHideBtnsBottom, required this.isDoctorLog, required this.onShowBlur});

  @override
  State<ClientDetails> createState() => _ClientDetailsState();
}

class _ClientDetailsState extends State<ClientDetails> {
  final FocusNode focusNode = FocusNode();
  final dropdownDataManager = DropdownDataManager();
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  late bool isDocLog;
  bool visibleKeyboard = false;
  bool platform = false;
  double previousOffset = 0;
  List<Client> clients = [];
  final TextEditingController searchController = TextEditingController();
  List<Client> filteredClients = [];
  late List<AlphabetListViewItemGroup> _alphabetizedData;
  late ScrollController scrollController;
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

  void _onFinishedAddClient(int initScreen, bool forShowBtnAfterAddclient) {
    setState(() {
    });
  }

  void _onHideBtnsBottom(bool hideBtnsBottom) {
    setState(() {
    });
  }

  Future<void> getNombres() async {
    List<String> fetchedNames = (await dropdownDataManager.fetchUser()).cast<String>();

    setState(() {
      clients = fetchedNames.cast<Client>();
      _alphabetizedData = _createAlphabetizedData(clients);
    });
  }
  Future<void> fetchAndPrintClientDetails() async {
    await dropdownDataManager.fetchUser();

    for (var client in dropdownDataManager.clients) {
      print('ID: ${client.id}, Nombre: ${client.name}, Email: ${client.email}, Número: ${client.number}');
    }
  }
  Future<void> addClient() async {
    return showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return Stack(
            children: [
              ClientForm(
                    onHideBtnsBottom: _onHideBtnsBottom,
                    onFinishedAddClient: _onFinishedAddClient),
            ],
          );
        }).then((_){
      widget.onShowBlur(false);

    });
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(onScroll);
    _alphabetizedData = _createAlphabetizedData(clients);
    keyboardVisibilityController = KeyboardVisibilityController();
    Platform.isIOS ? platform = false : platform = true;
    checkKeyboardVisibility();
    isDocLog = widget.isDoctorLog;
    searchController.addListener(onSearchChanged);
    dropdownDataManager.fetchUser().then((fetchedClients) {
      setState(() {
        clients = fetchedClients;
        filteredClients = clients;
        _alphabetizedData = _createAlphabetizedData(filteredClients);
      });
    });
    getNombres();
    super.initState();
  }


  @override
  void dispose() {
    keyboardVisibilitySubscription.cancel();
    searchController.dispose();
    focusNode.dispose();
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
  void onSearchChanged() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredClients = clients.where((client) {
        return client.name.toLowerCase().contains(query);
      }).toList();
      _alphabetizedData = _createAlphabetizedData(filteredClients);
    });
  }
  TextSpan highlightOccurrences(String source, String query) {
    if(query.isEmpty){
      return TextSpan(
        text: source,
        style: TextStyle(
          color: const Color(0xFF4F2263),
          fontSize: MediaQuery.of(context).size.width * 0.055,
        ),
      );
    }
    var matches = <TextSpan>[];
    String lowerSource = source.toLowerCase();
    String lowerQuery = query.toLowerCase();
    int start = 0;
    int index;

    while ((index = lowerSource.indexOf(lowerQuery, start)) != -1){
      if(index > start){
        matches.add(TextSpan(
          text: source.substring(start, index),
          style: TextStyle(
            color: const Color(0xFF4F2263),
            fontSize: MediaQuery.of(context).size.width * 0.055,
          ),
        ));
      }
      matches.add(TextSpan(
        text: source.substring(index, index + query.length),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4F2263),
          fontSize: MediaQuery.of(context).size.width * 0.055,
        ),
      ));
      start = index + query.length;
    }

    if(start < source.length){
      matches.add(TextSpan(
        text: source.substring(start),
        style: TextStyle(
          color: const Color(0xFF4F2263),
          fontSize: MediaQuery.of(context).size.width * 0.055,
        ),
      ));
    }

    return TextSpan(children: matches);
  }

  List<AlphabetListViewItemGroup> _createAlphabetizedData(List<Client> clients){
    final Map<String, List<Client>> data = {};
    String query = searchController.text;

    for(Client client in clients){
      final String tag = client.name[0].toUpperCase();
      if (!data.containsKey(tag)) {
        data[tag] = [];
      }
      data[tag]!.add(client);
    }

    data.forEach((key, value) {
      value.sort((a, b) => a.name.compareTo(b.name));
    });

    final sortedKeys = data.keys.toList()..sort();
    final List<AlphabetListViewItemGroup> groups = sortedKeys.map((key){
      return AlphabetListViewItemGroup(
        tag: key,
        children: data[key]!.map((client) => ListTile(
          onTap: () {
            Navigator.push(context,
              CupertinoPageRoute(
                builder: (context) => ClientInfo(isDoctorLog: isDocLog, id: client.id, name: client.name, phone: client.number, email: client.email,),
              ),
            );
          },
          title: Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            child: RichText(
              text: highlightOccurrences(client.name, query), // Este método ya regresa un TextSpan con el estilo aplicado
            ),
          ),
          subtitle: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${client.number}',
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: const Color(0xFF4F2263).withOpacity(0.3),
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      client.email,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF4F2263).withOpacity(0.3),
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                      ),
                    ),
                  ),
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
          ),
        )).toList(),
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
            child: Text(
              symbol,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          );
        },
      ),
      scrollbarOptions: ScrollbarOptions(
        jumpToSymbolsWithNoEntries: true,
        symbolBuilder: (context, symbol, state) {
          final color = switch (state) {
            AlphabetScrollbarItemState.active => Colors.white,
            AlphabetScrollbarItemState.deactivated => const Color(0xFF4F2263),
            _ => const Color(0xFF4F2263).withOpacity(0.6),
          };

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
        overlayBuilder: (context, symbol) {
          return Container(
            alignment: Alignment.center,
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black.withOpacity(0.4),
            ),
            child: Text(
              symbol,
              style: const TextStyle(color: Colors.white, fontSize: 100),
            ),
          );
        },
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
                child: SizedBox(
                  height: 37,
                  child: TextFormField(
                    controller: searchController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Bus..',
                      prefixIcon: const Icon(Icons.search),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFF4F2263).withOpacity(0.3), width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFF4F2263).withOpacity(0.3), width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: TextStyle(
                    ),
                  ),
                )
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
                    widget.onShowBlur(true);
                    addClient();
                  });
                },
                icon: Icon(
                  Icons.person_add_alt_outlined,
                  size: MediaQuery.of(context).size.width * 0.11,
                  color: const Color(0xFF4F2263),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            child: AlphabetListView(
              scrollController: scrollController,
              items: _alphabetizedData,
              options: options,
            ),
          ),
        ),
      ],
    );
  }
}