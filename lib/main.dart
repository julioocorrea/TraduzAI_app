import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/openai_service.dart';
import 'services/hive_service.dart';
import 'models/translation_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await HiveService.init();
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TraduzAI',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF333333), fontSize: 16),
        ),
      ),
      home: const PaginaTradutor(),
      routes: {
        '/historico': (context) => const PaginaHistorico(),
      },
    );
  }
}

class PaginaTradutor extends StatefulWidget {
  const PaginaTradutor({super.key});

  @override
  _PaginaTradutorState createState() => _PaginaTradutorState();
}

class _PaginaTradutorState extends State<PaginaTradutor> {
  String idiomaOrigem = 'Português';
  String idiomaDestino = 'Inglês';
  String textoEntrada = '';
  String textoTraduzido = '';
  bool _isTranslating = false;

  final Map<String, String> _languageCodes = {
    'Português': 'Portuguese',
    'Inglês': 'English',
    'Espanhol': 'Spanish',
    'Francês': 'French',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF00C6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.translate, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'TraduzAI',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.of(context).push(_createRoute()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: _construirSeletorIdiomas(),
              ),
              Expanded(
                child: _construirCampoTextoDividido(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: _construirBotaoTraduzir(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCampoTextoDividido() {
    return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: Offset(0, 4),
        ), 
      ], 
    ), 
    child: Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (texto) => setState(() => textoEntrada = texto),
              decoration: const InputDecoration(
                hintText: 'Digite a frase aqui...',
                hintStyle: TextStyle(color: Color(0xFF888888)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              maxLines: null,
              style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE0E0E0)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                child: Text(
                  textoTraduzido.isEmpty ? 'Tradução aparecerá aqui...' : textoTraduzido,
                  style: TextStyle(
                    fontSize: 16,
                    color: textoTraduzido.isEmpty 
                      ? const Color(0xFF888888) 
                      : const Color(0xFF333333),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _construirSeletorIdiomas() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ), 
        ], 
      ), 
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          children: [
            Expanded(
              child: _construirDropdownPersonalizado(
                valor: idiomaOrigem,
                itens: ['Português', 'Inglês', 'Espanhol', 'Francês'],
                aoAlterar: (novoValor) {
                  setState(() {
                    idiomaOrigem = novoValor!;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: Color(0xFF4A90E2), size: 30),
              onPressed: () {
                setState(() {
                  final temp = idiomaOrigem;
                  idiomaOrigem = idiomaDestino;
                  idiomaDestino = temp;
                });
              },
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _construirDropdownPersonalizado(
                valor: idiomaDestino,
                itens: ['Português', 'Inglês', 'Espanhol', 'Francês'],
                aoAlterar: (novoValor) {
                  setState(() {
                    idiomaDestino = novoValor!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirDropdownPersonalizado({
    required String valor,
    required List<String> itens,
    required Function(String?) aoAlterar,
  }) {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        return itens.map((String item) {
          return PopupMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
            ),
          );
        }).toList();
      },
      onSelected: aoAlterar,
      icon: const SizedBox(),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              valor,
              style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.grey),
      ),
    );
  }

  Widget _construirBotaoTraduzir() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isTranslating ? null : _realizarTraducao,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isTranslating 
              ? Colors.grey 
              : const Color(0xFF4A90E2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 5,
          shadowColor: Colors.black26,
        ),
        child: _isTranslating
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.translate, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Traduzir', 
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }

Future<void> _realizarTraducao() async {
    if (textoEntrada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Digite algo para traduzir!')));
      return;
    }

    setState(() => _isTranslating = true);

    try {
      final traducao = await OpenAIService.translateText(
        text: textoEntrada,
        sourceLanguage: _languageCodes[idiomaOrigem] ?? idiomaOrigem,
        targetLanguage: _languageCodes[idiomaDestino] ?? idiomaDestino,
      );

      // Salva a tradução no Hive
      await HiveService.saveTranslation(Translation(
        originalText: textoEntrada,
        translatedText: traducao,
        sourceLanguage: idiomaOrigem,
        targetLanguage: idiomaDestino,
      ));

      setState(() {
        textoTraduzido = traducao;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() => _isTranslating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na tradução: ${e.toString()}')),
      );
    }
  }
}

class PaginaHistorico extends StatefulWidget {
  const PaginaHistorico({super.key});

  @override
  State<PaginaHistorico> createState() => _PaginaHistoricoState();
}

class _PaginaHistoricoState extends State<PaginaHistorico> {
  List<Translation> historicoTraducoes = [];
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _carregarTraducoes();
  }

  Future<void> _carregarTraducoes() async {
    final traducoes = HiveService.getTranslations();
    setState(() {
      historicoTraducoes = traducoes;
      _editingIndex = null; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF00C6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        title: const Text(
          'Histórico de Traduções',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Tooltip(
            message: 'Limpar histórico',
            child: IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: () async {
                final confirmed = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Limpar histórico'),
                    content: const Text('Tem certeza que deseja apagar todo o histórico?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Limpar', 
                          style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  await HiveService.clearHistory();
                  await _carregarTraducoes();
                }
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarTraducoes,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: historicoTraducoes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: historicoTraducoes.length,
                  itemBuilder: (context, index) {
                    return _buildTranslationCard(
                      historicoTraducoes[index], 
                      context, 
                      index
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 80,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhuma tradução no histórico',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Suas traduções aparecerão aqui',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.translate),
            label: const Text('Fazer uma tradução'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF4A90E2),
              padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationCard(Translation traducao, BuildContext context, int index) {
    final isEditing = _editingIndex == index;
    final exampleController = TextEditingController(text: traducao.examplePhrase);
    return Dismissible(
      key: Key(traducao.timestamp.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remover tradução'),
            content: const Text('Deseja remover esta tradução do histórico?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remover', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await HiveService.deleteTranslation(index);
        await _carregarTraducoes();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tradução removida'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4A90E2),
                  Color(0xFF00C6FF),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardHeader(traducao),
                  const SizedBox(height: 16),
                  _buildTranslationSection(
                    'Texto Original', 
                    Icons.text_snippet, 
                    traducao.originalText, 
                    context
                  ),
                  const SizedBox(height: 16),
                  _buildTranslationSection(
                    'Tradução', 
                    Icons.translate, 
                    traducao.translatedText, 
                    context
                  ),
                  const SizedBox(height: 16),
                  _buildExampleSection(traducao, context, index, isEditing, exampleController),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(Translation traducao) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              '${traducao.timestamp.day}/${traducao.timestamp.month}/${traducao.timestamp.year} '
              '${traducao.timestamp.hour}:${traducao.timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${traducao.sourceLanguage} → ${traducao.targetLanguage}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExampleSection(
    Translation traducao,
    BuildContext context,
    int index,
    bool isEditing,
    TextEditingController exampleController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, size: 18, color: Colors.white70),
            const SizedBox(width: 8),
            const Text(
              'Exemplo de Uso',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            if (!isEditing && traducao.examplePhrase.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.white70),
                onPressed: () => setState(() => _editingIndex = index),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (isEditing)
          TextField(
            controller: exampleController,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      final updated = traducao.copyWith(
                        examplePhrase: exampleController.text,
                      );
                      await HiveService.updateTranslation(index, updated);
                      if (mounted) {
                        setState(() {
                          _editingIndex = null;
                          _carregarTraducoes();
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      final updated = traducao.copyWith(examplePhrase: ''); 
                      await HiveService.updateTranslation(index, updated);
                      if (mounted) {
                        setState(() {
                          _editingIndex = null;
                          _carregarTraducoes();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          )
        else
          InkWell(
            onTap: () => setState(() => _editingIndex = index),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                traducao.examplePhrase.isEmpty
                    ? 'Toque para adicionar um exemplo de uso'
                    : traducao.examplePhrase,
                style: TextStyle(
                  color: traducao.examplePhrase.isEmpty
                      ? Colors.white70
                      : Colors.white,
                  fontStyle: traducao.examplePhrase.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTranslationSection(
    String title, 
    IconData icon, 
    String text, 
    BuildContext context
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15, 
                    color: Colors.white, 
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$title copiado!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.content_copy, size: 20, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const PaginaHistorico(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
