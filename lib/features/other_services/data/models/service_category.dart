import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

const List<ServiceCategory> kServiceCategories = [
  ServiceCategory(
    id: 'electrician',
    name: 'Eletricista',
    icon: Icons.electrical_services,
    color: Color(0xFFF9A825),
  ),
  ServiceCategory(
    id: 'plumber',
    name: 'Encanador',
    icon: Icons.plumbing,
    color: Color(0xFF1E88E5),
  ),
  ServiceCategory(
    id: 'painter',
    name: 'Pintor',
    icon: Icons.format_paint,
    color: Color(0xFFE53935),
  ),
  ServiceCategory(
    id: 'cleaner',
    name: 'Faxineira',
    icon: Icons.cleaning_services,
    color: Color(0xFF43A047),
  ),
  ServiceCategory(
    id: 'furniture_assembler',
    name: 'Montador de Móveis',
    icon: Icons.handyman,
    color: Color(0xFF8D6E63),
  ),
  ServiceCategory(
    id: 'it_technician',
    name: 'Técnico de Informática',
    icon: Icons.computer,
    color: Color(0xFF5E35B1),
  ),
  ServiceCategory(
    id: 'gardener',
    name: 'Jardineiro',
    icon: Icons.grass,
    color: Color(0xFF2E7D32),
  ),
  ServiceCategory(
    id: 'mason',
    name: 'Pedreiro',
    icon: Icons.construction,
    color: Color(0xFFFF8F00),
  ),
  ServiceCategory(
    id: 'locksmith',
    name: 'Chaveiro',
    icon: Icons.key,
    color: Color(0xFF6D4C41),
  ),
  ServiceCategory(
    id: 'ac_technician',
    name: 'Ar-condicionado',
    icon: Icons.ac_unit,
    color: Color(0xFF00ACC1),
  ),
  ServiceCategory(
    id: 'carpenter',
    name: 'Marceneiro',
    icon: Icons.carpenter,
    color: Color(0xFFD84315),
  ),
  ServiceCategory(
    id: 'glazier',
    name: 'Vidraceiro',
    icon: Icons.window,
    color: Color(0xFF039BE5),
  ),
  ServiceCategory(
    id: 'welder',
    name: 'Serralheiro',
    icon: Icons.hardware,
    color: Color(0xFF546E7A),
  ),
  ServiceCategory(
    id: 'pest_control',
    name: 'Dedetizador',
    icon: Icons.pest_control,
    color: Color(0xFF7CB342),
  ),
];
