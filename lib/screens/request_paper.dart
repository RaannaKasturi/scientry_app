import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestPaper extends StatefulWidget {
  const RequestPaper({super.key});

  @override
  RequestPaperState createState() => RequestPaperState();
}

class RequestPaperState extends State<RequestPaper> {
  final GlobalKey<FormBuilderState> _doiFormKey = GlobalKey<FormBuilderState>();
  bool _isUploading = false;

  Future<void> _handleFileUpload(BuildContext context) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ['pdf'],
        type: FileType.custom,
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;
        if (file.path == null) {
          throw Exception("File path is null");
        }
        setState(() {
          _isUploading = true;
        });
        final request = http.MultipartRequest(
            'POST', Uri.parse('https://tmpfiles.org/api/v1/upload'));
        request.files
            .add(await http.MultipartFile.fromPath('file', file.path!));
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        debugPrint("Log: File upload response: $responseBody");
        final fileData = jsonDecode(responseBody);
        final fileURL = fileData['data']['url']
            .toString()
            .replaceAll("tmpfiles.org/", "tmpfiles.org/dl/");
        if (response.statusCode == 200) {
          _doiFormKey.currentState?.fields['pdfurl']?.didChange(fileURL);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("File uploaded successfully")),
          );
        } else {
          _doiFormKey.currentState?.fields['pdfurl']?.didChange("");
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Error"),
              content: const Text("Failed to upload file"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Error"),
            content: const Text("No file selected"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      debugPrint("File upload error: $error");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("An unexpected error occurred: $error"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  bool _validateForm() {
    return _doiFormKey.currentState?.saveAndValidate() ?? false;
  }

  generateSummaryMindmap() async {
    // Save form values.
    _doiFormKey.currentState?.save();

    // Process DOI (removing unwanted characters) and retrieve the PDF URL.
    final doi = _doiFormKey.currentState?.fields['doi']?.value
        .toString()
        .replaceAll(r'/', '')
        .replaceAll(':', '')
        .replaceAll('.', '');
    final pdfURL = _doiFormKey.currentState?.fields['pdfurl']?.value.toString();
    debugPrint("Log: Processing DOI: $doi and PDF URL: $pdfURL");

    // Send the POST request.
    final postResponse = await http.post(
      Uri.parse(
          'https://raannakasturi-scientryapi.hf.space/gradio_api/call/rexplore_summarizer'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, List<dynamic>>{
        'data': [pdfURL, doi, 'scientry']
      }),
    );

    if (postResponse.statusCode == 200) {
      final postData = jsonDecode(postResponse.body);
      final eventId = postData['event_id'];
      final url =
          'https://raannakasturi-scientryapi.hf.space/gradio_api/call/rexplore_summarizer/$eventId';
      debugPrint('Log: $url');

      // Poll the GET endpoint until the response contains "event: complete".
      http.Response getResponse;
      do {
        await Future.delayed(const Duration(seconds: 2));
        getResponse = await http.get(Uri.parse(url));
        debugPrint("Log: Polling, response: ${getResponse.body}");
      } while (!getResponse.body.contains("event: complete"));

      debugPrint("Log: Event completed.");

      // Sometimes the final response that triggers "complete" may not have the "data:" line
      // immediately. Retry a few times if necessary.
      int retryCount = 0;
      while (!getResponse.body.contains("data:") && retryCount < 5) {
        debugPrint("Log: 'data:' not found; retrying (${retryCount + 1})...");
        await Future.delayed(const Duration(seconds: 2));
        getResponse = await http.get(Uri.parse(url));
        retryCount++;
      }

      // Extract the "data:" line.
      final lines = getResponse.body.split('\n');
      String dataLine = "";
      for (var line in lines) {
        if (line.startsWith("data:")) {
          dataLine = line.substring(5).trim();
          break;
        }
      }

      if (dataLine.isNotEmpty) {
        try {
          // Decode the data. It might be "null" or not a list.
          final dynamic decodedData = jsonDecode(dataLine);
          debugPrint("Log: Decoded data: ${decodedData.toString()}");
          if (decodedData == null || decodedData is! List) {
            debugPrint("Log: Decoded data is null or not a list: $decodedData");
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Error"),
                content: const Text(
                    "No valid data found in response. Please try again later."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
            return;
          }
          final List<dynamic> dataList = decodedData;
          if (dataList.isNotEmpty) {
            final extractedJsonString = dataList[0] as String;
            final extractedJson =
                jsonDecode(extractedJsonString) as Map<String, dynamic>;
            debugPrint(
                "Log: Extracted JSON data: ${jsonEncode(extractedJson)}");
            debugPrint("Log: Summary: ${extractedJson['summary'].toString()}");
            debugPrint("Log: Mindmap: ${extractedJson['mindmap'].toString()}");
          } else {
            debugPrint("Log: Data list is empty.");
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Error"),
                content: const Text(
                    "No data found in response. Please try again later."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
        } catch (e) {
          debugPrint("Log: Error parsing JSON: $e");
        }
      } else {
        debugPrint("Log: No data line found in response.");
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Error"),
            content: const Text(
                "No data found in response. Please try again later."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } else {
      debugPrint(
          "Log: POST request failed with status: ${postResponse.statusCode}");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: const Text(
              "Failed to generate summary and mindmap. Please try again later."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FormBuilder(
                key: _doiFormKey,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'doi',
                      autofocus: true,
                      enableSuggestions: true,
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        labelText: "Enter DOI ID or URL *",
                        helperText:
                            "https://doi.org/10.1145/2470654.2470728 or\n10.1145/2470654.2470728",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _doiFormKey.currentState?.fields['doi']
                                ?.didChange("");
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    const SizedBox(height: 15),
                    FormBuilderTextField(
                      name: 'pdfurl',
                      enableSuggestions: true,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "Uploaded PDF's temporary URL",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.url(),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              InkWell(
                onTap: _isUploading
                    ? null
                    : () {
                        _handleFileUpload(context);
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withAlpha((0.5 * 255).toInt()),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  width: 0.8 * MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            LucideIcons.file,
                            size: 30,
                            color: _isUploading
                                ? Colors.grey
                                : Theme.of(context).iconTheme.color,
                          ),
                        ),
                        Text(
                          _isUploading
                              ? "Uploading..."
                              : "Upload Research Paper PDF",
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  iconColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  if (_validateForm()) {
                    debugPrint("Log: Form is valid");
                    generateSummaryMindmap();
                  } else {
                    debugPrint("Log: Form is invalid");
                  }
                },
                label: const Text("Generate Summary & Mindmap"),
                icon: const Icon(LucideIcons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
