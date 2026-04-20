// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CourseModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Accelerator _$AcceleratorFromJson(Map<String, dynamic> json) => Accelerator(
  courseId: json['course-id'] as String,
  title: json['title'] as String,
  author: json['author'] as String,
  description: json['description'] as String,
  coverImagePath: json['cover-image-path'] as String,
  color: json['color'] as String,
  relevantFor: (json['relevant-for'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  genres: (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
  preloadedAssets:
      (json['preloaded-assets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  segments: (json['segments'] as List<dynamic>)
      .map((e) => Segment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AcceleratorToJson(Accelerator instance) =>
    <String, dynamic>{
      'course-id': instance.courseId,
      'title': instance.title,
      'author': instance.author,
      'description': instance.description,
      'cover-image-path': instance.coverImagePath,
      'color': instance.color,
      'relevant-for': instance.relevantFor,
      'genres': instance.genres,
      'preloaded-assets': instance.preloadedAssets,
      'segments': instance.segments.map((e) => e.toJson()).toList(),
    };

Segment _$SegmentFromJson(Map<String, dynamic> json) => Segment(
  segmentId: json['segment-id'] as String,
  segmentTitle: json['segment-title'] as String,
  segmentSymbol: json['segment-symbol'] as String? ?? '',
  lessons: (json['lessons'] as List<dynamic>)
      .map((e) => Package.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SegmentToJson(Segment instance) => <String, dynamic>{
  'segment-id': instance.segmentId,
  'segment-title': instance.segmentTitle,
  'segment-symbol': instance.segmentSymbol,
  'lessons': instance.lessons.map((e) => e.toJson()).toList(),
};

Package _$PackageFromJson(Map<String, dynamic> json) => Package(
  lessonId: json['lesson-id'] as String,
  title: json['title'] as String,
  lessonVersion: json['lesson-version'] as String? ?? '1.0',
  isFree: json['isFree'] as bool,
  content: Package._contentFromJson(json['content']),
);

Map<String, dynamic> _$PackageToJson(Package instance) => <String, dynamic>{
  'lesson-id': instance.lessonId,
  'title': instance.title,
  'lesson-version': instance.lessonVersion,
  'isFree': instance.isFree,
  'content': instance.content,
};
