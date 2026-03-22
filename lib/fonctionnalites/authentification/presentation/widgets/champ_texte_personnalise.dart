import 'package:flutter/material.dart';
import '../../../../core/utilitaires/constantes.dart';

/// Champ texte réutilisable avec support mot de passe et validation
class ChampTextePersonnalise extends StatefulWidget {
  final TextEditingController controleur;
  final String libelle;
  final IconData icone;
  final bool estMotDePasse;
  final TextInputType typeClavier;
  final String? Function(String?)? validateur;

  const ChampTextePersonnalise({
    super.key,
    required this.controleur,
    required this.libelle,
    required this.icone,
    this.estMotDePasse = false,
    this.typeClavier = TextInputType.text,
    this.validateur,
  });

  @override
  State<ChampTextePersonnalise> createState() => _ChampTextePersonnaliseState();
}

class _ChampTextePersonnaliseState extends State<ChampTextePersonnalise> {
  bool _texteVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controleur,
      obscureText: widget.estMotDePasse && !_texteVisible,
      keyboardType: widget.typeClavier,
      validator: widget.validateur,
      decoration: InputDecoration(
        labelText: widget.libelle,
        prefixIcon: Icon(widget.icone, color: CodeCouleurs.primaire, size: 22),
        suffixIcon: widget.estMotDePasse
            ? IconButton(
                icon: Icon(
                  _texteVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: CodeCouleurs.texteSecondaire,
                  size: 20,
                ),
                onPressed: () => setState(() => _texteVisible = !_texteVisible),
              )
            : null,
        filled: true,
        fillColor: Colors.transparent,
        labelStyle: const TextStyle(color: CodeCouleurs.texteSecondaire, fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.rayonBordurePetit),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.rayonBordurePetit),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.rayonBordurePetit),
          borderSide: const BorderSide(color: CodeCouleurs.primaire, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.rayonBordurePetit),
          borderSide: const BorderSide(color: CodeCouleurs.rouge, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.rayonBordurePetit),
          borderSide: const BorderSide(color: CodeCouleurs.rouge, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Marges.moyenne,
          vertical: Marges.moyenne,
        ),
      ),
    );
  }
}
