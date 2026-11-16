import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controller.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class SetorialOrderDetails extends StatefulWidget {
  const SetorialOrderDetails({super.key, required this.controller});
  final SetorialController controller;
  @override
  State<SetorialOrderDetails> createState() => _SetorialOrderDetailsState();
}

class _SetorialOrderDetailsState extends State<SetorialOrderDetails> {
  late final description = TextEditingController(
    text: widget.controller.draft.description,
  );
  late final location = TextEditingController(
    text: widget.controller.draft.location,
  );
  bool changingLocation = false;
  @override
  void dispose() {
    description.dispose();
    location.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  bool _capturing = false;

  Future<void> capture() async {
    if (_capturing || !widget.controller.settings.allowPhotos) return;
    if (widget.controller.draft.photos.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limite de 4 fotos por OS.')),
      );
      return;
    }
    setState(() => _capturing = true);
    try {
      final XFile? picture = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1600,
      );
      if (!mounted || picture == null) return;
      if (!widget.controller.settings.allowPhotos) return;
      setState(() => widget.controller.draft.photos.add(picture.path));
      widget.controller.photoAdded();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível acessar a câmera do tablet.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: LayoutBuilder(
          builder: (_, constraints) {
            final wide = constraints.maxWidth >= 850;
            final c = widget.controller;
            final left = SCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conte o que está acontecendo',
                    style: TextStyle(
                      fontSize: wide ? 27 : 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 17),
                  const Text(
                    'Local',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (changingLocation)
                    TextField(
                      controller: location,
                      onChanged: c.selectLocation,
                      decoration: InputDecoration(
                        hintText: 'Informe o local do problema',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => changingLocation = false),
                          icon: const Icon(Icons.check),
                        ),
                      ),
                    )
                  else
                    OutlinedButton(
                      onPressed: () => setState(() => changingLocation = true),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(64),
                        foregroundColor: SColors.ink,
                        side: const BorderSide(color: SColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: SColors.primary,
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              c.draft.location,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Text(
                            'Alterar',
                            style: TextStyle(
                              color: SColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 22),
                  const Text(
                    'Prioridade',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAF8),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Row(
                      children: [
                        for (final p in ['Baixa', 'Média', 'Alta', 'Urgente'])
                          Expanded(
                            child: InkWell(
                              onTap: () => c.selectPriority(p),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                height: 51,
                                decoration: BoxDecoration(
                                  color: c.draft.priority == p
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: c.draft.priority == p
                                      ? const [SColors.shadow]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    p,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: c.draft.priority == p
                                          ? (p == 'Urgente'
                                                ? SColors.red
                                                : p == 'Média'
                                                ? SColors.amber
                                                : SColors.primary)
                                          : SColors.muted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Descrição do problema',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: description,
                    minLines: 5,
                    maxLines: 6,
                    maxLength: 300,
                    onChanged: c.selectDescription,
                    style: const TextStyle(fontSize: 17),
                    decoration: InputDecoration(
                      hintText: 'Descreva o problema com detalhes...',
                      hintStyle: const TextStyle(color: SColors.muted),
                      fillColor: SColors.soft,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  if (c.error != null)
                    Text(c.error!, style: const TextStyle(color: SColors.red)),
                ],
              ),
            );
            final right = Column(
              children: [
                SCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fotos (opcional)',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (c.settings.allowPhotos) ...[
                        InkWell(
                          onTap: _capturing ? null : capture,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 124,
                            width: 160,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFACB8EF),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  color: SColors.primary,
                                  size: 32,
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  _capturing
                                      ? 'Abrindo câmera...'
                                      : 'Tirar foto',
                                  style: const TextStyle(
                                    color: SColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${c.draft.photos.length}/4 fotos',
                                  style: const TextStyle(
                                    color: SColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (c.draft.photos.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final path in c.draft.photos)
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(path),
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const SizedBox(
                                                  width: 90,
                                                  height: 90,
                                                  child: Icon(
                                                    Icons.broken_image_outlined,
                                                  ),
                                                ),
                                      ),
                                    ),
                                    Positioned(
                                      right: -6,
                                      top: -6,
                                      child: IconButton.filledTonal(
                                        tooltip: 'Remover foto',
                                        icon: const Icon(Icons.close, size: 16),
                                        onPressed: () {
                                          setState(
                                            () => c.draft.photos.remove(path),
                                          );
                                          c.photoAdded();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Text(
                          'Fotos anexadas ao rascunho neste dispositivo. '
                          'O envio ao servidor será integrado posteriormente.',
                          style: TextStyle(color: SColors.muted, fontSize: 12),
                        ),
                      ] else
                        const Text(
                          'Fotos desativadas para este tablet.',
                          style: TextStyle(color: SColors.muted),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumo',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _line('Tipo', c.draft.type ?? '—'),
                      _line('Setor', c.settings.sector),
                      _line('Solicitante', c.draft.applicant?.firstName ?? '—'),
                      _line('Prioridade', c.draft.priority),
                    ],
                  ),
                ),
              ],
            );
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 22, 32, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SProgress(step: 2),
                  const SizedBox(height: 25),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 54, child: left),
                        const SizedBox(width: 24),
                        Expanded(flex: 46, child: right),
                      ],
                    )
                  else
                    Column(children: [left, const SizedBox(height: 22), right]),
                ],
              ),
            );
          },
        ),
      ),
      SFooter(
        controller: widget.controller,
        secondary: 'Voltar',
        onSecondary: () => widget.controller.go(SectorPage.type),
        primary: 'Enviar ordem de serviço',
        onPrimary: () async {
          widget.controller.selectDescription(description.text);
          widget.controller.selectLocation(location.text);
          await widget.controller.submit();
        },
      ),
    ],
  );
  Widget _line(String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      children: [
        Expanded(
          child: Text(
            a,
            style: const TextStyle(color: SColors.muted, fontSize: 15),
          ),
        ),
        Expanded(
          child: Text(
            b,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
      ],
    ),
  );
}
