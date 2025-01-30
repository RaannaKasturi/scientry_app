import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselPost {
  final int id;
  final String title;
  final String image;
  final String category;
  final String link;

  CarouselPost(
      {required this.id,
      required this.title,
      required this.image,
      required this.category,
      required this.link});

  factory CarouselPost.fromJson(Map<String, dynamic> json) {
    return CarouselPost(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      category: json['category'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'category': category,
        'link': link,
      };
}

class Carousel extends StatefulWidget {
  final List<CarouselPost> carouselPosts;
  const Carousel({super.key, required this.carouselPosts});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late List<CarouselPost> diaplayCarouselPosts;
  final CarouselSliderController carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    diaplayCarouselPosts = widget.carouselPosts.take(7).toList();
  }

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
                    items: diaplayCarouselPosts
                        .map(
                          (item) => item.image.startsWith("https")
                              ? Stack(
                                  children: [
                                    Image.network(
                                      item.image,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Text(
                                            "Error loading image");
                                      },
                                    ),
                                  ],
                                )
                              : Stack(
                                  children: [
                                    Image.memory(
                                      base64Decode(item.image.split(",")[1]),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Text(
                                            "Error loading image: $error :: $stackTrace");
                                      },
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        bottom: 25,
                                        top: 20,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              item.category,
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Text(item.title),
                                        ],
                                      ),
                                    ),
                                  ],
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
                  children: diaplayCarouselPosts.asMap().entries.map((entry) {
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
