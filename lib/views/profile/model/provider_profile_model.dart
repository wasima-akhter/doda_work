class ProviderProfileModel {
  final String id;
  final AuthIdModel? authId;
  final String companyName;
  final String website;
  final List<ServiceCategoryModel> serviceCategories;

  final double latitude;
  final double longitude;
  final int coveredRadius;

  final String serviceLocation;
  final String? postalCode;
  final bool isActive;
  final bool? isOnline;
  final DateTime? lastOnlineAt;

  final bool isVerified;

  final List<String> licenses;
  final List<String> certificates;

  final double rating;
  final int totalReviews;
  final String? profileImage;
  final PendingUpdatesModel? pendingUpdates;
  final dynamic reservedProvider;
  final String? paymentIntentId;

  final List<dynamic> potentialProviders;
  final List<String> attachments;

  final String contactPerson;
  final bool isRejected;

  final List<WorkingHourModel> workingHours;
  final StatsModel? stats;

  final BusinessVerificationModel? businessVerification;
  final int totalLeadsPurchased;
  final double totalSpentOnLeads;
  final int totalServicesCompleted;
  final double completionRate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProviderProfileModel({
    required this.id,
    this.authId,
    required this.companyName,
    required this.website,
    required this.serviceCategories,
    required this.latitude,
    required this.longitude,
    required this.coveredRadius,
    required this.serviceLocation,
    this.postalCode,
    required this.isActive,
    required this.isVerified,
    required this.licenses,
    required this.certificates,
    required this.rating,
    required this.totalReviews,
    this.pendingUpdates,
    this.reservedProvider,
    this.paymentIntentId,
    required this.potentialProviders,
    required this.attachments,
    required this.contactPerson,
    required this.isRejected,
    this.isOnline,
    this.lastOnlineAt,
    this.workingHours = const [],
    this.stats,
    this.profileImage,
    this.businessVerification,
    this.totalLeadsPurchased = 0,
    this.totalSpentOnLeads = 0,
    this.totalServicesCompleted = 0,
    this.completionRate = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ProviderProfileModel.fromJson(Map<String, dynamic> json) {
    return ProviderProfileModel(
      id: json["_id"] ?? '',

      authId: json["authId"] != null
          ? AuthIdModel.fromJson(json["authId"])
          : null,

      companyName: json["companyName"] ?? "",
      website: json["website"] ?? "",

      serviceCategories: (json["serviceCategories"] as List? ?? [])
          .map((e) => ServiceCategoryModel.fromJson(e))
          .toList(),

      latitude: _toDouble(json["latitude"]),
      longitude: _toDouble(json["longitude"]),
      coveredRadius: _toInt(json["coveredRadius"]),

      serviceLocation: json["serviceLocation"] ?? "",
      postalCode: json["postalCode"],
      isActive: json["isActive"] ?? false,
      isVerified: json["isVerified"] ?? false,

      licenses: List<String>.from(json["licenses"] ?? []),
      certificates: List<String>.from(json["certificates"] ?? []),

      rating: _toDouble(json["rating"]),
      totalReviews: _toInt(json["totalReviews"]),

      pendingUpdates: json["pendingUpdates"] != null
          ? PendingUpdatesModel.fromJson(json["pendingUpdates"])
          : null,

      reservedProvider: json["reservedProvider"],
      paymentIntentId: json["paymentIntentId"],
      potentialProviders: json["potentialProviders"] ?? [],

      attachments: List<String>.from(json["attachments"] ?? []),

      contactPerson: json["contactPerson"] ?? "",
      isRejected: json["isRejected"] ?? false,

      isOnline: _toBool(json["isOnline"]),
      lastOnlineAt: _toDate(json["lastOnlineAt"]),

      profileImage: json["profile_image"],

      workingHours: (json["workingHours"] as List? ?? [])
          .map((e) => WorkingHourModel.fromJson(e))
          .toList(),

      stats: json["stats"] != null ? StatsModel.fromJson(json["stats"]) : null,

      businessVerification: json["businessVerification"] != null
          ? BusinessVerificationModel.fromJson(json["businessVerification"])
          : null,

      totalLeadsPurchased: _toInt(json["totalLeadsPurchased"]),
      totalSpentOnLeads: _toDouble(json["totalSpentOnLeads"]),
      totalServicesCompleted: _toInt(json["totalServicesCompleted"]),
      completionRate: _toDouble(json["completionRate"]),

      createdAt: _toDate(json["createdAt"]),
      updatedAt: _toDate(json["updatedAt"]),
    );
  }
}

// --- Helpers ---

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

bool? _toBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v == 1;
  return v.toString().toLowerCase() == "true";
}

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

// --- Sub-models ---

class AuthIdModel {
  final String id;
  final String name;
  final String email;

  AuthIdModel({required this.id, required this.name, required this.email});

  factory AuthIdModel.fromJson(Map<String, dynamic> json) {
    return AuthIdModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
    );
  }
}

class ServiceCategoryModel {
  final String id;
  final String name;
  final String icon;
  final double price;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      icon: json["icon"] ?? "",
      price: _toDouble(json["price"]),
    );
  }
}

class WorkingHourModel {
  final String day;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final String id;

  WorkingHourModel({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.id,
  });

  factory WorkingHourModel.fromJson(Map<String, dynamic> json) {
    return WorkingHourModel(
      day: json["day"] ?? "",
      startTime: json["startTime"] ?? "",
      endTime: json["endTime"] ?? "",
      isAvailable: json["isAvailable"] ?? false,
      id: json["_id"] ?? "",
    );
  }
}

class PendingUpdatesModel {
  final String? companyName;
  final String? website;
  final String? serviceLocation;
  final int? coveredRadius;
  final String? contactPerson;
  final double? latitude;
  final double? longitude;

  PendingUpdatesModel({
    this.companyName,
    this.website,
    this.serviceLocation,
    this.coveredRadius,
    this.contactPerson,
    this.latitude,
    this.longitude,
  });

  factory PendingUpdatesModel.fromJson(Map<String, dynamic> json) {
    return PendingUpdatesModel(
      companyName: json["companyName"],
      website: json["website"],
      serviceLocation: json["serviceLocation"],
      coveredRadius: json["coveredRadius"],
      contactPerson: json["contactPerson"],
      latitude: _toDouble(json["latitude"]),
      longitude: _toDouble(json["longitude"]),
    );
  }
}

class StatsModel {
  final int totalAssignedRequests;
  final int totalCompletedRequests;
  final int totalPendingRequests;
  final double acceptanceRate;

  StatsModel({
    required this.totalAssignedRequests,
    required this.totalCompletedRequests,
    required this.totalPendingRequests,
    required this.acceptanceRate,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      totalAssignedRequests: _toInt(json["totalAssignedRequests"]),
      totalCompletedRequests: _toInt(json["totalCompletedRequests"]),
      totalPendingRequests: _toInt(json["totalPendingRequests"]),
      // acceptanceRate comes as a String "0.0" in the API, so _toDouble handles it
      acceptanceRate: _toDouble(json["acceptanceRate"]),
    );
  }
}

class BusinessVerificationModel {
  final String status;
  final List<dynamic> documents;

  BusinessVerificationModel({required this.status, required this.documents});

  factory BusinessVerificationModel.fromJson(Map<String, dynamic> json) {
    return BusinessVerificationModel(
      status: json["status"] ?? "",
      documents: json["documents"] ?? [],
    );
  }
}
