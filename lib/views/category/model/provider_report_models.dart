class ProviderReportModel {
  final int statusCode;
  final bool success;
  final String message;
  final ProviderReportData? data;

  ProviderReportModel({
    required this.statusCode,
    required this.success,
    required this.message,
    this.data,
  });

  factory ProviderReportModel.fromJson(Map<String, dynamic> json) {
    return ProviderReportModel(
      statusCode: _toInt(json["statusCode"]),
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null
          ? ProviderReportData.fromJson(json["data"])
          : null,
    );
  }
}

class ProviderReportData {
  final ReportPeriod? period;
  final ReportOverview? overview;
  final ReportCards? cards;
  final ReportPipeline? pipeline;
  final ReportLifetime? lifetime;
  final int recentReviews;

  ProviderReportData({
    this.period,
    this.overview,
    this.cards,
    this.pipeline,
    this.lifetime,
    required this.recentReviews,
  });

  factory ProviderReportData.fromJson(Map<String, dynamic> json) {
    return ProviderReportData(
      period: json["period"] != null
          ? ReportPeriod.fromJson(json["period"])
          : null,
      overview: json["overview"] != null
          ? ReportOverview.fromJson(json["overview"])
          : null,
      cards: json["cards"] != null ? ReportCards.fromJson(json["cards"]) : null,
      pipeline: json["pipeline"] != null
          ? ReportPipeline.fromJson(json["pipeline"])
          : null,
      lifetime: json["lifetime"] != null
          ? ReportLifetime.fromJson(json["lifetime"])
          : null,
      recentReviews: _toInt(json["recentReviews"]),
    );
  }
}

class ReportPeriod {
  final String type;
  final String label;
  final DateTime? startDate;
  final DateTime? endDateExclusive;
  final DateTime? previousStartDate;
  final DateTime? previousEndDateExclusive;

  ReportPeriod({
    required this.type,
    required this.label,
    this.startDate,
    this.endDateExclusive,
    this.previousStartDate,
    this.previousEndDateExclusive,
  });

  factory ReportPeriod.fromJson(Map<String, dynamic> json) {
    return ReportPeriod(
      type: json["type"] ?? "",
      label: json["label"] ?? "",
      startDate: _toDate(json["startDate"]),
      endDateExclusive: _toDate(json["endDateExclusive"]),
      previousStartDate: _toDate(json["previousStartDate"]),
      previousEndDateExclusive: _toDate(json["previousEndDateExclusive"]),
    );
  }
}

class ReportOverview {
  final double rating;
  final int totalReviews;
  final int totalLeadsPurchased;
  final int totalServicesCompleted;
  final bool isOnline;

  ReportOverview({
    required this.rating,
    required this.totalReviews,
    required this.totalLeadsPurchased,
    required this.totalServicesCompleted,
    required this.isOnline,
  });

  factory ReportOverview.fromJson(Map<String, dynamic> json) {
    return ReportOverview(
      rating: _toDouble(json["rating"]),
      totalReviews: _toInt(json["totalReviews"]),
      totalLeadsPurchased: _toInt(json["totalLeadsPurchased"]),
      totalServicesCompleted: _toInt(json["totalServicesCompleted"]),
      isOnline: json["isOnline"] ?? false,
    );
  }
}

class ReportCards {
  final ReportCardItem? totalRequests;
  final ReportCardItem? totalAccepted;
  final ReportCardItem? totalCompleted;
  final PurchaseCardItem? totalPurchase;

  ReportCards({
    this.totalRequests,
    this.totalAccepted,
    this.totalCompleted,
    this.totalPurchase,
  });

  factory ReportCards.fromJson(Map<String, dynamic> json) {
    return ReportCards(
      totalRequests: json["totalRequests"] != null
          ? ReportCardItem.fromJson(json["totalRequests"])
          : null,
      totalAccepted: json["totalAccepted"] != null
          ? ReportCardItem.fromJson(json["totalAccepted"])
          : null,
      totalCompleted: json["totalCompleted"] != null
          ? ReportCardItem.fromJson(json["totalCompleted"])
          : null,
      totalPurchase: json["totalPurchase"] != null
          ? PurchaseCardItem.fromJson(json["totalPurchase"])
          : null,
    );
  }
}

class ReportCardItem {
  final int current;
  final int previous;
  final double percentage;
  final String direction;

