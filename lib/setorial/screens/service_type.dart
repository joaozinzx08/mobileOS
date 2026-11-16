import 'package:flutter/material.dart';
import '../controller.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class SetorialServiceType extends StatelessWidget {
  const SetorialServiceType({super.key, required this.controller});
  final SetorialController controller;
  static const options = <(String, IconData)>[
    ('Elétrica', Icons.bolt_outlined),
    ('Hidráulica', Icons.water_drop_outlined),
    ('Ar-condicionado', Icons.ac_unit_outlined),
    ('TI e rede', Icons.desktop_windows_outlined),
    ('Mobiliário', Icons.inventory_2_outlined),
    ('Mecânica', Icons.build_circle_outlined),
    ('Manutenção geral', Icons.build_outlined),
    ('Segurança', Icons.shield_outlined),
    ('Outros', Icons.more_horiz),
  ];
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: LayoutBuilder(
          builder: (_, constraints) {
            final wide = constraints.maxWidth >= 900;
            final cols = wide
                ? 4
                : constraints.maxWidth >= 580
                ? 2
                : 1;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                constraints.maxWidth < 600 ? 16 : 32,
                28,
                constraints.maxWidth < 600 ? 16 : 32,
                26,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SProgress(step: 1),
                  const SizedBox(height: 20),
                  Text(
                    'Qual é o tipo de serviço?',
                    style: TextStyle(
                      fontSize: wide ? 34 : 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Toque na opção que mais se parece com o problema.',
                    style: TextStyle(fontSize: 16, color: SColors.muted),
                  ),
                  const SizedBox(height: 25),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: options.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 19,
                      crossAxisSpacing: 19,
                      mainAxisExtent: cols == 1 ? 114 : (wide ? 174 : 155),
                    ),
                    itemBuilder: (_, index) {
                      final item = options[index];
                      final selected = controller.draft.type == item.$1;
                      return Material(
                        color: selected ? SColors.primary : Colors.white,
                        elevation: selected ? 7 : 0,
                        shadowColor: SColors.primary.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(26),
                        child: InkWell(
                          onTap: () => controller.selectType(item.$1),
                          borderRadius: BorderRadius.circular(26),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: selected
                                    ? SColors.primary
                                    : SColors.border,
                                width: 2,
                              ),
                            ),
                            child: Semantics(
                              button: true,
                              selected: selected,
                              label: "Serviço: ${item.$1}",
                              child: Stack(
                                children: [
                                  if (selected)
                                    const Positioned(
                                      top: 14,
                                      right: 14,
                                      child: CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Color(0xFF72FFBE),
                                        child: Icon(
                                          Icons.check,
                                          size: 19,
                                          color: SColors.ink,
                                        ),
                                      ),
                                    ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(
                                            cols == 1 ? 10 : 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? Colors.white24
                                                : SColors.soft,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                          child: Icon(
                                            item.$2,
                                            size: cols == 1 ? 24 : 34,
                                            color: selected
                                                ? Colors.white
                                                : SColors.primary,
                                          ),
                                        ),
                                        SizedBox(height: cols == 1 ? 5 : 12),
                                        Text(
                                          item.$1,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: selected
                                                ? Colors.white
                                                : SColors.ink,
                                            fontSize: cols == 1 ? 16 : 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      SFooter(
        controller: controller,
        secondary: 'Cancelar',
        onSecondary: controller.backHome,
        primary: 'Continuar',
        onPrimary: controller.draft.type == null
            ? null
            : () => controller.go(SectorPage.details),
      ),
    ],
  );
}
