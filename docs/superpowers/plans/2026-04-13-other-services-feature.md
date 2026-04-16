# Other Services Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the "Outros Serviços" feature allowing clients to request professional services (electrician, plumber, etc.) with a carousel-based category selector, service request form with media attachments, request history, and provider selection flow.

**Architecture:** Feature-independent architecture under `lib/features/other_services/` with data models, pages, and widgets. Navigation integrates via existing TripBottomNav (index 1) and GoRouter. Mock data for all entities (no external DB).

**Tech Stack:** Flutter, GoRouter, flutter_svg, image_picker (new dependency), Dart

---

### Task 1: Data Models

**Files:**
- Create: `lib/features/other_services/data/models/service_category.dart`
- Create: `lib/features/other_services/data/models/service_request.dart`
- Create: `lib/features/other_services/data/models/mock_provider.dart`

- [ ] **Step 1: Create ServiceCategory model**

```dart
// lib/features/other_services/data/models/service_category.dart
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
  ServiceCategory(id: 'electrician', name: 'Eletricista', icon: Icons.electrical_services_rounded, color: Color(0xFFFFA000)),
  ServiceCategory(id: 'plumber', name: 'Encanador', icon: Icons.plumbing_rounded, color: Color(0xFF2196F3)),
  ServiceCategory(id: 'painter', name: 'Pintor', icon: Icons.format_paint_rounded, color: Color(0xFF9C27B0)),
  ServiceCategory(id: 'cleaner', name: 'Faxineira', icon: Icons.cleaning_services_rounded, color: Color(0xFF4CAF50)),
  ServiceCategory(id: 'furniture_assembler', name: 'Montador de Móveis', icon: Icons.chair_rounded, color: Color(0xFF795548)),
  ServiceCategory(id: 'it_technician', name: 'Técnico de Informática', icon: Icons.computer_rounded, color: Color(0xFF607D8B)),
  ServiceCategory(id: 'gardener', name: 'Jardineiro', icon: Icons.grass_rounded, color: Color(0xFF388E3C)),
  ServiceCategory(id: 'mason', name: 'Pedreiro', icon: Icons.construction_rounded, color: Color(0xFFE65100)),
  ServiceCategory(id: 'locksmith', name: 'Chaveiro', icon: Icons.key_rounded, color: Color(0xFFFF5722)),
  ServiceCategory(id: 'ac_technician', name: 'Ar-condicionado', icon: Icons.ac_unit_rounded, color: Color(0xFF00BCD4)),
  ServiceCategory(id: 'carpenter', name: 'Marceneiro', icon: Icons.carpenter_rounded, color: Color(0xFF8D6E63)),
  ServiceCategory(id: 'glazier', name: 'Vidraceiro', icon: Icons.window_rounded, color: Color(0xFF78909C)),
  ServiceCategory(id: 'welder', name: 'Serralheiro', icon: Icons.hardware_rounded, color: Color(0xFF455A64)),
  ServiceCategory(id: 'pest_control', name: 'Dedetizador', icon: Icons.pest_control_rounded, color: Color(0xFFD32F2F)),
];
```

- [ ] **Step 2: Create ServiceRequest model & enums**

```dart
// lib/features/other_services/data/models/service_request.dart

enum ServiceRequestStatus {
  searchingProvider,
  selectProvider,
  awaitingConfirmation,
  scheduled,
}

enum UrgencyType { now, scheduled }

class ServiceRequest {
  final String id;
  final String categoryId;
  final String categoryName;
  final String problem;
  final String details;
  final List<String> mediaPaths;
  final String? address;
  final UrgencyType urgency;
  final DateTime? scheduledDate;
  final ServiceRequestStatus status;
  final DateTime createdAt;

  const ServiceRequest({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.problem,
    required this.details,
    required this.mediaPaths,
    this.address,
    required this.urgency,
    this.scheduledDate,
    required this.status,
    required this.createdAt,
  });
}
```

- [ ] **Step 3: Create MockProvider model with sample data**

