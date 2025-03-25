import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future fetchData(String? pdfurl, String? doi) async {
  if (pdfurl == null || doi == null || pdfurl.isEmpty || doi.isEmpty) {
    debugPrint("Log: PDF URL or DOI is null or empty.");
    return null;
  }

  const String apiUrl =
      'https://raannakasturi-scientryapi.hf.space/gradio_api/call/rexplore_summarizer';

  debugPrint("Log: Initiating POST request to API.");
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'data': [pdfurl, doi, 'scientrypass'],
    }),
  );

  debugPrint("Log: POST response status code: ${response.statusCode}");
  debugPrint("Log: POST response body: ${response.body}");

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    debugPrint("Log: Parsed JSON response: $jsonResponse");

    final String? eventId = jsonResponse["event_id"];
    debugPrint("Log: Extracted event_id: $eventId");

    if (eventId != null) {
      final eventUrl = '$apiUrl/$eventId';
      debugPrint("Log: Constructed event URL: $eventUrl");

      while (true) {
        final statusResponse = await http.get(
          Uri.parse(eventUrl),
          headers: {'Content-Type': 'application/json'},
        );
        debugPrint(
            "Log: GET $eventUrl returned status ${statusResponse.statusCode}");
        debugPrint("Log: GET response body: ${statusResponse.body}");

        if (statusResponse.statusCode == 200) {
          final lines = statusResponse.body.split('\n');
          String? eventType;
          String? dataLine;
          for (var line in lines) {
            debugPrint("Log: Processing line: $line");
            if (line.startsWith("event: ")) {
              eventType = line.substring("event: ".length).trim();
              debugPrint("Log: Found event type: $eventType");
            }
            if (line.startsWith("data: ")) {
              dataLine = line.substring("data: ".length).trim();
              debugPrint("Log: Found data line: $dataLine");
            }
          }

          if (eventType != null) {
            if (eventType == "complete") {
              debugPrint("Log: Received 'complete' event.");
              if (dataLine != null && dataLine != "null") {
                try {
                  final List<dynamic> dataList = jsonDecode(dataLine);
                  debugPrint("Log: Decoded data list: $dataList");
                  if (dataList.isNotEmpty) {
                    final apiResponse = jsonDecode(dataList[0]);
                    debugPrint("Log: Final API response: $apiResponse");
                    return apiResponse;
                  } else {
                    debugPrint("Log: Data list is empty.");
                  }
                } catch (e) {
                  debugPrint("Log: Error decoding JSON from dataLine: $e");
                }
              } else {
                debugPrint("Log: Received empty or null data line.");
              }
              break;
            } else if (eventType == "error") {
              debugPrint("Log: Received 'error' event.");
              break;
            } else if (eventType == "progress") {
              debugPrint("Log: Received 'progress' event.");
            } else {
              debugPrint("Log: Unknown event type: $eventType");
            }
          } else {
            debugPrint("Log: No event type found in the response.");
          }
        } else {
          debugPrint("Log: Error: HTTP ${statusResponse.statusCode}");
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    } else {
      debugPrint("Log: Event ID not found in JSON response.");
    }
  } else {
    debugPrint(
        "Log: Failed to make POST request. Status code: ${response.statusCode}");
  }
  return null;
}
