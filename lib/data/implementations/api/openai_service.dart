import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  Future<String> getBudgetAdvice({
    required int totalBudget,
    required int totalEstimated,
    required int totalSpent,
    required int remaining,
    required List<Map<String, dynamic>> categories,
  }) async {
    final categoryLines = categories.isEmpty
        ? 'Chua co du lieu danh muc.'
        : categories
            .map((c) =>
                '- ${c['label']}: du tinh ${_fmt(c['estimated'] as int)} d, da chi ${_fmt(c['spent'] as int)} d')
            .join('\n');

    final remainingText =
        remaining >= 0 ? '${_fmt(remaining)} d' : '-${_fmt(remaining.abs())} d (vuot ngan sach)';

    final prompt = 'Toi dang quan ly ngan sach mua sam Tet:\n'
        '- Tong ngan sach: ${_fmt(totalBudget)} d\n'
        '- Tong du tinh: ${_fmt(totalEstimated)} d\n'
        '- Da chi: ${_fmt(totalSpent)} d\n'
        '- Con lai: $remainingText\n\n'
        'Theo danh muc:\n$categoryLines\n\n'
        'Hay phan tich ngan gon tinh hinh ngan sach va dua ra 2-3 goi y cu the de toi uu chi tieu. '
        'Tra loi bang tieng Viet, toi da 120 tu.';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 350,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Khong the ket noi AI. Vui long thu lai.');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return data['choices'][0]['message']['content'] as String;
  }

  String _fmt(int v) => v.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}
