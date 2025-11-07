import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/course_screens/widgets/course/course_card_widget.dart';

class CourseSliderWidget extends StatefulWidget {
  final List<Course> courses;
  final Function(Course) onCourseSelected;

  const CourseSliderWidget({
    super.key,
    required this.courses,
    required this.onCourseSelected,
  });

  @override
  State<CourseSliderWidget> createState() => CourseSliderWidgetState();
}

class CourseSliderWidgetState extends State<CourseSliderWidget> {
  late PageController pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      viewportFraction: 0.85,
      initialPage: currentIndex,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (pageIndex) {
              setState(() {
                currentIndex = pageIndex;
              });
            },
            itemCount: widget.courses.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, courseIndex) {
              final Course course = widget.courses[courseIndex];
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: CourseCardWidget(
                  course: course,
                  onTap: () => widget.onCourseSelected(course),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.courses.length; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == currentIndex ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == currentIndex ? Colors.blue : Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ],
    );
  }

}
