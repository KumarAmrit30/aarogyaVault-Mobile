import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/features/ocr/data/models/critical_finding_model.dart';
import 'package:mobile_app/features/ocr/domain/entities/ocr_result.dart';

/// Firestore DTO for `ocr_results/{documentId}`.
///
/// Handles both v1 (inline [extractedText]) and v2 (Storage + analysis)
/// record shapes. Text loaded from Storage is passed via
/// [resolvedExtractedText] when mapping to a domain entity.
class OcrResultModel {
  const OcrResultModel({
    required this.documentId,
    required this.summary,
    required this.createdAt,
    this.extractedText,
    this.ocrTextPath,
    this.ocrCharacterCount,
    this.documentType,
    this.processingVersion,
    this.ocrProvider,
    this.ocrConfidence,
    this.pageCount,
    this.criticalFindings = const [],
    this.normalFindings = const [],
    this.recommendedFollowUp = const [],
    this.handwritingDetected,
    this.extractionWarning,
    this.riskLevel,
  });

  final String documentId;
  final String summary;
  final DateTime createdAt;

  /// Present on v1 records; absent on v2 Storage-backed records.
  final String? extractedText;

  final String? ocrTextPath;
  final int? ocrCharacterCount;
  final String? documentType;
  final int? processingVersion;
  final String? ocrProvider;
  final double? ocrConfidence;
  final int? pageCount;
  final List<CriticalFindingModel> criticalFindings;
  final List<String> normalFindings;
  final List<String> recommendedFollowUp;
  final bool? handwritingDetected;
  final String? extractionWarning;
  final String? riskLevel;

  /// True when OCR text must be fetched from Storage (v2).
  bool get requiresStorageTextLoad =>
      (extractedText == null || extractedText!.isEmpty) &&
      ocrTextPath != null &&
      ocrTextPath!.isNotEmpty;

  /// Returns true when a raw Firestore map needs Storage text resolution.
  static bool mapRequiresStorageTextLoad(Map<String, dynamic> map) {
    final inlineText = map['extractedText'] as String?;
    final path = map['ocrTextPath'] as String?;
    return (inlineText == null || inlineText.isEmpty) &&
        path != null &&
        path.isNotEmpty;
  }

  /// Builds a model from a Firestore document map.
  factory OcrResultModel.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    return OcrResultModel(
      documentId: documentId,
      summary: map['summary'] as String,
      createdAt: _toDateTime(map['createdAt']),
      extractedText: map['extractedText'] as String?,
      ocrTextPath: map['ocrTextPath'] as String?,
      ocrCharacterCount: _toInt(map['ocrCharacterCount']),
      documentType: map['documentType'] as String?,
      processingVersion: _toInt(map['processingVersion']),
      ocrProvider: map['ocrProvider'] as String?,
      ocrConfidence: _toDouble(map['ocrConfidence']),
      pageCount: _toInt(map['pageCount']),
      criticalFindings:
          CriticalFindingModel.listFromDynamic(map['criticalFindings']),
      normalFindings: _stringList(map['normalFindings']),
      recommendedFollowUp: _stringList(map['recommendedFollowUp']),
      handwritingDetected: map['handwritingDetected'] as bool?,
      extractionWarning: map['extractionWarning'] as String?,
      riskLevel: map['riskLevel'] as String?,
    );
  }

  /// Serializes to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'summary': summary,
      'createdAt': Timestamp.fromDate(createdAt),
      if (extractedText != null) 'extractedText': extractedText,
      if (ocrTextPath != null) 'ocrTextPath': ocrTextPath,
      if (ocrCharacterCount != null) 'ocrCharacterCount': ocrCharacterCount,
      if (documentType != null) 'documentType': documentType,
      if (processingVersion != null) 'processingVersion': processingVersion,
      if (ocrProvider != null) 'ocrProvider': ocrProvider,
      if (ocrConfidence != null) 'ocrConfidence': ocrConfidence,
      if (pageCount != null) 'pageCount': pageCount,
      if (criticalFindings.isNotEmpty)
        'criticalFindings':
            criticalFindings.map((finding) => finding.toMap()).toList(),
      if (normalFindings.isNotEmpty) 'normalFindings': normalFindings,
      if (recommendedFollowUp.isNotEmpty)
        'recommendedFollowUp': recommendedFollowUp,
      if (handwritingDetected != null)
        'handwritingDetected': handwritingDetected,
      if (extractionWarning != null) 'extractionWarning': extractionWarning,
      if (riskLevel != null) 'riskLevel': riskLevel,
    };
  }

  /// Converts to domain entity.
  ///
  /// Pass [resolvedExtractedText] when [requiresStorageTextLoad] is true.
  OcrResult toEntity({String? resolvedExtractedText}) {
    final text = extractedText ?? resolvedExtractedText ?? '';
    return OcrResult(
      documentId: documentId,
      extractedText: text,
      summary: summary,
      createdAt: createdAt,
      ocrTextPath: ocrTextPath,
      ocrCharacterCount: ocrCharacterCount,
      documentType: documentType,
      processingVersion: processingVersion,
      ocrProvider: ocrProvider,
      ocrConfidence: ocrConfidence,
      pageCount: pageCount,
      criticalFindings:
          criticalFindings.map((finding) => finding.toEntity()).toList(),
      normalFindings: List<String>.from(normalFindings),
      recommendedFollowUp: List<String>.from(recommendedFollowUp),
      handwritingDetected: handwritingDetected,
      extractionWarning: extractionWarning,
      riskLevel: riskLevel,
    );
  }

  /// Builds a model from a domain entity.
  factory OcrResultModel.fromEntity(OcrResult entity) {
    return OcrResultModel(
      documentId: entity.documentId,
      summary: entity.summary,
      createdAt: entity.createdAt,
      extractedText:
          entity.isStorageBacked ? null : entity.extractedText,
      ocrTextPath: entity.ocrTextPath,
      ocrCharacterCount: entity.ocrCharacterCount,
      documentType: entity.documentType,
      processingVersion: entity.processingVersion,
      ocrProvider: entity.ocrProvider,
      ocrConfidence: entity.ocrConfidence,
      pageCount: entity.pageCount,
      criticalFindings: entity.criticalFindings
          .map(CriticalFindingModel.fromEntity)
          .toList(),
      normalFindings: List<String>.from(entity.normalFindings),
      recommendedFollowUp: List<String>.from(entity.recommendedFollowUp),
      handwritingDetected: entity.handwritingDetected,
      extractionWarning: entity.extractionWarning,
      riskLevel: entity.riskLevel,
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    throw FormatException(
      'Expected Timestamp or DateTime, got ${value.runtimeType}.',
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    return value.whereType<String>().toList();
  }
}
