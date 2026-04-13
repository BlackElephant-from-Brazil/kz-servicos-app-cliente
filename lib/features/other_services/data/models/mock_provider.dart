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
      id: 'provider_1',
      name: 'Roberto Almeida',
      initials: 'RA',
      rg: '11.222.333-4',
      birthDate: DateTime(1980, 5, 12),
      experienceDescription:
          'Eletricista certificado pelo SENAI com experiência em '
          'instalações residenciais e comerciais. Especialista em '
          'quadros de distribuição e automação residencial.',
      yearsOfExperience: 15,
      rating: 4.9,
      specialties: [
        'Instalação elétrica',
        'Quadro de distribuição',
        'Automação residencial',
      ],
      feedbacks: [
        ProviderFeedback(
          clientName: 'Ana Costa',
          comment: 'Excelente profissional, resolveu o problema rápido.',
          rating: 5.0,
          date: DateTime(2026, 3, 20),
        ),
        ProviderFeedback(
          clientName: 'Pedro Lima',
          comment: 'Pontual e muito educado. Recomendo!',
          rating: 4.8,
          date: DateTime(2026, 2, 15),
        ),
      ],
    ),
    MockProvider(
      id: 'provider_2',
      name: 'Fernanda Souza',
      initials: 'FS',
      rg: '55.666.777-8',
      birthDate: DateTime(1992, 9, 3),
      experienceDescription:
          'Encanadora com formação técnica e experiência em '
          'manutenção hidráulica predial. Atende residências '
          'e pequenos comércios.',
      yearsOfExperience: 8,
      rating: 4.7,
      specialties: [
        'Reparo hidráulico',
        'Instalação de aquecedor',
        'Desentupimento',
      ],
      feedbacks: [
        ProviderFeedback(
          clientName: 'Marcos Vieira',
          comment: 'Muito competente, resolveu um vazamento difícil.',
          rating: 4.7,
          date: DateTime(2026, 3, 10),
        ),
      ],
    ),
    MockProvider(
      id: 'provider_3',
      name: 'Antônio Ferreira',
      initials: 'AF',
      photoUrl: 'https://example.com/photo_provider_3.jpg',
      rg: '99.888.777-6',
      birthDate: DateTime(1975, 1, 28),
      experienceDescription:
          'Técnico em refrigeração com certificação CREA. '
          'Especializado em instalação e manutenção de sistemas '
          'split e multi-split de todas as marcas.',
      yearsOfExperience: 20,
      rating: 4.8,
      specialties: [
        'Instalação split',
        'Manutenção preventiva',
        'Carga de gás',
        'Multi-split',
      ],
      feedbacks: [
        ProviderFeedback(
          clientName: 'Juliana Rocha',
          comment:
              'Profissional muito experiente. Fez a manutenção '
              'completa e explicou tudo direitinho.',
          rating: 5.0,
          date: DateTime(2026, 4, 1),
        ),
        ProviderFeedback(
          clientName: 'Ricardo Mendes',
          comment: 'Bom serviço, mas demorou um pouco para chegar.',
          rating: 4.5,
          date: DateTime(2026, 3, 25),
        ),
      ],
    ),
  ];
}
