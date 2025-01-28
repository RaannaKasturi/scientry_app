import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Carousel extends StatefulWidget {
  const Carousel({super.key});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  List imageList = [
    {"id": 1, "image_path": 'https://i.ibb.co/84pRh5y/529a0b20ffad.jpg'},
    {"id": 2, "image_path": 'https://i.ibb.co/84pRh5y/529a0b20ffad.jpg'},
    {"id": 3, "image_path": 'https://i.ibb.co/84pRh5y/529a0b20ffad.jpg'},
    {"id": 4, "image_path": 'https://i.ibb.co/84pRh5y/529a0b20ffad.jpg'},
  ];
  final CarouselSliderController carouselController =
      CarouselSliderController();
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
                    debugPrint("Post is $currentIndex");
                  },
                  child: CarouselSlider(
                    items: imageList
                        .map(
                          (item) => item['image_path'].startsWith("https")
                              ? Image.network(
                                  item['image_path'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text("Error loading image");
                                  },
                                )
                              : Image.memory(
                                  base64Decode(item['image_path']),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                        "Error loading image: $error :: $stackTrace");
                                  },
                                ),
                        )
                        .toList(),
                    carouselController: carouselController,
                    options: CarouselOptions(
                      scrollPhysics: const BouncingScrollPhysics(),
                      autoPlay: true,
                      aspectRatio: 3 / 2,
                      viewportFraction: 1,
                      pauseAutoPlayOnManualNavigate: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imageList.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => carouselController.animateToPage(
                        entry.key,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: Container(
                        width: currentIndex == entry.key ? 17 : 7,
                        height: 7.0,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 3.0,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: currentIndex == entry.key
                                ? Colors.red
                                : Colors.teal),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
