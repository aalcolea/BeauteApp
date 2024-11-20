import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../themes/colors.dart';
import 'package:share_plus/share_plus.dart';

class TestPDF extends StatefulWidget {

  final Map<String, dynamic> ticket;

  const TestPDF({super.key, required this.ticket});

  @override
  _TestPDFState createState() => _TestPDFState();
}

class _TestPDFState extends State<TestPDF> {
  late pw.Document pdf;
  late Uint8List archivoPdf;
  String? pdfPath;
  List<dynamic> detallesTicket = [];

  @override
  void initState() {
    super.initState();
    initPDF();
  }

  Future<void> initPDF() async {
    archivoPdf = await generarPdf1();
    pdfPath = await savePdfTemporarily();
    setState(() {});
  }

  Future<String> savePdfTemporarily() async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Recibo de Compra_${widget.ticket['id']}.pdf');
    await file.writeAsBytes(archivoPdf);
    return file.path;
  }

  Future<Uint8List> generarPdf1() async {
    detallesTicket = widget.ticket['detalles'];
    pdf = pw.Document();
    final imageBytes = await rootBundle.load('assets/imgLog/test2.jpeg');
    final image = pw.MemoryImage(imageBytes.buffer.asUint8List());
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        margin: pw.EdgeInsets.zero,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        build: (context) => [
          pw.Column(
              children: [
                pw.Padding(
                    padding: const pw.EdgeInsets.all(20),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Image(
                            image,
                            width: 75
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Recibo de',
                              style: pw.TextStyle(
                                  fontSize: 35,
                                  color: PdfColors.blue900,
                                  fontWeight: pw.FontWeight.bold
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                            pw.Text(
                              'compra',
                              style: pw.TextStyle(
                                  fontSize: 35,
                                  color: PdfColors.blue900,
                                  fontWeight: pw.FontWeight.bold
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    )
                ),
                pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 20),
                    child: pw.Column(
                      children: [
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                '[Nombre y slogan de tu compañia]',
                                style: pw.TextStyle(
                                    fontSize: 12,
                                    color: PdfColors.blue900,
                                    fontWeight: pw.FontWeight.bold
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                  children: [
                                    pw.Row(
                                        children: [
                                          pw.Text(
                                            'Fecha: ',
                                            style: pw.TextStyle(
                                                fontSize: 12,
                                                color: PdfColors.blue900,
                                                fontWeight: pw.FontWeight.bold
                                            ),
                                            textAlign: pw.TextAlign.center,
                                          ),
                                          pw.Text(
                                            '${widget.ticket['fecha']}',
                                            style: const pw.TextStyle(
                                              fontSize: 12,
                                              color: PdfColors.black,
                                            ),
                                            textAlign: pw.TextAlign.center,
                                          ),
                                        ]
                                    ),
                                    pw.Row(
                                        children: [
                                          pw.Text(
                                            'Recibo #',
                                            style: pw.TextStyle(
                                                fontSize: 12,
                                                color: PdfColors.blue900,
                                                fontWeight: pw.FontWeight.bold
                                            ),
                                            textAlign: pw.TextAlign.center,
                                          ),
                                          pw.Text(
                                            '${widget.ticket['id']}',
                                            style: const pw.TextStyle(
                                              fontSize: 12,
                                              color: PdfColors.black,
                                            ),
                                            textAlign: pw.TextAlign.center,
                                          ),
                                        ]
                                    )
                                  ]
                              )
                            ]
                        ),
                        pw.Container(
                            height: 15
                        ),
                        pw.Row(
                            children: [
                              pw.Column(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                      margin: const pw.EdgeInsets.only(right: 2, bottom: 2),
                                      color: PdfColors.blue900,
                                      width: 120,
                                      child: pw.Text(
                                        'Metodo de pago',
                                        style: const pw.TextStyle(
                                          fontSize: 11,
                                          color: PdfColors.white,
                                        ),
                                        textAlign: pw.TextAlign.center,
                                      ),
                                    ),
                                    pw.Container(
                                      padding: const pw.EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                      margin: const pw.EdgeInsets.only(right: 2),
                                      color: PdfColors.blue100,
                                      width: 120,
                                      child: pw.Text(
                                        'Efectivo/Tarjeta',
                                        style: const pw.TextStyle(
                                          fontSize: 11,
                                          color: PdfColors.black,
                                        ),
                                        textAlign: pw.TextAlign.center,
                                      ),
                                    ),
                                  ]
                              ),
                            ]
                        ),
                        pw.Row(
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                margin: const pw.EdgeInsets.only(right: 2, top: 10),
                                color: PdfColors.blue900,
                                width: 43,
                                child: pw.Text(
                                  'Cant.',
                                  style: const pw.TextStyle(
                                    fontSize: 11,
                                    color: PdfColors.white,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Container(
                                  padding: const pw.EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                  margin: const pw.EdgeInsets.only(right: 2, top: 10),
                                  color: PdfColors.blue900,
                                  child: pw.Text(
                                    'Articulo',
                                    style: const pw.TextStyle(
                                      fontSize: 11,
                                      color: PdfColors.white,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                margin: const pw.EdgeInsets.only(right: 2, top: 10),
                                color: PdfColors.blue900,
                                width: 90,
                                child: pw.Text(
                                  'Precio unitario',
                                  style: const pw.TextStyle(
                                    fontSize: 11,
                                    color: PdfColors.white,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                margin: const pw.EdgeInsets.only(right: 2, top: 10),
                                color: PdfColors.blue900,
                                width: 90,
                                child: pw.Text(
                                  'Total prod',
                                  style: const pw.TextStyle(
                                    fontSize: 11,
                                    color: PdfColors.white,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                            ]
                        ),
                        pw.ListView.builder(
                            itemCount: detallesTicket.length,
                            itemBuilder: (context, index) {
                              return pw.Row(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                      margin: const pw.EdgeInsets.only(right: 2, bottom: 2),
                                      color: PdfColors.blue100,
                                      width: 43,
                                      child: pw.Text(
                                        '${widget.ticket['detalles'][index]['cantidad']}',
                                        style: const pw.TextStyle(
                                          fontSize: 11,
                                          color: PdfColors.black,
                                        ),
                                        textAlign: pw.TextAlign.center,
                                      ),
                                    ),
                                    pw.Expanded(
                                      child: pw.Container(
                                        padding: const pw.EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                        margin: const pw.EdgeInsets.only(right: 2, bottom: 2),
                                        color: PdfColors.blue100,
                                        child: pw.Text(
                                          '${widget.ticket['detalles'][index]['producto']['nombre']}',
                                          style: const pw.TextStyle(
                                            fontSize: 11,
                                            color: PdfColors.black,
                                          ),
                                          textAlign: pw.TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    pw.Container(
                                        padding: const pw.EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                        margin: const pw.EdgeInsets.only(right: 2, bottom: 2),
                                        color: PdfColors.blue100,
                                        width: 90,
                                        child: pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                            children: [
                                              pw.Text(
                                                '\$',
                                                style: const pw.TextStyle(
                                                  fontSize: 11,
                                                  color: PdfColors.black,
                                                ),
                                                textAlign: pw.TextAlign.center,
                                              ),
                                              pw.Text(
                                                '${widget.ticket['detalles'][index]['precio']}',
                                                style: const pw.TextStyle(
                                                  fontSize: 11,
                                                  color: PdfColors.black,
                                                ),
                                                textAlign: pw.TextAlign.center,
                                              )
                                            ]
                                        )
                                    ),
                                    pw.Container(
                                        padding: const pw.EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                        margin: const pw.EdgeInsets.only(right: 2, bottom: 2),
                                        color: PdfColors.blue100,
                                        width: 90,
                                        child: pw.Row(
                                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                            children: [
                                              pw.Text(
                                                '\$',
                                                style: const pw.TextStyle(
                                                  fontSize: 11,
                                                  color: PdfColors.black,
                                                ),
                                                textAlign: pw.TextAlign.right,
                                              ),
                                              pw.Text(
                                                (double.parse(widget.ticket['detalles'][index]['precio'])*(widget.ticket['detalles'][index]['cantidad'])).toStringAsFixed(2),
                                                style: const pw.TextStyle(
                                                  fontSize: 11,
                                                  color: PdfColors.black,
                                                ),
                                                textAlign: pw.TextAlign.right,
                                              )
                                            ]
                                        )
                                    ),
                                  ]
                              );
                            }
                        ),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Container(
                                  padding: const pw.EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                  margin: const pw.EdgeInsets.only(right: 2, top: 5),
                                  color: PdfColors.blue900,
                                  width: 90,
                                  child: pw.Text(
                                    'Total',
                                    style: const pw.TextStyle(
                                      fontSize: 11,
                                      color: PdfColors.white,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  )
                              ),
                              pw.Container(
                                  padding: const pw.EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                  margin: const pw.EdgeInsets.only(right: 2, top: 5),
                                  color: PdfColors.blue100,
                                  width: 90,
                                  child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          '\$',
                                          style: const pw.TextStyle(
                                            fontSize: 11,
                                            color: PdfColors.black,
                                          ),
                                          textAlign: pw.TextAlign.center,
                                        ),
                                        pw.Text(
                                          '${widget.ticket['total']}',
                                          style: const pw.TextStyle(
                                            fontSize: 11,
                                            color: PdfColors.black,
                                          ),
                                          textAlign: pw.TextAlign.center,
                                        )
                                      ]
                                  )
                              )
                            ]
                        ),
                      ],
                    )
                ),
              ]
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Container(
              alignment: pw.Alignment.bottomCenter,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    '¡Gracias por su confianza!',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.blue900,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Container(
                    height: 5
                  ),
                  pw.Text(
                    '[Nombre de la empresa][Calle,ciudad y código postal][Teléfono][Correo electrónico]',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.blue900,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ]
              ),
            )
          )
        ],
      ),
    );
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Ticket #${widget.ticket['id']}',
          style: const TextStyle(
            color: AppColors.primaryColor
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (pdfPath != null) {
                await Share.shareXFiles(
                  [XFile(pdfPath!)],
                  text: '¡Gracias por su confianza en Beaute clinique!',
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error: PDF no disponible para compartir")),
                );
              }
            },
            icon: const Icon(
              CupertinoIcons.share,
              color: AppColors.primaryColor,
            )
          )
        ],
        iconTheme: const IconThemeData(
          color: AppColors.primaryColor
        ),
      ),
      body: SafeArea(
        child: pdfPath == null
            ? const Center(child: CircularProgressIndicator())
            : PdfView(
          path: pdfPath!,
        ),
      ),
    );
  }
}