  final int newRequestsCount;
  final int pendingResponseCount;

  final int upcomingTasksCount;
  final int awaitingPaymentCount;

  final int incompleteTasksCount;
  final int awaitingCustomerApprovalCount;

  ReportCardItem({
    required this.current,
    required this.previous,
    required this.percentage,
    required this.direction,
    required this.newRequestsCount,
    required this.pendingResponseCount,
    required this.upcomingTasksCount,
    required this.awaitingPaymentCount,
    required this.incompleteTasksCount,
    required this.awaitingCustomerApprovalCount,
  });

  factory ReportCardItem.fromJson(Map<String, dynamic> json) {
    return ReportCardItem(
      current: _toInt(json["current"]),
      previous: _toInt(json["previous"]),
      percentage: _toDouble(json["percentage"]),
      direction: json["direction"] ?? "",

      newRequestsCount: _toInt(json["newRequestsCount"]),
      pendingResponseCount: _toInt(json["pendingResponseCount"]),

      upcomingTasksCount: _toInt(json["upcomingTasksCount"]),
      awaitingPaymentCount: _toInt(json["awaitingPaymentCount"]),

      incompleteTasksCount: _toInt(json["incompleteTasksCount"]),
      awaitingCustomerApprovalCount: _toInt(
        json["awaitingCustomerApprovalCount"],
      ),
    );
  }
}

class PurchaseCardItem {
  final double current;
  final double previous;
  final double percentage;
  final String direction;
  final String currency;

  PurchaseCardItem({
    required this.current,
    required this.previous,
    required this.percentage,
    required this.direction,
    required this.currency,
  });

  factory PurchaseCardItem.fromJson(Map<String, dynamic> json) {
    return PurchaseCardItem(
      current: _toDouble(json["current"]),
      previous: _toDouble(json["previous"]),
      percentage: _toDouble(json["percentage"]),
      direction: json["direction"] ?? "",
      currency: json["currency"] ?? "",
    );
  }
}

class ReportPipeline {
  final int pendingResponseCount;
  final int awaitingPaymentCount;
  final int upcomingTasksCount;
  final int incompleteTasksCount;
  final int activeJobsCount;
  final int awaitingCustomerApprovalCount;

  ReportPipeline({
    required this.pendingResponseCount,
    required this.awaitingPaymentCount,
    required this.upcomingTasksCount,
    required this.incompleteTasksCount,
    required this.activeJobsCount,
    required this.awaitingCustomerApprovalCount,
  });

  factory ReportPipeline.fromJson(Map<String, dynamic> json) {
    return ReportPipeline(
      pendingResponseCount: _toInt(json["pendingResponseCount"]),
      awaitingPaymentCount: _toInt(json["awaitingPaymentCount"]),
      upcomingTasksCount: _toInt(json["upcomingTasksCount"]),
      incompleteTasksCount: _toInt(json["incompleteTasksCount"]),
      activeJobsCount: _toInt(json["activeJobsCount"]),
      awaitingCustomerApprovalCount: _toInt(
        json["awaitingCustomerApprovalCount"],
      ),
    );
  }
}

class ReportLifetime {
  final int totalRequests;
  final int acceptedRequests;
  final int completedRequests;
  final int declinedRequests;
  final double totalPurchaseAmount;
  final int totalLeadsPurchased;
  final double acceptanceRate;
  final double completionRate;

  ReportLifetime({
    required this.totalRequests,
    required this.acceptedRequests,
    required this.completedRequests,
    required this.declinedRequests,
    required this.totalPurchaseAmount,
    required this.totalLeadsPurchased,
    required this.acceptanceRate,
    required this.completionRate,
  });

  factory ReportLifetime.fromJson(Map<String, dynamic> json) {
    return ReportLifetime(
      totalRequests: _toInt(json["totalRequests"]),
      acceptedRequests: _toInt(json["acceptedRequests"]),
      completedRequests: _toInt(json["completedRequests"]),
      declinedRequests: _toInt(json["declinedRequests"]),
      totalPurchaseAmount: _toDouble(json["totalPurchaseAmount"]),
      totalLeadsPurchased: _toInt(json["totalLeadsPurchased"]),
      acceptanceRate: _toDouble(json["acceptanceRate"]),
      completionRate: _toDouble(json["completionRate"]),
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
