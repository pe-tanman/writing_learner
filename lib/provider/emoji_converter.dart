import 'package:flutter/material.dart';
import 'package:writing_learner/themes/app_color.dart';
class EmojiConverter {
  // Method to convert accuracy rate to face emoji
  static String convertAccuracyToEmoji(int accuracy) {
    if (accuracy >= 90) {
      return '😍'; // Happy face for high accuracy
    } else if (accuracy >= 70) {
      return '😄'; // Slightly smiling face for moderate accuracy
    } else if (accuracy >= 50) {
      return '🙂'; // Neutral face for average accuracy
    } else if (accuracy >= 30) {
      return '😟'; // Worried face for low accuracy
    } else {
      return '😢'; // Crying face for very low accuracy
    }
  }
  static Widget convertAccuracyToImage(int accuracy) {
    if (accuracy >= 90) {
      return Container(
                  height: 200,
                  width: 400,
                  decoration: BoxDecoration(
                    color: AppColors.themeColor,
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(image:  AssetImage('lib/assets/blue_wide.png'), fit: BoxFit.fill),
                  ),
                  child: const Center(
                    child: Text(
                      'Awesome! 😍',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )); // Happy face for high accuracy
    } else if (accuracy >= 70) {
      return Container(
          height: 200,
          width: 400,
          decoration: BoxDecoration(
            color: AppColors.themeColor,
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
                image: AssetImage('lib/assets/blue_wide.png'),
                fit: BoxFit.fill),
          ),
          child: const Center(
            child: Text(
              'Nicely Done! 😄',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ));  // Slightly smiling face for moderate accuracy
    } else if (accuracy >= 50) {
     return Container(
          height: 200,
          width: 400,
          decoration: BoxDecoration(
            color: AppColors.themeColor,
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
                image: AssetImage('lib/assets/blue_wide.png'),
                fit: BoxFit.fill),
          ),
          child: const Center(
            child: Text(
              'Keep it up! 🙂',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ));  // Neutral face for average accuracy
    } else if (accuracy >= 30) {
       return Container(
                  height: 200,
                  width: 400,
                  decoration: BoxDecoration(
                    color: AppColors.themeColor,
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(image:  AssetImage('lib/assets/blue_wide.png'), fit: BoxFit.fill),
                  ),
                  child: const Center(
                    child: Text(
                      'Stepping Up! 😟',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )); ; // Worried face for low accuracy
    } else {
      return Container(
          height: 200,
          width: 400,
          decoration: BoxDecoration(
            color: AppColors.themeColor,
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
                image: AssetImage('lib/assets/blue_wide.png'),
                fit: BoxFit.fill),
          ),
          child: const Center(
            child: Text(
              'You do more, you learn more! 😢',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ));
      ; // Crying face for very low accuracy
    }
  }
  static Widget convertAccuracyToPassFail(int accuracy) {
    if (accuracy >= 90) {
      return Container(
          height: 200,
          width: 400,
          color: AppColors.accentColor,
          child: const Center(
            child: Text(
              'Passed! 😍',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          )); // Happy face for high accuracy
    } else if (accuracy >= 70) {
      return Container(
          height: 200,
          width: 400,
          color: AppColors.accentColor,
          child: const Center(
            child: Text(
              'Passed! 😄',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          )); // Slightly smiling face for moderate accuracy
    } else if (accuracy >= 50) {
      return Container(
          height: 200,
          width: 400,
         color: AppColors.themeColor,
          child: const Center(
            child: Text(
              'Failed.. 🙂',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          )); // Neutral face for average accuracy
    } else if (accuracy >= 30) {
      return Container(
          height: 200,
          width: 400,
          color: AppColors.themeColor,
          child: const Center(
            child: Text(
              'Failed.. 😟',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ));
      ; // Worried face for low accuracy
    } else {
      return Container(
          height: 200,
          width: 400,
          color: AppColors.themeColor,
          child: const Center(
            child: Text(
              'Failed 😢',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ));
    // Crying face for very low accuracy
    }
  }
}