```dart
// lib/features/other_services/data/models/mock_provider.dart

class ProviderFeedback {
  final String clientName;
  final String comment;
  final double rating;
  final DateTime date;

  const ProviderFeedback({
    required this.clientName,
    required this.comment,
    required this.rating,
    required this.date,
  });
}

class MockProvider {
  final String id;
  final String name;
  final String initials;
  final String? photoUrl;
  final String rg;
  final DateTime birthDate;
  final String experienceDescription;
  final int yearsOfExperience;
  final double rating;
  final List<String> specialties;
  final List<ProviderFeedback> feedbacks;

  const MockProvider({
    required this.id,
    required this.name,
    required this.initials,
    this.photoUrl,
    required this.rg,
    required this.birthDate,
    required this.experienceDescription,
    required this.yearsOfExperience,
    required this.rating,
    required this.specialties,
    required this.feedbacks,
  });

  static final List<MockProvider> samples = [
    MockProvider(
      id: 'prov_1',
      name: 'Roberto Almeida',
      initials: 'RA',
      rg: '23.456.789-0',
      birthDate: DateTime(1980, 5, 20),
      experienceDescription: 'Eletricista certificado com vasta experiência em instalações residenciais e comerciais.',
      yearsOfExperience: 15,
      rating: 4.9,
      specialties: ['Eletricista', 'Ar-condicionado'],
      feedbacks: [
        ProviderFeedback(clientName: 'Ana C.', comment: 'Excelente profissional, muito pontual.', rating: 5.0, date: DateTime(2026, 3, 10)),
        ProviderFeedback(clientName: 'Pedro M.', comment: 'Resolveu o problema rapidamente.', rating: 4.8, date: DateTime(2026, 2, 22)),
      ],
    ),
    MockProvider(
      id: 'prov_2',
      name: 'Fernanda Costa',
      initials: 'FC',
      rg: '34.567.890-1',
      birthDate: DateTime(1992, 8, 14),
      experienceDescription: 'Especialista em pintura decorativa e reformas residenciais.',
      yearsOfExperience: 8,
      rating: 4.7,
      specialties: ['Pintor', 'Pedreiro'],
      feedbacks: [
        ProviderFeedback(clientName: 'Lucas S.', comment: 'Trabalho impecável, super recomendo.', rating: 5.0, date: DateTime(2026, 3, 5)),
        ProviderFeedback(clientName: 'Mariana R.', comment: 'Boa profissional, entregou no prazo.', rating: 4.5, date: DateTime(2026, 1, 18)),
      ],
    ),
    MockProvider(
      id: 'prov_3',
      name: 'Carlos Eduardo',
      initials: 'CE',
      rg: '45.678.901-2',
      birthDate: DateTime(1988, 11, 3),
      experienceDescription: 'Encanador com experiência em reparos hidráulicos e instalação de aquecedores.',
      yearsOfExperience: 12,
      rating: 4.6,
      specialties: ['Encanador'],
      feedbacks: [
        ProviderFeedback(clientName: 'Juliana F.', comment: 'Profissional competente, preço justo.', rating: 4.7, date: DateTime(2026, 2, 28)),
      ],
    ),
  ];
}
```

- [ ] **Step 4: Commit models**

```bash
git add lib/features/other_services/data/models/
git commit -m "feat(other-services): add data models for categories, requests, and providers"
```

---

### Task 2: Category Carousel & Card Widgets

**Files:**
- Create: `lib/features/other_services/presentation/widgets/category_card.dart`
- Create: `lib/features/other_services/presentation/widgets/category_carousel.dart`

- [ ] **Step 1: Create CategoryCard widget**

Immersive card with gradient background based on category color, icon, and name. Awwwards-style with glassmorphism effect.

- [ ] **Step 2: Create CategoryCarousel widget**

Horizontal PageView with viewportFraction ~0.72 for peek effect. Cards scale up when centered (1.0 vs 0.85). Includes animated dots indicator below.

- [ ] **Step 3: Commit carousel widgets**

```bash
git add lib/features/other_services/presentation/widgets/
git commit -m "feat(other-services): add category carousel with immersive cards"
```

---

### Task 3: Service Request Form & Media Picker

**Files:**
- Create: `lib/features/other_services/presentation/widgets/service_request_form.dart`
- Create: `lib/features/other_services/presentation/widgets/media_attachment_picker.dart`
- Create: `lib/features/other_services/presentation/widgets/urgency_selector.dart`

