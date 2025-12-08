import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/models.dart';

class PdfService {
  static Future<Uint8List> generateQuote({
    required ProfessionalProfile professional,
    required CalculationResult calculation,
    required double pricePerSqm,
    required bool isFullService, 
    String? clientName,
    Uint8List? logoBytes,
  }) async {
    final pdf = pw.Document();
    
    final totalLabor = calculation.area * pricePerSqm;
    final finalPrice = totalLabor; 

    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Estilos
    final styleTitle = pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800);
    final styleHeader = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.white);
    final styleTotal = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green900);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- CABEÇALHO ---
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                   if (logoBytes != null)
                      pw.Container(
                        height: 70,
                        width: 70,
                        child: pw.Image(pw.MemoryImage(logoBytes)),
                      ),
                   pw.Expanded(
                     child: pw.Padding(
                       padding: const pw.EdgeInsets.only(left: 16),
                       child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(professional.companyName.toUpperCase(), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text('Contato: ${professional.phone}'),
                          pw.Text('Pix: ${professional.pixKey}'),
                        ],
                       ),
                     )
                   ),
                   pw.Column(
                     crossAxisAlignment: pw.CrossAxisAlignment.end,
                     children: [
                       pw.Text('ORÇAMENTO', style: styleTitle),
                       pw.Text('Data: ${dateFormat.format(DateTime.now())}'),
                       if (clientName != null) pw.Text('Cliente: $clientName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                     ]
                   )
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: PdfColors.blueGrey200),
              pw.SizedBox(height: 20),

              // --- ESCOPO ---
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ESCOPO DO SERVIÇO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey700)),
                    pw.SizedBox(height: 4),
                    pw.Text('${calculation.moduleName}'),
                    pw.Text('Área Total Aproximada: ${calculation.area.toStringAsFixed(2)} m²', style: pw.TextStyle(fontSize: 14)),
                  ]
                )
              ),
              pw.SizedBox(height: 20),

              // --- DETALHAMENTO ---
              if (!isFullService) ...[
                pw.Text('LISTA DE MATERIAIS SUGERIDA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Table.fromTextArray(
                  headers: ['ITEM', 'QUANTIDADE', 'UNIDADE'],
                  headerStyle: styleHeader,
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey600),
                  cellHeight: 25,
                  cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.center, 2: pw.Alignment.center},
                  data: calculation.materials.map((m) => [
                    m.name, 
                    m.formattedQuantity, // Usando a formatação corrigida
                    m.unit
                  ]).toList(),
                  border: null,
                  oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                ),
                pw.SizedBox(height: 5),
                pw.Text('* A compra dos materiais é responsabilidade do cliente.', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                     pw.Text('MÃO DE OBRA TÉCNICA:', style: pw.TextStyle(fontSize: 14)),
                     pw.Text(currencyFormat.format(finalPrice), style: styleTotal),
                  ]
                ),
              ] else ...[
                 pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                  child: pw.Column(
                    children: [
                      pw.Text('SERVIÇO COMPLETO (MATERIAL + MÃO DE OBRA)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text('Execução completa conforme normas técnicas, incluindo fornecimento de todo material necessário.', textAlign: pw.TextAlign.center),
                    ]
                  )
                 ),
                 pw.SizedBox(height: 20),
                 pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                     pw.Text('TOTAL DO INVESTIMENTO:', style: pw.TextStyle(fontSize: 14)),
                     pw.Text(currencyFormat.format(finalPrice), style: styleTotal),
                  ]
                ),
              ],

              pw.Spacer(),

              // --- RODAPÉ ---
              pw.Divider(color: PdfColors.blueGrey200),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Validade: 10 dias', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Gerado por GessoGestor App', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                ]
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
