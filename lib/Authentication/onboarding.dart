import 'package:taskmaster/constants/onBoardImages.dart';
import 'package:taskmaster/widgets/onboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardScreen extends StatelessWidget {
  const OnboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: Stack(
        children: [
          /// Horizontal Scrollable Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              new_onboardingPage(
                image: CCimage.onBoardingimage1,
                title: CCtext.onBoardingtext1,
                subtitle: CCsubtext.onBoardingsubtext1,
              ),
              new_onboardingPage(
                image: CCimage.onBoardingimage2,
                title: CCtext.onBoardingtext2,
                subtitle: CCsubtext.onBoardingsubtext2,
              ),
              new_onboardingPage(
                image: CCimage.onBoardingimage3,
                title: CCtext.onBoardingtext3,
                subtitle: CCsubtext.onBoardingsubtext3,
              ),
            ],
          ),
          //skip button
          const onboardSkip(),
          // dot navigator
          const onboardNavi(),
          // next circle button
          onboardNext()
        ],
      ),
    );
  }
}

class onboardNext extends StatelessWidget {
  const onboardNext({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 35,
      right: 30,
      child: ElevatedButton(
          onPressed: () => OnBoardingController.instance.nextPage(),
          style:
              ElevatedButton.styleFrom(shape: CircleBorder(), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          child: const Icon(Iconsax.arrow_right_3)),
    );
  }
}

class onboardNavi extends StatelessWidget {
  const onboardNavi({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    return Positioned(
      bottom: 50,
      right: 162,
      child: SmoothPageIndicator(
        controller: controller.pageController,
        onDotClicked: controller.dotNavigationClick,
        count: 3,
        effect: ExpandingDotsEffect(activeDotColor: Colors.blueAccent, dotHeight: 5),
      ),
    );
  }
}

class onboardSkip extends StatelessWidget {
  const onboardSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 10,
      child: TextButton(
        onPressed: () => OnBoardingController.instance.skipPage(),
        child: const Text('Skip'),
        style: TextButton.styleFrom(foregroundColor: Colors.black, textStyle: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

class new_onboardingPage extends StatelessWidget {
  const new_onboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image, title, subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image(
          width: 450,
          height: 600,
          image: AssetImage(image),
        ),
        // Image

        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ), // Text
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
