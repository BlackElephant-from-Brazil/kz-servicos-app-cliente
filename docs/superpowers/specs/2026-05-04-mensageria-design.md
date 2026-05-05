# Spec: Sistema de Mensageria — KZ Serviços App Cliente

**Data:** 2026-05-04  
**Status:** Aprovado  
**Escopo:** Chat cliente ↔ motorista vinculado às corridas

---

## Visão Geral

Implementar mensageria real (Supabase) substituindo os mocks existentes. O sistema permite que o cliente troque mensagens com o motorista em corridas com status `scheduled`, `started` ou `finished`. Cada corrida é uma sala de chat. A sala é criada lazily na primeira vez que o usuário abre o chat.

---

## 1. Mudanças de Rota

| Antes | Depois |
|-------|--------|
| `/chat/:conversationId` | `/chat/:tripId` |

O parâmetro passa a ser o ID da viagem (UUID do Supabase), não mais um ID de conversa mock.

---

## 2. Domain Layer

### Entidades Novas

**`lib/features/chat/domain/entities/chat_room.dart`**
```
ChatRoom {
  id: String
  tripId: String
  clientId: String
  providerId: String
  isActive: bool
  createdAt: DateTime
}
```

**`lib/features/chat/domain/entities/chat_message.dart`**
```
ChatMessage {
  id: String
  chatRoomId: String
  senderId: String
  message: String
  isFromCurrentUser: bool   // senderId == auth.uid(), resolvido no repositório
  createdAt: DateTime
  isRead: bool
}
```

### Interface do Repositório

**`lib/features/chat/domain/repositories/chat_repository.dart`**

```dart
abstract class ChatRepository {
  /// Busca sala para o trip. Se não existir, cria uma nova.
  Future<ChatRoom> getOrCreateRoomForTrip(String tripId);

  /// Mensagens da sala, ordenadas por created_at ASC.
  Future<List<ChatMessage>> getMessages(String chatRoomId);

  /// Envia mensagem de texto.
  Future<ChatMessage> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String text,
  });

  /// Stream de novas mensagens via Supabase Realtime.
  Stream<ChatMessage> subscribeToMessages(String chatRoomId);

  /// Marca todas mensagens não lidas (sender != userId) como lidas.
  Future<void> markAllAsRead(String chatRoomId, String userId);

  /// Busca salas para múltiplas viagens de uma vez (batch).
  /// Retorna mapa tripId → ChatRoom? (null se não existe sala ainda).
  Future<Map<String, ChatRoom?>> getRoomsForTrips(List<String> tripIds);
}
```

### Adição ao TripRepository Existente

```dart
// Em trip_repository.dart (interface)
Future<List<ScheduledTrip>> getChatEligibleTrips(String clientId);

// Em trip_repository_impl.dart
// status IN ['scheduled', 'started', 'finished']
// Reutiliza ScheduledTripModel.fromJson — sem novo model necessário
```

---

## 3. Data Layer

### `ChatRepositoryImpl`

**`lib/features/chat/data/repositories/chat_repository_impl.dart`**

**`getOrCreateRoomForTrip(tripId)`:**
1. Query: `chat_rooms?trip_id=eq.{tripId}&limit=1`
2. Se existe → retorna `ChatRoomModel.fromJson(...).toEntity()`
3. Se não existe:
   - Fetch: `trips?select=client_id,driver_profiles(provider_profiles(user_id))&id=eq.{tripId}`
   - Extrai `clientId` e `driverUserId` (provider_profiles.user_id)
   - Insert: `chat_rooms` com `{trip_id, client_id, provider_id: driverUserId}`
   - Retorna sala criada

**`getMessages(chatRoomId)`:**
- Query: `chat_messages?chat_room_id=eq.{chatRoomId}&order=created_at.asc`
- `isFromCurrentUser` = `senderId == supabase.auth.currentUser!.id`

**`sendMessage(...)`:**
- Insert: `chat_messages` com `{chat_room_id, sender_id, message, message_type: 'text'}`
- Retorna mensagem inserida

**`subscribeToMessages(chatRoomId)`:**
```dart
supabase.channel('chat-room-$chatRoomId')
  .on('postgres_changes', event: INSERT, table: 'chat_messages',
      filter: 'chat_room_id=eq.$chatRoomId')
  → converte payload para ChatMessage, emite no StreamController
```

**`markAllAsRead(chatRoomId, userId)`:**
- Patch: `chat_messages?chat_room_id=eq.{chatRoomId}&is_read=eq.false&sender_id=neq.{userId}`
- Body: `{is_read: true, read_at: now()}`

