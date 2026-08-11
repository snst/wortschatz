import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:translator/translator.dart';
import 'package:wortschatz/database_service.dart';
import 'package:wortschatz/flashcard.dart';
import 'package:wortschatz/settings_service.dart';

/// Shows a full-screen editor to add or edit a flashcard.
void showCardDialog(BuildContext context, DatabaseService db, {Flashcard? card}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CardEditorPage(db: db, card: card),
      fullscreenDialog: true,
    ),
  );
}

class CardEditorPage extends StatefulWidget {
  final DatabaseService db;
  final Flashcard? card;

  const CardEditorPage({super.key, required this.db, this.card});

  @override
  State<CardEditorPage> createState() => _CardEditorPageState();
}

class _CardEditorPageState extends State<CardEditorPage> {
  late TextEditingController _frontController;
  late TextEditingController _backController;
  late TextEditingController _noteController;
  final SettingsService _settingsService = SettingsService();
  bool _isLoading = false;
  String langFront_ = '';
  String langBack_ = '';
  bool _learnCard = false;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(text: widget.card?.front ?? '');
    _backController = TextEditingController(text: widget.card?.back ?? '');
    _noteController = TextEditingController(text: widget.card?.note ?? '');
    _learnCard = (widget.card?.priority ?? 1) > 0;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    String front = await _settingsService.getLanguageFront();
    String back = await _settingsService.getLanguageBack();

    // Normalize language codes (e.g., 'es-ES' -> 'es')
    if (front.length > 2) front = front.substring(0, 2);
    if (back.length > 2) back = back.substring(0, 2);

    if (mounted) {
      setState(() {
        langFront_ = front;
        langBack_ = back;
      });
    }
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _translate(bool fromFront) async {
    final input = fromFront ? _frontController.text : _backController.text;
    if (input.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final from = fromFront ? langFront_ : langBack_;
      final to = fromFront ? langBack_ : langFront_;

      final translator = GoogleTranslator();
      final translation = await translator.translate(input, from: from, to: to);

      setState(() {
        if (fromFront) {
          _backController.text = translation.text;
        } else {
          _frontController.text = translation.text;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Translation failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)));
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    String formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
    return formattedDate;
  }

  Future<void> _save() async {
    final front = _frontController.text.trim();
    final back = _backController.text.trim();
    final note = _noteController.text.trim();

    if (front.isEmpty || back.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in both Front and Back')));
      return;
    }

    if (widget.card == null) {
      await widget.db.addCard(front, back, note, _learnCard);
    } else {
      await widget.db.updateCard(widget.card!.id, front, back, note, _learnCard);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _resetProgress() async {
    if (widget.card == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text('Are you sure you want to reset the learning progress for this card?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.db.updateCardResetProgress(widget.card!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress reset'), duration: Duration(seconds: 1)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card == null ? 'Add Card' : 'Edit Card'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            ) /*IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
            tooltip: 'Save Card',
          ),*/
          ,
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputSection(
              controller: _frontController,
              label: langFront_.isEmpty ? 'Front' : langFront_,
              translateTo: langBack_,
              //hint: 'e.g. word or phrase in original language',
              onTranslate: () => _translate(true),
            ),
            const SizedBox(height: 4),
            _buildInputSection(
              controller: _backController,
              label: langBack_.isEmpty ? 'Back' : langBack_,
              translateTo: langFront_,
              //hint: 'e.g. translation or definition',
              onTranslate: () => _translate(false),
            ),
            const SizedBox(height: 4),
            _buildInputSection(
              controller: _noteController, label: 'Note', translateTo: '',
              //hint: 'Additional information (optional)',
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _learnCard,
                    onChanged: (value) => setState(() => _learnCard = value!),
                  ),
                  const Text('Learn Card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (widget.card != null)
                    OutlinedButton.icon(
                      onPressed: _resetProgress,
                      icon: const Icon(Icons.restart_alt, size: 20),
                      label: const Text('Reset Progress'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                ],
              ),
            ),
            if (widget.card != null) ...[
              const SizedBox(
                height: 16,
              ),
              Text(
                  'Reviews: ${widget.card!.reviewCount}, Stability: ${widget.card!.stability.toStringAsFixed(1)}, Difficulty: ${widget.card!.difficulty.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
              Text(
                  'Last: ${_formatDateTime(widget.card!.lastReview)}, Next: ${_formatDateTime(widget.card!.nextReview)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (widget.card != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => showDeleteConfirmation(context, widget.db, widget.card!, onDeleted: () {
                        if (mounted) Navigator.pop(context);
                      }),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection({
    required TextEditingController controller,
    required String label,
    required String translateTo,
    VoidCallback? onTranslate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () => _copyToClipboard(controller.text),
              tooltip: 'Copy to clipboard',
            ),
            if (onTranslate != null)
              IconButton(
                icon: const Icon(Icons.translate, size: 20, color: Colors.blue),
                onPressed: onTranslate,
                tooltip: 'Translate to \'$translateTo\'',
              ),
          ],
        ),
        //const SizedBox(height: 2),
        TextField(
          controller: controller,
          maxLines: null,
          minLines: 3,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            //hintText: hint,
            border: const OutlineInputBorder(), filled: true,
            fillColor: Theme.of(context).brightness == Brightness.light ? Colors.grey[50] : Colors.grey[900],
          ),
        ),
      ],
    );
  }
}

void showDeleteConfirmation(BuildContext context, DatabaseService db, Flashcard card, {VoidCallback? onDeleted}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Card?'),
      content: Text('Really delete the card "${card.front}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            await db.deleteCard(card.id);
            if (context.mounted) {
              Navigator.pop(context);
              if (onDeleted != null) onDeleted();
            }
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
