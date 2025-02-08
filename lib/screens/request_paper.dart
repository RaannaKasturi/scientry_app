import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RequestPaper extends StatelessWidget {
  RequestPaper({super.key});

  final GlobalKey<FormBuilderState> _doiFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: (() {
            Navigator.pop(context);
          }),
          icon: Icon(
            Icons.arrow_back,
          ),
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
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                      decoration: InputDecoration(
                        labelText: "Enter DOI ID or URL *",
                        helper: Text(
                            "https://doi.org/10.1145/2470654.2470728 or\n10.1145/2470654.2470728"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          onPressed: (() {
                            _doiFormKey.currentState?.fields['doi']
                                ?.didChange("");
                          }),
                          icon: Icon(Icons.close),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    FormBuilderTextField(
                      name: 'pdfurl',
                      autofocus: true,
                      enableSuggestions: true,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "Uploaded PDF's temporary URL",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
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
                        ),
                      ),
                      Text(
                        "Upload Research Paper PDF",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
