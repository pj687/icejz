import 'package:dio/dio.dart';
import 'package:icejz_app/data/api_client.dart';
import 'package:icejz_app/data/models.dart';

class AiRepository {
  Dio get _dio => ApiClient.instance.dio;

  Future<AiRobot?> robot() async {
    try {
      return await apiCallNullable(
        () => _dio.get('/sys/ai/robot/info'),
        (raw) => AiRobot.fromJson(asJsonMap(raw)),
      );
    } catch (_) {
      return null;
    }
  }

  Future<AiChatReply> chat(String content, {int? sessionId}) {
    return apiCall(
      () => _dio.post(
        '/sys/ai/chat',
        data: AiChatRequest(content: content, sessionId: sessionId).toJson(),
      ),
      (raw) => AiChatReply.fromJson(asJsonMap(raw)),
    );
  }

  Future<List<AiSession>> sessions() async {
    return await apiCallNullable(
          () => _dio.get('/sys/ai/chat/session/list'),
          (raw) => asJsonList(raw).map(AiSession.fromJson).toList(),
        ) ??
        const [];
  }

  Future<List<AiMessage>> messages(int sessionId) async {
    return await apiCallNullable(
          () => _dio.get('/sys/ai/chat/session/$sessionId/messages'),
          (raw) => asJsonList(raw).map(AiMessage.fromJson).toList(),
        ) ??
        const [];
  }

  Future<AiSession?> createSession({String? title}) async {
    return apiCallNullable(
      () => _dio.post(
        '/sys/ai/chat/session',
        data: (title == null || title.isEmpty) ? <String, String>{} : {'title': title},
      ),
      (raw) => AiSession.fromJson(asJsonMap(raw) ?? {}),
    );
  }
}