**`getRoomsForTrips(tripIds)`:**
- Query: `chat_rooms?trip_id=in.({tripIds.join(',')})&select=*`
- Retorna `Map<String, ChatRoom?>` indexado por `trip_id`

### Models

**`lib/features/chat/data/models/chat_room_model.dart`**  
`fromJson` + `toEntity()` — campos diretos da tabela `chat_rooms`.

**`lib/features/chat/data/models/chat_message_model.dart`**  
`fromJson` + `toEntity(currentUserId)` — resolve `isFromCurrentUser`.

---

## 4. Presentation Layer

### `MessagesCubit` + `MessagesState`

**`lib/features/chat/presentation/cubit/messages_cubit.dart`**

States:
```
MessagesInitial
MessagesLoading
MessagesLoaded {
  trips: List<ScheduledTrip>,
  rooms: Map<String, ChatRoom?>,
  lastMessages: Map<String, ChatMessage?>,
  unreadCounts: Map<String, int>,
}
MessagesError { message: String }
```

`load()`:
1. `clientId = supabase.auth.currentUser!.id`
2. `trips = tripRepository.getChatEligibleTrips(clientId)`
3. Se `trips` vazio → emite `MessagesLoaded` com mapas vazios
4. `roomIds` das rooms existentes (via `getRoomsForTrips`)
5. Batch: busca last messages e unread counts para os roomIds
6. Emite `MessagesLoaded` com todos os mapas preenchidos

### `ChatCubit` + `ChatState`

**`lib/features/chat/presentation/cubit/chat_cubit.dart`**

States:
```
ChatInitial
ChatLoading
ChatLoaded { room: ChatRoom, messages: List<ChatMessage>, isSending: bool }
ChatError { message: String }
```

`init(tripId)`:
1. Emite `ChatLoading`
2. `room = chatRepository.getOrCreateRoomForTrip(tripId)`
3. `messages = chatRepository.getMessages(room.id)`
4. `chatRepository.markAllAsRead(room.id, currentUserId)`
5. Subscreve `chatRepository.subscribeToMessages(room.id)` → appenda ao estado
6. Emite `ChatLoaded`

`sendMessage(text)`:
1. Atualiza estado com `isSending: true`
2. Adiciona mensagem otimista à lista (id temporário)
3. `chatRepository.sendMessage(...)` — Realtime trará a versão real
4. `isSending: false`

`dispose`: cancela `StreamSubscription` do Realtime.

---

## 5. Mudanças de UI

### `TripDetailsSheet`

Adicionar ao final do `build`, logo antes do `SizedBox` de padding inferior, quando `status ∈ {scheduled, started, finished}`:

```dart
if (['scheduled', 'started', 'finished'].contains(trip.status))
  Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.chat_bubble_rounded, size: 18),
        label: const Text('Abrir chat com motorista'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          Navigator.pop(context); // fecha o bottom sheet
          context.push('/chat/${trip.id}');
        },
      ),
    ),
  ),
```

### `MessagesPage`

- Envolve o conteúdo em `BlocProvider<MessagesCubit>` criado inline na rota
- Substitui `MockConversation.samples` por `BlocBuilder<MessagesCubit, MessagesState>`
- `_ConversationTile` recebe `trip: ScheduledTrip` e `room: ChatRoom?`
- `onTap`: `context.push('/chat/${trip.id}')`
- Last message preview: `room?.lastMessage ?? ''` (ChatRoom ganha campo computed)
- Unread count: contagem de mensagens não lidas da sala (carregado com os rooms)

> **Implementação de last message + unread count:** O `MessagesCubit.load()` faz duas queries batch adicionais após buscar as rooms:
> 1. Última mensagem por sala: `chat_messages?chat_room_id=in.({roomIds})&order=created_at.desc` — agrupa client-side por `chat_room_id`, mantendo só o primeiro de cada grupo.
> 2. Contagem de não-lidos: `chat_messages?chat_room_id=in.({roomIds})&is_read=eq.false&sender_id=neq.{currentUserId}` — agrupa e conta client-side.
> Esses dados são mesclados no estado como `MessagesLoaded { ..., lastMessages: Map<String, ChatMessage?>, unreadCounts: Map<String, int> }`.

### `ChatPage`

