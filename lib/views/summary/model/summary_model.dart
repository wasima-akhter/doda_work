import '../../home/model/home_model.dart';

class SummaryModel {
  final bool isUser;
  final String? id;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? categoryName;
  final String? categoryIcon;
  final String? subcategory;
  final String? priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;
  final String? address;
  final num? latitude;
  final num? longitude;
  final String? description;
  final List<String?>? attachments;
  final String? status;
  final num? leadFee;
  final String? paymentStatus;
  final List<CompletionProof>? completionProof; // ✅ here
  final List<dynamic>? potentialProviders;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? requestId;
  final String? providerNotes;
  final String? completedById;

  SummaryModel({
    required this.isUser,
    this.id,
    this.customerName,
    this.customerPhone,
    this.categoryName,
    this.categoryIcon,
    this.subcategory,
    this.priority,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.attachments,
    this.status,
    this.leadFee,
    this.paymentStatus,
    this.completionProof,
    this.potentialProviders,
    this.createdAt,
    this.updatedAt,
    this.requestId,
    this.providerNotes,
    this.completedById,
    this.customerEmail,
  });
}
