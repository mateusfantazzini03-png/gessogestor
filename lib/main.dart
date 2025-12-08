
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GessoGestor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // Controllers
  final _widthController = TextEditingController();
  final _lengthController = TextEditingController(); // Or Height
  final _priceController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _rebaixoController = TextEditingController(text: '0.15');

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GessoGestor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // Controllers
  final _widthController = TextEditingController();
  final _lengthController = TextEditingController(); // Or Height
  final _priceController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _rebaixoController = TextEditingController(text: '0.15');

  // State
  String _selectedModule = 'Aramado'; // Aramado, Estruturado, Divisoria
  bool _isRecessed = false; // Para estruturado
  bool _isFullService = false; // Modo orcamento
  CalculationResult? _lastResult;

  // Profile loaded from shared_preferences
  ProfessionalProfile _professional = ProfessionalProfile(
    companyName: 'Carregando...',
    phone: '',
    pixKey: '',
  );
  final _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await _profileService.loadProfile();
    setState(() {
      _professional = p;
    });
  }

  void _calculate() {
    double width = double.tryParse(_widthController.text) ?? 0;
    double length = double.tryParse(_lengthController.text) ?? 0;
    double rebaixo = double.tryParse(_rebaixoController.text) ?? 0.15;

    if (width <= 0) return;

    setState(() {
      if (_selectedModule == 'Aramado') {
        // Aramado usa area direta nas inputs
        double area = width; // Se usuario digitou area direta
        if (length > 0) area = width * length; // Se digitou os dois
        
        _lastResult = MaterialCalculator.calculateAramado(
          area: area,
          rebaixoHeight: rebaixo,
        );
      } else if (_selectedModule == 'Estruturado') {
        _lastResult = MaterialCalculator.calculateEstruturado(
          width: width,
          length: length > 0 ? length : 1,
          isRecessed: _isRecessed,
        );
      } else if (_selectedModule == 'Divisoria') {
        _lastResult = MaterialCalculator.calculateDivisoria(
          width: width,
          height: length > 0 ? length : 2.60,
        );
      }
    });
  }

  Future<void> _generatePdf() async {
    if (_lastResult == null) return;
    double price = double.tryParse(_priceController.text) ?? 0;

    Uint8List? logoBytes;
    if (_professional.logoPath != null) {
      try {
        // Check if asset or local file
        if (_professional.logoPath!.startsWith('assets/')) {
           final byteData = await rootBundle.load(_professional.logoPath!);
           logoBytes = byteData.buffer.asUint8List();
        } else {
           // Local file
           final file = io.File(_professional.logoPath!);
           if (await file.exists()) {
             logoBytes = await file.readAsBytes();
           }
        }
      } catch (e) {
        debugPrint('Erro ao carregar logo: $e');
      }
    }

    final pdfBytes = await PdfService.generateQuote(
      professional: _professional,
      calculation: _lastResult!,
      pricePerSqm: price,
      isFullService: _isFullService,
      clientName: _clientNameController.text.isEmpty ? null : _clientNameController.text,
      logoBytes: logoBytes,
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdfBytes,
      name: 'Orcamento_GessoGestor.pdf',
    );
  }

  Future<void> _saveQuote() async {
    if (_lastResult == null) return;
    double price = double.tryParse(_priceController.text) ?? 0;
    double total = _lastResult!.area * price;
    
    final savedQuote = SavedQuote(
       id: DateTime.now().millisecondsSinceEpoch, // Generate ID
       clientName: _clientNameController.text.isEmpty ? 'Cliente Temporário' : _clientNameController.text,
       totalValue: total,
       date: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
       result: _lastResult!
    );

    // Use StorageService instead of DatabaseHelper
    await StorageService().saveQuote(savedQuote); 
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Orçamento salvo no Histórico Local!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GessoGestor CRM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage())),
            tooltip: 'Histórico',
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryPage())),
            tooltip: 'Portfólio',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const SettingsPage())
              );
              _loadProfile(); // Reload after edit
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Module Selection
            DropdownButtonFormField<String>(
              value: _selectedModule,
              decoration: const InputDecoration(labelText: 'Tipo de Serviço'),
              items: ['Aramado', 'Estruturado', 'Divisoria'].map((m) {
                return DropdownMenuItem(value: m, child: Text(m));
              }).toList(),
              onChanged: (v) {
                setState(() {
                  _selectedModule = v!;
                  _lastResult = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // 2. Inputs Dimensions
            Row(
              children: [
                Expanded(child: TextField(
                  controller: _widthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _selectedModule == 'Aramado' ? 'Área Total (m²) ou Largura' : 'Largura (m)',
                    border: const OutlineInputBorder(),
                  ),
                )),
                const SizedBox(width: 10),
                if (_selectedModule != 'Aramado') // Aramado pode ser sÃ³ area
                  Expanded(child: TextField(
                    controller: _lengthController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _selectedModule == 'Divisoria' ? 'Altura (m)' : 'Comprimento (m)',
                      border: const OutlineInputBorder(),
                    ),
                  )),
              ],
            ),
            
            // Specific inputs
            if (_selectedModule == 'Aramado')
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: _rebaixoController,
                   keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Altura Rebaixo (m)'),
                ),
              ),
            
            if (_selectedModule == 'Estruturado')
              CheckboxListTile(
                title: const Text('Tem Rebaixo/Sanca? (Estrutura Reforçada)'),
                value: _isRecessed,
                onChanged: (v) => setState(() => _isRecessed = v!),
              ),

             const SizedBox(height: 20),

            // 6. Action Buttons
            if (_lastResult != null)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveQuote,
                      icon: const Icon(Icons.save),
                      label: const Text('SALVAR'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.all(12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _generatePdf,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('GERAR PDF'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(12)),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: const Text('CALCULAR MATERIAIS'),
              ),
            
            const SizedBox(height: 20),

            // 7. Results Preview
            if (_lastResult != null) ...[
               const Divider(height: 40),
               Text('Resultado Prévio (${_lastResult!.moduleName}):', style: const TextStyle(fontWeight: FontWeight.bold)),
               Text('Área: ${_lastResult!.area.toStringAsFixed(2)} m²'),
               const SizedBox(height: 10),
               
               // Card de Materiais (Visualização Rápida)
               Card(
                 child: ListView.builder(
                   shrinkWrap: true,
                   physics: const NeverScrollableScrollPhysics(),
                   itemCount: _lastResult!.materials.length,
                   itemBuilder: (ctx, i) {
                     final m = _lastResult!.materials[i];
                     return ListTile(
                       title: Text(m.name),
                       subtitle: Text('Compra: ${m.quantityPurchase} ${m.unit} (Tec: ${m.quantityTechnical.toStringAsFixed(1)})'),
                       trailing: Text('Sobra: ${m.stockLeftover.toStringAsFixed(1)}', style: const TextStyle(color: Colors.orange)),
                     );
                   },
                 ),
               ),

               const Divider(height: 40),
               // Pricing Section
               const Text('Gerar Orçamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               const SizedBox(height: 10),
               TextField(
                 controller: _clientNameController,
                 decoration: const InputDecoration(labelText: 'Nome do Cliente'),
               ),
               const SizedBox(height: 10),
                TextField(
                 controller: _priceController,
                 keyboardType: TextInputType.number,
                 decoration: const InputDecoration(
                   labelText: 'Valor por m² (R\$)',
                   prefixText: 'R\$ ',
                   border: OutlineInputBorder(),
                 ),
               ),
               SwitchListTile(
                 title: const Text('Orçamento "Full Service"'),
                 subtitle: Text(_isFullService 
                   ? 'Oculta lista de materiais. Valor fechado.' 
                   : 'Mostra lista de compras p/ cliente. Valor só Mão de Obra.'),
                 value: _isFullService,
                 onChanged: (v) => setState(() => _isFullService = v),
               ),
               const SizedBox(height: 10),
             ],
          ],
        ),
      ),
    );
  }
}
