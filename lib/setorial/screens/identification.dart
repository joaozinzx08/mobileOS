import 'package:flutter/material.dart';
import '../controller.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class SetorialIdentification extends StatefulWidget {
  const SetorialIdentification({super.key, required this.controller});
  final SetorialController controller;
  @override
  State<SetorialIdentification> createState() => _SetorialIdentificationState();
}

class _SetorialIdentificationState extends State<SetorialIdentification> {
  final registration = TextEditingController(text: '');
  String pin = '';
  @override
  void dispose() {
    registration.dispose();
    super.dispose();
  }

  void number(String text) {
    setState(() {
      if (text == 'Limpar') {
        pin = '';
      } else if (text == '⌫') {
        if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
      } else if (pin.length < 4) {
        pin += text;
      }
    });
    widget.controller.touch();
  }

  Future<void> next() async {
    if (registration.text.trim().isEmpty || pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe sua matrícula e um PIN de 4 dígitos.'),
        ),
      );
      return;
    }
    await widget.controller.submitPin(registration.text, pin);
    if (mounted) setState(() => pin = '');
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) {
      final wide = constraints.maxWidth >= 850;
      final entry = SCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quem está abrindo a OS?',
              style: TextStyle(
                fontSize: wide ? 31 : 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Digite sua matrícula e o PIN, ou aproxime o crachá do leitor.',
              style: TextStyle(color: SColors.muted, fontSize: 16),
            ),
            const SizedBox(height: 25),
            const Text(
              'Matrícula',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: registration,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.badge_outlined,
                  color: SColors.primary,
                ),
                hintText: 'Ex.: 04218',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: SColors.primary),
                  borderRadius: BorderRadius.circular(18),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 22),
            const Text(
              'PIN (4 dígitos)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: SColors.soft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: SColors.ink),
                  const SizedBox(width: 16),
                  for (var i = 0; i < 4; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 22),
                      child: Icon(
                        i < pin.length ? Icons.circle : Icons.circle_outlined,
                        color: i < pin.length
                            ? SColors.ink
                            : const Color(0xFFB3B8D5),
                        size: 15,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                '─────────────    ou    ─────────────',
                style: TextStyle(color: SColors.muted),
              ),
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Leitura de QR estará disponível após integração com a API.',
                  ),
                ),
              ),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFB4BCEB),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.qr_code_2, size: 39, color: SColors.primary),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aproxime o crachá QR',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Leitor indisponível no modo de demonstração',
                            style: TextStyle(
                              color: SColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.controller.error != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.controller.error!,
                style: const TextStyle(
                  color: SColors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 20),
            SPrimaryButton(
              widget.controller.isCheckingPin ? 'Verificando...' : 'Continuar',
              onPressed: widget.controller.isCheckingPin ? null : next,
            ),
          ],
        ),
      );
      final keypad = SCard(
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: wide ? 1.67 : 1.85,
              children: [
                for (final key in [
                  '1',
                  '2',
                  '3',
                  '4',
                  '5',
                  '6',
                  '7',
                  '8',
                  '9',
                  'Limpar',
                  '0',
                  '⌫',
                ])
                  Material(
                    color: SColors.soft,
                    borderRadius: BorderRadius.circular(22),
                    child: InkWell(
                      onTap: () => number(key),
                      borderRadius: BorderRadius.circular(22),
                      child: Center(
                        child: Text(
                          key,
                          style: TextStyle(
                            color: key == 'Limpar'
                                ? SColors.muted
                                : SColors.ink,
                            fontSize: key == 'Limpar' ? 17 : 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Esqueceu o PIN? Procure o gestor do setor.',
              style: TextStyle(color: SColors.muted, fontSize: 13),
            ),
          ],
        ),
      );
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 26, 32, 28),
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: entry),
                  const SizedBox(width: 24),
                  Expanded(child: keypad),
                ],
              )
            : Column(children: [entry, const SizedBox(height: 20), keypad]),
      );
    },
  );
}
