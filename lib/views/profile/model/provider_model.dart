class ProviderProfileModels {
  final int statusCode;
  final bool success;
  final String message;
  final Data data;

  ProviderProfileModels({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProviderProfileModels.fromJson(Map<String, dynamic> json) =>
      ProviderProfileModels(
        statusCode: json["statusCode"],
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  final String id;
  final AuthId authId;
  final String companyName;
  final String website;
  final List<ServiceCategory> serviceCategories;
  final double latitude;
  final double longitude;
  final int coveredRadius;
  final String serviceLocation;
  final String contactPerson;
  final String? profileImage;
  final bool isActive;

  final bool? isOnline;
  final DateTime? lastOnlineAt;
  final bool isRejected;
  final bool isVerified;

  final List<String> attachments;
  final PendingUpdates pendingUpdates;
  final List<WorkingHoursApiResModel> workingHours;

  Data({
    required this.id,
    required this.authId,
    required this.companyName,
    this.profileImage,
    required this.website,
    required this.serviceCategories,
    required this.latitude,
    required this.longitude,
    required this.coveredRadius,
    required this.serviceLocation,
    required this.contactPerson,
    required this.isActive,
    required this.isRejected,
    required this.isVerified,
    required this.attachments,
    required this.pendingUpdates,
    this.isOnline,
    this.lastOnlineAt,
    required this.workingHours,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    authId: AuthId.fromJson(json["authId"]),
    companyName: json["companyName"],
    website: json["website"],
    serviceCategories: List<ServiceCategory>.from(
      json["serviceCategories"].map((x) => ServiceCategory.fromJson(x)),
    ),
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    coveredRadius: json["coveredRadius"],
    serviceLocation: json["serviceLocation"],
    profileImage: json["profile_image"] ?? '',
    contactPerson: json["contactPerson"],
    isActive: json["isActive"],
    isOnline: _toBool(json["isOnline"]),
    lastOnlineAt: _toDate(json["lastOnlineAt"]),
    isRejected: json["isRejected"],
    isVerified: json["isVerified"],
    attachments: List<String>.from(json["attachments"].map((x) => x)),
    pendingUpdates: PendingUpdates.fromJson(json["pendingUpdates"] ?? {}),
    workingHours:
        (json["workingHours"] as List?)
            ?.map((e) => WorkingHoursApiResModel.fromJson(e))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "authId": authId.toJson(),
    "companyName": companyName,
    "website": website,
    "serviceCategories": List<dynamic>.from(
      serviceCategories.map((x) => x.toJson()),
    ),
    "latitude": latitude,
    "longitude": longitude,
    "coveredRadius": coveredRadius,
    "serviceLocation": serviceLocation,
    "contactPerson": contactPerson,
    "isActive": isActive,
    "isRejected": isRejected,
    "isVerified": isVerified,
    "attachments": List<dynamic>.from(attachments.map((x) => x)),
    "pendingUpdates": pendingUpdates.toJson(),
    "workingHours": List<WorkingHoursApiResModel>.from(
      workingHours.map((x) => x.toJson()),
    ),
  };
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

class AuthId {
  final String id;
  final String name;
  final String email;

  AuthId({required this.id, required this.name, required this.email});

  factory AuthId.fromJson(Map<String, dynamic> json) =>
      AuthId(id: json["_id"], name: json["name"], email: json["email"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "email": email};
}

class PendingUpdates {
  final String companyName;
  final String website;
  final String serviceLocation;
  final int coveredRadius;
  final String contactPerson;
  final double latitude;
  final double longitude;
  final String profileImage;

  PendingUpdates({
    required this.companyName,
    required this.website,
    required this.serviceLocation,
    required this.coveredRadius,
    required this.contactPerson,
    required this.latitude,
    required this.longitude,
    required this.profileImage,
  });

  factory PendingUpdates.fromJson(Map<String, dynamic> json) => PendingUpdates(
    companyName: json["companyName"] ?? '',
    website: json["website"] ?? '',
    serviceLocation: json["serviceLocation"] ?? '',
    coveredRadius: json["coveredRadius"] ?? 0,
    contactPerson: json["contactPerson"] ?? '',
    latitude: json["latitude"]?.toDouble() ?? 0.0,
    longitude: json["longitude"]?.toDouble() ?? 0.0,
    profileImage: json["profile_image"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "companyName": companyName,
    "website": website,
    "serviceLocation": serviceLocation,
    "coveredRadius": coveredRadius,
    "contactPerson": contactPerson,
    "latitude": latitude,
    "longitude": longitude,
    "profile_image": profileImage,
  };
}

class ServiceCategory {
  final String id;
  final String name;
  final String icon;

  ServiceCategory({required this.id, required this.name, required this.icon});

  factory ServiceCategory.fromJson(Map<String, dynamic> json) =>
      ServiceCategory(id: json["_id"], name: json["name"], icon: json["icon"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "icon": icon};
}

//
class WorkingHoursApiResModel {
  WorkingHoursApiResModel({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.id,
  });

  final String? day;
  final String? startTime;
  final String? endTime;
  final bool? isAvailable;
  final String? id;

  factory WorkingHoursApiResModel.fromJson(Map<String, dynamic> json) {
    return WorkingHoursApiResModel(
      day: json["day"] ?? '',
      startTime: json["startTime"] ?? '',
      endTime: json["endTime"] ?? '',
      isAvailable: json["isAvailable"] ?? false,
      id: json["_id"] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "day": day,
      "startTime": startTime,
      "endTime": endTime,
      "isAvailable": isAvailable,
    };
  }
}
