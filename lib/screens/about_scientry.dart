import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scientry/analytics_service.dart';

class AboutScientry extends StatefulWidget {
  const AboutScientry({super.key});

  @override
  State<AboutScientry> createState() => _AboutScientryState();
}

class _AboutScientryState extends State<AboutScientry> {
  String _appVersion = '';

  version() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var version = packageInfo.version;
    var buildNumber = packageInfo.buildNumber;
    String appVersion = 'v$version+$buildNumber';
    setState(() {
      _appVersion = appVersion;
    });
  }

  @override
  void initState() {
    super.initState();
    version();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    AnalyticsService().logAnalyticsEvent('aboutpage_visited');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('About Scientry'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 15,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                      'assets/brand/scientry_launcher_icon.png',
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Scientry',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Science Simplifed,\nKnowledge Amplified',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Table(
                  columnWidths: {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(0.15),
                    2: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      children: [
                        Text(
                          'Developed by',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ':',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        InkWell(
                          child: Text(
                            'Binary Biology',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          onTap: () {
                            EasyLauncher.url(
                              url: "https://binarybiology.top",
                              mode: Mode.externalApp,
                            );
                          },
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          'Developer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ':',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        InkWell(
                          child: Text(
                            'Nayan (Raanna) Kasturi',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          onTap: () {
                            EasyLauncher.url(
                              url: "https://nayankasturi.eu.org",
                              mode: Mode.externalApp,
                            );
                          },
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          'Version',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ':',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          _appVersion,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          'Website',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ':',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        InkWell(
                          child: Text(
                            'scientry.binarybiology.top',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          onTap: () {
                            EasyLauncher.url(
                              url: "https://scientry.binarybiology.top",
                              mode: Mode.externalApp,
                            );
                          },
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          'License',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ':',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        InkWell(
                          child: Text(
                            'BSD 4-Clause',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          onTap: () {
                            EasyLauncher.url(
                              url:
                                  "https://raw.githubusercontent.com/RaannaKasturi/scientry_app/refs/heads/master/LICENSE",
                              mode: Mode.inAppBrowser,
                            );
                          },
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          'Repository',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ':',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        InkWell(
                          child: Text(
                            'RaannaKasturi/scientry_app',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          onTap: () {
                            EasyLauncher.url(
                              url:
                                  "https://github.com/RaannaKasturi/scientry_app",
                              mode: Mode.inAppBrowser,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  "Made with ❤️ in 🇮🇳\n© ${now.year == 2025 ? 2025 : '2025 - ${now.year}'} Nayan Kasturi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              Divider(
                thickness: 2,
                indent: 25,
                endIndent: 25,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("""
BSD 4-Clause License
              
Copyright (c) 2025, Nayan Kasturi All rights reserved.
              
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software must display the following acknowledgement: This product includes software developed by scientry_app.
4. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDER "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
              """),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
