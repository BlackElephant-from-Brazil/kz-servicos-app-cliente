enum ServiceRequestStatus {
  searchingProvider,
  selectProvider,
  awaitingConfirmation,
  scheduled,
}

enum UrgencyType {
  now,
  scheduled,
}

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

  static final List<ServiceRequest> mockRequests = [
    ServiceRequest(
      id: 'sr_1',
      categoryId: 'electrician',
      categoryName: 'Eletricista',
      problem: 'Curto-circuito na cozinha',
      details:
          'Ao ligar o micro-ondas e a geladeira ao mesmo tempo, '
          'o disjuntor desarma. Já tentei trocar o disjuntor, '
          'mas o problema persiste.',
      mediaPaths: ['assets/images/placeholder.png'],
      address: 'Rua das Flores, 123 - Centro, São Paulo - SP',
      urgency: UrgencyType.now,
      status: ServiceRequestStatus.searchingProvider,
      createdAt: DateTime(2026, 4, 13, 9, 30),
    ),
    ServiceRequest(
      id: 'sr_2',
      categoryId: 'plumber',
      categoryName: 'Encanador',
      problem: 'Vazamento no banheiro',
      details:
          'O registro do chuveiro está pingando constantemente. '
          'Já fechei o registro geral, mas preciso de reparo '
          'urgente para normalizar o uso.',
      mediaPaths: [],
      address: 'Av. Brasil, 456 - Jardim América, Rio de Janeiro - RJ',
      urgency: UrgencyType.scheduled,
      scheduledDate: DateTime(2026, 4, 15, 14, 0),
      status: ServiceRequestStatus.selectProvider,
      createdAt: DateTime(2026, 4, 12, 16, 45),
    ),
    ServiceRequest(
      id: 'sr_3',
      categoryId: 'ac_technician',
      categoryName: 'Ar-condicionado',
      problem: 'Limpeza e manutenção preventiva',
      details:
          'Ar-condicionado split 12.000 BTUs não utilizado há '
          '6 meses. Precisa de limpeza completa dos filtros e '
          'verificação do gás refrigerante.',
      mediaPaths: ['assets/images/placeholder.png'],
      address: 'Rua Palmeiras, 789 - Boa Viagem, Recife - PE',
      urgency: UrgencyType.scheduled,
      scheduledDate: DateTime(2026, 4, 20, 10, 0),
      status: ServiceRequestStatus.scheduled,
      createdAt: DateTime(2026, 4, 10, 11, 20),
    ),
  ];
}
