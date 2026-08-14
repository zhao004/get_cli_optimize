import '../../interface/sample_interface.dart';

class LangChainAgentSample extends Sample {
  LangChainAgentSample({String path = 'lib/app/ai/app_ai_agent.dart'})
      : super(path, overwrite: true);

  @override
  String get content => '''import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

class AppAiAgent {
  AppAiAgent({
    required String apiKey,
    this.model = 'gpt-4o-mini',
    this.systemPrompt = 'You are a helpful AI agent for this GetX project.',
  }) : _chatModel = ChatOpenAI(
          apiKey: apiKey,
          defaultOptions: ChatOpenAIOptions(model: model),
        );

  final String model;
  final String systemPrompt;
  final ChatOpenAI _chatModel;

  Future<String> run(String input) async {
    final prompt = ChatPromptTemplate.fromTemplates([
      (ChatMessageType.system, systemPrompt),
      (ChatMessageType.human, '{input}'),
    ]);

    final chain = prompt | _chatModel | const StringOutputParser();
    return (await chain.invoke({'input': input})) as String;
  }
}
''';
}
