import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_servicos_app/core/constants/app_colors.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 8),
          _buildHeader(context),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _SecuritySection(
                    items: [
                      _SecurityItem(
                        icon: Icons.lock_rounded,
                        label: 'Alterar Senha',
                        subtitle: 'Atualize sua senha de acesso',
                        onTap: () => _showChangeDialog(
                          context,
                          title: 'Alterar Senha',
                          fields: [
                            _DialogField(
                              label: 'Senha atual',
                              obscure: true,
                            ),
                            _DialogField(
                              label: 'Nova senha',
                              obscure: true,
                            ),
                            _DialogField(
                              label: 'Confirmar nova senha',
                              obscure: true,
                            ),
                          ],
                        ),
                      ),
                      _SecurityItem(
                        icon: Icons.email_rounded,
                        label: 'Alterar E-mail',
                        subtitle: 'ana.carolina@email.com',
                        onTap: () => _showChangeDialog(
                          context,
                          title: 'Alterar E-mail',
                          fields: [
                            _DialogField(label: 'Novo e-mail'),
                            _DialogField(
                              label: 'Senha atual',
                              obscure: true,
                            ),
                          ],
                        ),
                      ),
                      _SecurityItem(
                        icon: Icons.phone_rounded,
                        label: 'Alterar Telefone',
                        subtitle: '(11) 99999-9999',
                        onTap: () => _showChangeDialog(
                          context,
                          title: 'Alterar Telefone',
                          fields: [
                            _DialogField(
                              label: 'Novo telefone',
                              keyboard: TextInputType.phone,
                            ),
                            _DialogField(
                              label: 'Senha atual',
                              obscure: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _DeleteAccountButton(
                    onTap: () => _showDeleteConfirmation(context),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 22,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Configurações de Segurança',
              style: TextStyle(
                fontFamily: 'OutfitBlack',
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeDialog(
    BuildContext context, {
    required String title,
    required List<_DialogField> fields,
  }) {
    final controllers = List.generate(
      fields.length,
      (_) => TextEditingController(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'OutfitBlack',
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < fields.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              TextField(
                controller: controllers[i],
                obscureText: fields[i].obscure,
                keyboardType: fields[i].keyboard,
                decoration: InputDecoration(
                  labelText: fields[i].label,
                  labelStyle: const TextStyle(
                    fontFamily: 'QuasimodoSemiBold',
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.secondary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'QuasimodoSemiBold',
                color: Color(0xFF999999),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title realizado com sucesso!'),
                  backgroundColor: AppColors.secondary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Salvar',
              style: TextStyle(
                fontFamily: 'QuasimodoSemiBold',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Excluir Conta',
          style: TextStyle(
            fontFamily: 'OutfitBlack',
            fontSize: 18,
            color: Colors.red,
          ),
        ),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? '
          'Esta ação não pode ser desfeita e todos os seus dados serão '
          'permanentemente removidos.',
          style: TextStyle(
            fontFamily: 'QuasimodoSemiBold',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'QuasimodoSemiBold',
                color: Color(0xFF999999),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Solicitação de exclusão enviada.',
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Excluir',
              style: TextStyle(
                fontFamily: 'QuasimodoSemiBold',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogField {
  final String label;
  final bool obscure;
  final TextInputType? keyboard;

  const _DialogField({
    required this.label,
    this.obscure = false,
    this.keyboard,
  });
}

class _SecuritySection extends StatelessWidget {
  final List<_SecurityItem> items;

  const _SecuritySection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFEEEEEE),
                ),
              ),
            items[i],
          ],
        ],
      ),
    );
  }
}

class _SecurityItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _SecurityItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteAccountButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(
              'Excluir Conta',
              style: TextStyle(
                fontFamily: 'QuasimodoSemiBold',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
