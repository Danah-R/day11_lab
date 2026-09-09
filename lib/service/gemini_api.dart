import 'dart:developer';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiApi {

  // history: chronological list of {"role": "user"|"model", "text": "..."}
  Future<String> SendRequest(List<Map<String, String>> history) async {

    String link = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent";
    var uri = Uri.parse(link);
    Map<String, String> headers = {
      "x-goog-api-key": dotenv.get("api-key"),
      };

    Map<String, dynamic> body = {
        "system_instruction": {
          "parts": [
            {
              "text": "You are a friendly recipe assistant. Your job is to help the user "
                  "decide what to cook. If they haven't told you yet, ask what meal "
                  "they're preparing (breakfast, lunch, dinner, or snack) and what "
                  "ingredients they have on hand. Once you know both, suggest one dish "
                  "that fits, then give a short, clear recipe for it (ingredients list "
                  "and numbered steps). Keep replies concise and use simple formatting."
            }
          ]
        },
        "contents": history
            .map((turn) => {
                  "role": turn["role"],
                  "parts": [
                    {"text": turn["text"]}
                  ]
                })
            .toList(),
        };



    try {
      var request = await http.post(uri, headers: headers, body: jsonEncode(body));

      var requestBody = request.body;

      var responseBody = jsonDecode(requestBody);

      log("${request.statusCode}");

      if (request.statusCode == 200) {
        return responseBody["candidates"][0]["content"]["parts"][0]["text"].toString();
      } else {
        log("API error ${request.statusCode}: $responseBody");
        return "there's something wrong";
      }
    } catch (e) {
      log("Request failed: $e");
      return "there's something wrong";
    }
  }
}