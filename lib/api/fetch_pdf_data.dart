import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scientry/analytics_service.dart';

Future fetchPDFData(String? pdfurl) async {
  if (pdfurl == null || pdfurl.isEmpty) {
    debugPrint("Log: fetchPDFData: PDF URL or DOI is null or empty.");
    return null;
  }
  const String apiUrl =
      'https://raannakasturi-scientrypdfdataapi.hf.space/gradio_api/call/getDOIData';

  debugPrint("Log: fetchPDFData: Initiating POST request to API.");
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'data': [pdfurl],
    }),
  );

  debugPrint(
      "Log: fetchPDFData: POST response status code: ${response.statusCode}");
  debugPrint("Log: fetchPDFData: POST response body: ${response.body}");

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    debugPrint("Log: fetchPDFData: Parsed JSON response: $jsonResponse");
    AnalyticsService().logAnalyticsEvent('pdf_data_fetched_from_api');
    final String? eventId = jsonResponse["event_id"];
    debugPrint("Log: fetchPDFData: Extracted event_id: $eventId");

    if (eventId != null) {
      final eventUrl = '$apiUrl/$eventId';
      debugPrint("Log: fetchPDFData: Constructed event URL: $eventUrl");

      while (true) {
        final statusResponse = await http.get(
          Uri.parse(eventUrl),
          headers: {'Content-Type': 'application/json'},
        );
        debugPrint(
            "Log: fetchPDFData: GET $eventUrl returned status ${statusResponse.statusCode}");
        debugPrint(
            "Log: fetchPDFData: GET response body: ${statusResponse.body}");

        if (statusResponse.statusCode == 200) {
          final lines = statusResponse.body.split('\n');
          String? eventType;
          String? dataLine;

          for (var line in lines) {
            debugPrint("Log: fetchPDFData: Processing line: $line");
            if (line.startsWith("event: ")) {
              eventType = line.substring("event: ".length).trim();
              debugPrint("Log: fetchPDFData: Found event type: $eventType");
            }
            if (line.startsWith("data: ")) {
              dataLine = line.substring("data: ".length).trim();
              debugPrint("Log: fetchPDFData: Found data line: $dataLine");
            }
          }

          if (eventType != null) {
            if (eventType == "complete") {
              debugPrint("Log: fetchPDFData: Received 'complete' event.");
              if (dataLine != null && dataLine != "null") {
                try {
                  final List<dynamic> dataList = jsonDecode(dataLine);
                  debugPrint("Log: fetchPDFData: Decoded data list: $dataList");
                  if (dataList.isNotEmpty) {
                    final apiResponse = jsonDecode(dataList[0]);
                    debugPrint(
                        "Log: fetchPDFData: Final API response: $apiResponse");
                    return apiResponse;
                  } else {
                    debugPrint("Log: fetchPDFData: Data list is empty.");
                  }
                } catch (e) {
                  debugPrint(
                      "Log: fetchPDFData: Error decoding JSON from dataLine: $e");
                }
              } else {
                debugPrint(
                    "Log: fetchPDFData: Received empty or null data line.");
              }
              break;
            } else if (eventType == "error") {
              debugPrint("Log: fetchPDFData: Received 'error' event.");
              break;
            } else if (eventType == "progress") {
              debugPrint("Log: fetchPDFData: Received 'progress' event.");
            } else {
              debugPrint("Log: fetchPDFData: Unknown event type: $eventType");
            }
          } else {
            debugPrint(
                "Log: fetchPDFData: No event type found in the response.");
          }
        } else {
          debugPrint(
              "Log: fetchPDFData: Error: HTTP ${statusResponse.statusCode}");
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    } else {
      debugPrint("Log: fetchPDFData: Event ID not found in JSON response.");
    }
  } else {
    debugPrint(
        "Log: fetchPDFData: Failed to make POST request. Status code: ${response.statusCode}");
  }
  return null;
}
