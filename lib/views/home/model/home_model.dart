class HomeServiceItem {
  final String? id;
  final int? leadPrice;
  final CustomerId? customerId;
  final String? customerPhone;
  final ServiceCategory? serviceCategory;
  final String? subcategory;
  final String? priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;
  final String? address;
  final String? postalCode;
  final String? completedById;
  final num? latitude;
  final num? longitude;
  final String? description;
  final List<String> attachments;
  final String? status;
  final num? leadFee;
  final String? paymentStatus;
  final List<CompletionProof> completionProof;
  final List<dynamic> potentialProviders;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? requestId;
  final String? providerNotes;

  HomeServiceItem({
    this.id,
    this.leadPrice,
    this.customerId,
    this.customerPhone,
    this.serviceCategory,
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
    this.attachments = const [],
    this.status,
    this.leadFee,
    this.paymentStatus,
    this.completionProof = const [],
    this.potentialProviders = const [],
    this.createdAt,
    this.updatedAt,
    this.requestId,
    this.providerNotes,
    this.postalCode,
    this.completedById,
  });

  factory HomeServiceItem.fromJson(Map<String, dynamic> json) =>
      HomeServiceItem(
        id: json["_id"],
        leadPrice: json["leadPrice"],
        customerId: json["customerId"] != null
            ? CustomerId.fromJson(json["customerId"])
            : null,
        customerPhone: json["customerPhone"],
        serviceCategory: json["serviceCategory"] != null
            ? ServiceCategory.fromJson(json["serviceCategory"])
            : null,
        subcategory: json["subcategory"],
        priority: json["priority"],
        startDate: json["startDate"] != null
            ? DateTime.parse(json["startDate"])
            : null,
        endDate: json["endDate"] != null
            ? DateTime.parse(json["endDate"])
            : null,
        startTime: json["startTime"],
        endTime: json["endTime"],
        address: json["address"],
        postalCode: json["postalCode"] ?? '',
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        description: json["description"],
        attachments: json["attachments"] != null
            ? List<String>.from(json["attachments"])
            : [],
        status: json["status"],
        leadFee: json["leadFee"],
        paymentStatus: json["paymentStatus"],
        completionProof: json["completionProof"] != null
            ? List<CompletionProof>.from(
                json["completionProof"].map((x) => CompletionProof.fromJson(x)),
              )
            : [],
        potentialProviders: json["potentialProviders"] != null
            ? List<dynamic>.from(json["potentialProviders"])
            : [],
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
            : null,
        requestId: json["requestId"],
        providerNotes: json["providerNotes"],

        // // completedById: json["completedBy"] != null
        // //     ? json["completedBy"]["_id"]
        // //     : null,
        // completedById: json["completedBy"],
        completedById: json["completedBy"] is Map
            ? json["completedBy"]["_id"]
            : json["completedBy"],
      );
}

class CompletionProof {
  final String? url;
  final String? type;
  final DateTime? uploadedAt;
  final int? size;
  final String? mimeType;
  final String? id;

  CompletionProof({
    this.url,
    this.type,
    this.uploadedAt,
    this.size,
    this.mimeType,
    this.id,
  });

  factory CompletionProof.fromJson(Map<String, dynamic> json) =>
      CompletionProof(
        url: json["url"],
        type: json["type"],
        uploadedAt: json["uploadedAt"] != null
            ? DateTime.parse(json["uploadedAt"])
            : null,
        size: json["size"],
        mimeType: json["mimeType"],
        id: json["_id"],
      );
}

class CustomerId {
  final String? id;
  final String? name;
  final String? email;
  final String? avatar;
  final String? phoneNumber;

  CustomerId({this.id, this.name, this.email, this.phoneNumber, this.avatar});

  factory CustomerId.fromJson(Map<String, dynamic> json) => CustomerId(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    avatar: json["avatar"],
    phoneNumber: json["phoneNumber"],
  );
}

class ServiceCategory {
  final String? id;
  final String? name;
  final String? icon;

  ServiceCategory({this.id, this.name, this.icon});

  factory ServiceCategory.fromJson(Map<String, dynamic> json) =>
      ServiceCategory(id: json["_id"], name: json["name"], icon: json["icon"]);
}

class HomeModel {
  final num? statusCode;
  final bool? success;
  final String? message;
  final Data? data;

  HomeModel({this.statusCode, this.success, this.message, this.data});

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
    statusCode: json["statusCode"],
    success: json["success"],
    message: json["message"],
    data: json["data"] != null ? Data.fromJson(json["data"]) : null,
  );
}

class Data {
  final List<HomeServiceItem> requests;
  final bool? success;
  final String? message;

  Data({this.requests = const [], this.success, this.message});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    requests: json["requests"] != null
        ? List<HomeServiceItem>.from(
            json["requests"].map((x) => HomeServiceItem.fromJson(x)),
          )
        : [],
    success: json["success"],
    message: json["message"],
  );
}