- [ ] **Step 1: Create UrgencySelector widget**

Toggle between "Preciso agora" and "Quero agendar". When "Quero agendar" is selected, show date/time picker.

- [ ] **Step 2: Create MediaAttachmentPicker widget**

Grid of thumbnails + add button. Supports up to 5 images + 1 video (30s). Uses image_picker. Shows X to remove.

- [ ] **Step 3: Create ServiceRequestForm widget**

Full form with: problem text field, details text area, MediaAttachmentPicker, optional address field, UrgencySelector, and submit button.

- [ ] **Step 4: Add image_picker dependency**

```bash
flutter pub add image_picker
```

- [ ] **Step 5: Commit form widgets**

```bash
git add lib/features/other_services/presentation/widgets/ pubspec.yaml pubspec.lock
git commit -m "feat(other-services): add service request form with media picker and urgency selector"
```

---

### Task 4: ServicesHomePage

**Files:**
- Create: `lib/features/other_services/presentation/pages/services_home_page.dart`

- [ ] **Step 1: Create ServicesHomePage**

Two-section page: header with greeting + CategoryCarousel at top. When category is selected, animates/scrolls down to show ServiceRequestForm below. Submit navigates to MyRequestsPage.

- [ ] **Step 2: Commit home page**

```bash
git add lib/features/other_services/presentation/pages/services_home_page.dart
git commit -m "feat(other-services): add services home page with category selection and form"
```

---

### Task 5: MyRequestsPage + Request List

**Files:**
- Create: `lib/features/other_services/presentation/pages/my_requests_page.dart`
- Create: `lib/features/other_services/presentation/widgets/request_list_tile.dart`
- Create: `lib/features/other_services/presentation/widgets/request_status_badge.dart`

- [ ] **Step 1: Create RequestStatusBadge widget**

Colored badge with icon per status.

- [ ] **Step 2: Create RequestListTile widget**

Card with category name, problem excerpt, status badge, and creation date.

- [ ] **Step 3: Create MyRequestsPage**

ListView of RequestListTiles. FAB button to navigate back to ServicesHomePage. Tapping a tile navigates to RequestDetailPage.

- [ ] **Step 4: Commit requests list page**

```bash
git add lib/features/other_services/presentation/
git commit -m "feat(other-services): add my requests page with list tiles and FAB"
```

---

### Task 6: RequestDetailPage + Status Views

**Files:**
- Create: `lib/features/other_services/presentation/pages/request_detail_page.dart`
- Create: `lib/features/other_services/presentation/widgets/provider_list_tile.dart`
- Create: `lib/features/other_services/presentation/widgets/provider_detail_sheet.dart`

- [ ] **Step 1: Create ProviderListTile widget**

Card with avatar/initials, name, rating stars, years of experience. Tap opens ProviderDetailSheet.

- [ ] **Step 2: Create ProviderDetailSheet bottom sheet**

Full profile: photo/initials, name, RG, birth date, experience description, specialties chips, feedbacks list with ratings. "Selecionar prestador" button.

- [ ] **Step 3: Create RequestDetailPage**

Shows request details + status timeline. Different content per status:
- searchingProvider: animated pulse (searching)
- selectProvider: list of MockProvider samples
- awaitingConfirmation: waiting animation
- scheduled: confirmed info with date

- [ ] **Step 4: Commit detail page**

```bash
git add lib/features/other_services/presentation/
git commit -m "feat(other-services): add request detail page with provider selection and status views"
```

---

### Task 7: Router & Navigation Integration

**Files:**
- Modify: `lib/routes/app_router.dart`
- Modify: `lib/features/trip/presentation/pages/trip_home_page.dart`

- [ ] **Step 1: Add routes to GoRouter**

Add `/services`, `/services/requests`, `/services/requests/:id` routes.

- [ ] **Step 2: Integrate nav in TripHomePage**

When `_selectedNavIndex == 1`, navigate to `/services` via GoRouter.

- [ ] **Step 3: Commit integration**

```bash
git add lib/routes/app_router.dart lib/features/trip/presentation/pages/trip_home_page.dart
git commit -m "feat(other-services): integrate routes and bottom nav navigation"
```
