import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../closet/presentation/providers/closet_provider.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../providers/stylist_repository_provider.dart';

final chatSessionsProvider = FutureProvider<List<ChatSessionEntity>>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return [];
  final repo = ref.watch(stylistRepositoryProvider);
  return repo.getUserSessions(user.uid);
});

class StylistNotifier extends Notifier<ChatSessionEntity?> {
  bool _isLoading = false;

  @override
  ChatSessionEntity? build() {
    return null;
  }

  bool get isLoading => _isLoading;

  void loadSession(ChatSessionEntity session) {
    state = session;
  }
  
  void newSession() {
    state = null;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final repo = ref.read(stylistRepositoryProvider);
    final uuid = const Uuid();
    
    // Create or update session
    ChatSessionEntity currentSession = state ?? ChatSessionEntity(
      id: uuid.v4(),
      userId: user.uid,
      title: text.length > 20 ? '${text.substring(0, 20)}...' : text,
      updatedAt: DateTime.now(),
      messages: [
        ChatMessageEntity(
          id: uuid.v4(),
          text: 'Hello! I am your personal FitLens AI Stylist. How can I elevate your wardrobe today?',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(seconds: 1)),
        )
      ],
    );

    // Add user message
    final userMessage = ChatMessageEntity(
      id: uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    currentSession = ChatSessionEntity(
      id: currentSession.id,
      userId: currentSession.userId,
      title: currentSession.title,
      updatedAt: DateTime.now(),
      messages: [...currentSession.messages, userMessage],
    );

    state = currentSession;
    _isLoading = true;
    
    // Trigger UI rebuild
    ref.notifyListeners();

    try {
      final geminiService = GeminiService();
      
      // Contexts
      String closetContext = "The user currently has NO items in their digital closet.";
      final closetState = ref.read(closetProvider);
      if (closetState.hasValue && closetState.value != null && closetState.value!.isNotEmpty) {
        final items = closetState.value!;
        final inventoryList = items.map((i) => "- ${i.color} ${i.category} (${i.season})").join("\n");
        closetContext = "The user currently owns the following clothing items in their digital closet:\n$inventoryList\n\nWhen recommending outfits, prioritize using these items.";
      }
      
      String weatherContext = "Unknown weather conditions.";
      final weatherState = ref.read(weatherProvider);
      if (weatherState.hasValue && weatherState.value != null) {
        final w = weatherState.value!;
        weatherContext = "The user is currently in ${w.city}. The weather is ${w.temperature}°C with ${w.condition}. Suggest outfits appropriate for this weather.";
      }

      final systemInstruction = "System Instruction: You are a high-end, expert fashion stylist for a premium app called FitLens. Keep your responses concise, stylish, and highly helpful. Use fashion terminology where appropriate, but remain accessible. Provide concrete outfit suggestions.\n\nCRITICAL INSTRUCTION: If the user explicitly asks you to generate, draw, or show an image or picture of an outfit, output your conversational text, and then add EXACTLY this at the very end: [GENERATE_IMAGE: <highly detailed text prompt describing the image>]. Do NOT use the word 'prompt' inside the brackets, just put the actual description.\n\n$closetContext\n\n$weatherContext\n\nUser query: ";

      String payloadText = text;
      if (currentSession.messages.length <= 2) {
        payloadText = "$systemInstruction$text";
      }

      List<Map<String, String>> history = [];
      for (int i = 1; i < currentSession.messages.length - 1; i++) {
         final msg = currentSession.messages[i];
         String msgText = msg.text;
         if (i == 1 && msg.isUser) {
             msgText = "$systemInstruction${msg.text}";
         }
         history.add({
           "role": msg.isUser ? "user" : "model",
           "text": msgText
         });
      }

      String? replyText = await geminiService.generateChatContent(
        history: history,
        message: payloadText,
      );

      if (replyText == null || replyText.trim().isEmpty) {
        throw Exception("Empty response from AI.");
      }

      ChatMessageEntity responseMessage;
      String? imageUrl;

      // Parse for image generation
      final regExp = RegExp(r'\[GENERATE_IMAGE:(.*?)\]');
      final match = regExp.firstMatch(replyText);
      if (match != null) {
        final prompt = match.group(1)?.trim() ?? "";
        replyText = replyText.replaceAll(regExp, "").trim();
        imageUrl = "https://image.pollinations.ai/prompt/${Uri.encodeComponent(prompt)}";
      }

      responseMessage = ChatMessageEntity(
        id: uuid.v4(),
        text: replyText,
        isUser: false,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
      );

      currentSession = ChatSessionEntity(
        id: currentSession.id,
        userId: currentSession.userId,
        title: currentSession.title,
        updatedAt: DateTime.now(),
        messages: [...currentSession.messages, responseMessage],
      );

      state = currentSession;
      
      // Save session to Firestore
      await repo.saveSession(currentSession);
      ref.invalidate(chatSessionsProvider); // refresh sidebar

    } catch (e) {
      currentSession = ChatSessionEntity(
        id: currentSession.id,
        userId: currentSession.userId,
        title: currentSession.title,
        updatedAt: DateTime.now(),
        messages: [
          ...currentSession.messages,
          ChatMessageEntity(
            id: uuid.v4(),
            text: ErrorHandler.getMessage(
              e,
              'I am having trouble connecting right now. Please try asking again in a moment.',
            ),
            isUser: false,
            timestamp: DateTime.now(),
          )
        ],
      );
      state = currentSession;
    } finally {
      _isLoading = false;
      ref.notifyListeners();
    }
  }
}

final stylistProvider = NotifierProvider<StylistNotifier, ChatSessionEntity?>(() {
  return StylistNotifier();
});
