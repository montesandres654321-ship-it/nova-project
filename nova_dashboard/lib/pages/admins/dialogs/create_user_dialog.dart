// lib/pages/admins/dialogs/create_user_dialog.dart
// Extraído de list_tab.dart (_showCreateUserDialog) sin cambios de
// comportamiento ni de estilo. Antes era un StatefulBuilder anónimo de
// ~380 líneas dentro de list_tab.dart; ahora es su propio StatefulWidget.
import 'package:nova_dashboard/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../../models/place.dart';
import '../../../services/admin_service.dart';
import '../admin_tokens.dart';
import '../widgets/admin_form_fields.dart';

class CreateUserDialog extends StatefulWidget {
  final List<Place> places;
  final VoidCallback onSuccess;

  const CreateUserDialog({
    Key? key,
    required this.places,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final formKey   = GlobalKey<FormState>();
  final firstCtrl = TextEditingController();
  final lastCtrl  = TextEditingController();
  final emailCtrl = TextEditingController();
  final userCtrl  = TextEditingController();
  final passCtrl  = TextEditingController();

  String  selectedRole = 'user_place';
  Place?  selectedPlace;
  bool    obscure    = true;
  bool    isCreating = false;

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isCreating = true);
    final result = await AdminService.createUser(
      firstName: firstCtrl.text.trim(),
      lastName:  lastCtrl.text.trim(),
      email:     emailCtrl.text.trim(),
      password:  passCtrl.text,
      username:  userCtrl.text.trim(),
      role:      selectedRole,
      placeId:   selectedRole == 'user_place' ? selectedPlace?.id : null,
    );
    if (!mounted) return;
    setState(() => isCreating = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['success'] == true
            ? '✅ Usuario creado exitosamente'
            : result['error'] ?? 'Error al crear usuario'),
        backgroundColor: result['success'] == true ? AppTheme.success : AppTheme.error,
        duration: const Duration(seconds: 3)));
    if (result['success'] == true) widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _buildHeader(),
            Flexible(child: _buildBody()),
            _buildFooter(),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kAdminBorder, width: 0.5)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: kAdminPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.person_add_rounded,
              size: 17, color: kAdminPrimary),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Crear usuario',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kAdminTextHead)),
              Text('Nuevo acceso al panel de administración',
                  style: TextStyle(fontSize: 11, color: kAdminTextSub)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded,
              size: 19, color: kAdminTextMuted),
          onPressed: isCreating ? null : () => Navigator.pop(context),
          padding: EdgeInsets.zero,
        ),
      ]),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          adminSectionDivider('INFORMACIÓN PERSONAL'),
          adminFormRow2(
            adminTextField(
              label: 'Nombre *',
              ctrl: firstCtrl,
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            adminTextField(
              label: 'Apellido *',
              ctrl: lastCtrl,
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
          ),
          const SizedBox(height: 10),
          adminTextField(
            label: 'Email *',
            ctrl: emailCtrl,
            keyboard: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Requerido';
              if (!v.contains('@')) return 'Email inválido';
              return null;
            },
          ),

          const SizedBox(height: 14),

          adminSectionDivider('ACCESO'),
          adminFormRow2(
            adminTextField(
              label: 'Usuario *',
              ctrl: userCtrl,
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            adminTextField(
              label: 'Contraseña *',
              ctrl: passCtrl,
              obscureText: obscure,
              suffix: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 17, color: kAdminTextSub,
                ),
                onPressed: () => setState(() => obscure = !obscure),
                padding: const EdgeInsets.only(right: 4),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if (v.length < 6) return 'Mínimo 6 caracteres';
                return null;
              },
            ),
          ),

          const SizedBox(height: 14),

          adminSectionDivider('CONFIGURACIÓN'),
          adminLabelField('Rol *',
            DropdownButtonFormField<String>(
              value: selectedRole,
              isDense: true,
              style: const TextStyle(fontSize: 13, color: kAdminTextHead),
              decoration: adminInputDecoration(),
              items: const [
                DropdownMenuItem(
                    value: 'admin_general',
                    child: Text('👑 Administrador General')),
                DropdownMenuItem(
                    value: 'user_general',
                    child: Text('📋 Secretaría de Turismo')),
                DropdownMenuItem(
                    value: 'user_place',
                    child: Text('🏪 Propietario de Lugar')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    selectedRole  = v;
                    selectedPlace = null;
                  });
                }
              },
            ),
          ),

          if (selectedRole == 'user_place') ...[
            const SizedBox(height: 10),
            adminLabelField('Lugar asignado *',
              DropdownButtonFormField<Place>(
                value: selectedPlace,
                isDense: true,
                style: const TextStyle(fontSize: 13, color: kAdminTextHead),
                decoration: adminInputDecoration(),
                hint: const Text('Selecciona el establecimiento',
                    style: TextStyle(fontSize: 12, color: kAdminTextSub)),
                items: widget.places
                    .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(
                          '${p.tipoEmoji} ${p.name} — ${p.lugar}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        )))
                    .toList(),
                onChanged: (p) => setState(() => selectedPlace = p),
                validator: (v) => v == null ? 'Selecciona un lugar' : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kAdminBorder, width: 0.5)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        TextButton(
          onPressed: isCreating ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: kAdminTextMuted,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          ),
          child: const Text('Cancelar', style: TextStyle(fontSize: 13)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: isCreating ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: kAdminPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: isCreating
              ? const SizedBox(
                  width: 17, height: 17,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_rounded, size: 14),
                    SizedBox(width: 7),
                    Text('Crear usuario',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ]),
        ),
      ]),
    );
  }
}
