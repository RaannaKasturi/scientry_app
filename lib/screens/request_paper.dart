import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:scientry/adverts/interstitial_ad.dart';
import 'package:scientry/analytics_service.dart';
import 'package:scientry/api/fetch_pdf_data.dart';
import 'package:scientry/info_pages/no_internet.dart';
import 'dart:convert';
import 'package:scientry/screens/requested_paper.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

class RequestPaper extends StatefulWidget {
  const RequestPaper({super.key});

  @override
  RequestPaperState createState() => RequestPaperState();
}

class RequestPaperState extends State<RequestPaper> {
  final GlobalKey<FormBuilderState> _doiFormKey = GlobalKey<FormBuilderState>();
  bool _isUploading = false;
  bool _doiDataFetched = false;

  Future<void> _handleFileUpload(BuildContext context) async {
    AnalyticsService().logAnalyticsEvent('user_uploaded_file');
    _doiFormKey.currentState?.fields['doi']?.didChange("");
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
        try {
          var pdfData = await fetchPDFData(fileURL);
          var pdfDatas = await jsonDecode(jsonEncode(pdfData));
          String doi = pdfDatas['doi'].toString();
          debugPrint("Log: RPPDFData: DOI: $doi");
          if (doi.isNotEmpty && doi != "null") {
            if (doi.contains(".org/")) {
              _doiFormKey.currentState?.fields['doi']
                  ?.didChange(doi.split(".org/")[1]);
            } else {
              _doiFormKey.currentState?.fields['doi']?.didChange(doi);
            }
            setState(() {
              _doiDataFetched = true;
            });
          } else {
            setState(() {
              _doiFormKey.currentState?.fields['doi']?.didChange("");
              _doiDataFetched = false;
            });
          }
        } catch (error) {
          setState(() {
            _doiDataFetched = false;
          });
          debugPrint("Log: RPPDFData: Error: $error");
        }
        if (response.statusCode == 200) {
          _doiFormKey.currentState?.fields['pdfurl']?.didChange(fileURL);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("File uploaded successfully")),
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

  Future<bool> checkInternet() async {
    return await SimpleConnectionChecker.isConnectedToInternet();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkInternet(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return const NoInternet();
        }
        if (snapshot.hasError) {
          return NoInternet();
        }
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
                          enableSuggestions: true,
                          enabled: !_doiDataFetched,
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
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
                                setState(() {
                                  _doiDataFetched = false;
                                });
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
                            if (FirebaseAuth.instance.currentUser == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Please Login in to upload a file"),
                                ),
                              );
                            } else {
                              _handleFileUpload(context);
                            }
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withAlpha((0.25 * 255).toInt()),
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
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
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
                        final doi =
                            _doiFormKey.currentState?.fields['doi']?.value;
                        final pdfURL =
                            _doiFormKey.currentState?.fields['pdfurl']?.value;
                        debugPrint("RequestedLog: DOI: $doi, PDF URL: $pdfURL");
                        debugPrint(
                            "RequestedLog: Initiating POST request to API.");
                        context.pushTransition(
                          curve: Curves.easeInOut,
                          type: PageTransitionType.rightToLeft,
                          child: RequestedPaper(
                            inputDOI: doi,
                            inputpdfURL: pdfURL,
                          ),
                        );
                        ScientryInterstitialAd.showAd(context: context);
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Error"),
                            content: const Text(
                                "Please enter a valid DOI ID or URL"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
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
      },
    );
  }
}