- Parâmetro muda de `conversationId` para `tripId`
- Envolve em `BlocProvider<ChatCubit>` criado inline na rota com `..init(tripId)`
- Header: exibe `origin → destination` — esses valores vêm do `ScheduledTrip` passado como `extra` na navegação (`context.push('/chat/${trip.id}', extra: trip)`). O `ChatPage` recebe o trip via construtor. Se `extra` for null (navegação direta por deep link), o cubit busca o trip pelo `tripId` para montar o header.
- Mensagens: `BlocBuilder` sobre `ChatLoaded.messages`
- `_MessageBubble` usa `message.isFromCurrentUser` em vez de `message.isFromUser`
- `StreamSubscription` gerenciada pelo cubit (não pelo widget)
- Preset messages mantidos

### `AppRouter`

```dart
// Antes
GoRoute(path: '/chat/:conversationId', ...)

// Depois
GoRoute(
  path: '/chat/:tripId',
  builder: (context, state) {
    final tripId = state.pathParameters['tripId']!;
    return BlocProvider(
      create: (_) => ChatCubit(
        chatRepository: ChatRepositoryImpl(client: supabaseClient),
      )..init(tripId),
      child: ChatPage(tripId: tripId),
    );
  },
),
GoRoute(
  path: '/messages',
  builder: (context, state) => BlocProvider(
    create: (_) => MessagesCubit(
      tripRepository: TripRepositoryImpl(client: supabaseClient),
      chatRepository: ChatRepositoryImpl(client: supabaseClient),
    )..load(),
    child: const MessagesPage(),
  ),
),
```

> **Nota:** `Supabase.instance.client` é um singleton acessível globalmente após `Supabase.initialize`. Os builders do router usam diretamente `Supabase.instance.client` — sem necessidade de passar via parâmetro.

---

## 6. Dados Necessários nos Cards da MessagesPage

Para exibir corretamente cada card na MessagesPage, o `MessagesLoaded` carrega:
- `trips`: lista de `ScheduledTrip` (origin, destination, scheduledDatetime)
- `rooms`: `Map<tripId, ChatRoom?>` 
- Último mensagem e unread count: buscados separadamente em batch e incluídos em `ChatRoom` como campos opcionais (`lastMessage: String?`, `lastMessageAt: DateTime?`, `unreadCount: int`)

O `ChatRoomModel.fromJson` populará esses campos quando disponíveis no response.

---

## 7. Arquivos a Criar

| Arquivo | Tipo |
|---------|------|
| `lib/features/chat/domain/entities/chat_room.dart` | Novo |
| `lib/features/chat/domain/entities/chat_message.dart` | Novo |
| `lib/features/chat/domain/repositories/chat_repository.dart` | Novo |
| `lib/features/chat/data/models/chat_room_model.dart` | Novo |
| `lib/features/chat/data/models/chat_message_model.dart` | Novo |
| `lib/features/chat/data/repositories/chat_repository_impl.dart` | Novo |
| `lib/features/chat/presentation/cubit/messages_cubit.dart` | Novo |
| `lib/features/chat/presentation/cubit/messages_state.dart` | Novo |
| `lib/features/chat/presentation/cubit/chat_cubit.dart` | Novo |
| `lib/features/chat/presentation/cubit/chat_state.dart` | Novo |

## 8. Arquivos a Modificar

| Arquivo | Mudança |
|---------|---------|
| `lib/features/trip/domain/repositories/trip_repository.dart` | + `getChatEligibleTrips` |
| `lib/features/trip/data/repositories/trip_repository_impl.dart` | + implementação |
| `lib/features/trip/presentation/widgets/trip_details_sheet.dart` | + botão "Abrir chat" |
| `lib/features/profile/presentation/pages/messages_page.dart` | Conectar à API |
| `lib/features/profile/presentation/pages/chat_page.dart` | Conectar à API |
| `lib/routes/app_router.dart` | Rota + BlocProviders inline |
| `lib/main.dart` | Expor `supabaseClient` ao router |

---

## 9. Pontos de Atenção

- **RLS `chat_rooms_insert`:** O cliente pode inserir apenas se for participante. Como o cliente está autenticado e é o `client_id`, a inserção será permitida.
- **RLS `chat_messages_insert`:** `sender_id = auth.uid()` — garantido porque o cubit usa o userId atual.
- **Realtime:** Cancelar `StreamSubscription` no `close()` do cubit para evitar memory leak.
- **Trip sem motorista:** `getOrCreateRoomForTrip` deve lançar exceção descritiva se `driver_profile_id` for null (não deve ocorrer para `scheduled`/`started`/`finished`, mas deve ser tratado).
- **Máximo 300 linhas por arquivo:** Se `chat_repository_impl.dart` ultrapassar, separar em datasource + repository.
