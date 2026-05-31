part of '../screen/request_screen.dart';

class RequestPreviewWidget extends StatelessWidget {
  final RequestController controller;
  final String description;
  final String phone;

  const RequestPreviewWidget({
    super.key,
    required this.controller,
    required this.description,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final category = controller.categoryController.allCategory.firstWhereOrNull(
      (c) => c.id == controller.selectedCategoryId.value,
    );
    final subcategory = category?.subcategories?.firstWhereOrNull(
      (s) => s.id == controller.selectedSubCategoryId.value,
    );

    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Service Details"),
          _buildInfoRow("Category", category?.name ?? "N/A"),
          _buildInfoRow("Subcategory", subcategory?.name ?? "N/A"),
          _buildInfoRow("Priority", controller.selectedPriority.value),
          _buildInfoRow("Description", description),
          _buildInfoRow("Phone", phone),

          const Divider(height: 30),

          _buildSectionTitle("Logistics"),
          _buildInfoRow("Date", _formatDateRange()),
          _buildInfoRow("Address", controller.selectedAddress.value),

          const Divider(height: 30),

          _buildSectionTitle("Attachments"),
          _buildPhotoPreview(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextWidget(
        title,
        fontSize: Dimensions.titleMedium,
        fontWeight: FontWeight.bold,
        color: CustomColors.primary,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: TextWidget(
              "$label:",
              fontSize: Dimensions.bodyMedium,
              fontWeight: FontWeight.w500,
              color: CustomColors.grayShade,
            ),
          ),
          Expanded(
            child: TextWidget(
              value,
              fontSize: Dimensions.bodyMedium,
              fontWeight: FontWeight.w400,
              color: CustomColors.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange() {
    if (controller.startDateTime.value == null ||
        controller.endDateTime.value == null) {
      return "N/A";
    }
    final df = DateFormat('MMM dd, yyyy HH:mm');
    return "${df.format(controller.startDateTime.value!)} - ${df.format(controller.endDateTime.value!)}";
  }

  Widget _buildPhotoPreview() {
    if (controller.photos.isEmpty) {
      return const TextWidget("No photos added", color: Colors.grey);
    }
    return SizedBox(
      height: 80.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.photos.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            width: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(controller.photos[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

class RequestInfoCard extends StatelessWidget {
  final String requestId;
  final String category;
  final String subcategory;
  final String priority;
  final String customerName;
  final String address;
  final String phone;
  final String email;
  final String username;

  const RequestInfoCard({
    super.key,
    required this.requestId,
    required this.category,
    required this.subcategory,
    required this.priority,
    required this.customerName,
    required this.address,
    required this.phone,
    required this.email,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize * 0.8,
        vertical: Dimensions.verticalSize * 0.5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3), // shadow position
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabelValue('Request ID', requestId),
          _buildLabelValue('Service category', category),
          _buildLabelValue('Subcategory', subcategory),
          _buildLabelValue('Priority', priority),
          _buildLabelValue('Customer Name', customerName),
          _buildLabelValue('Email', email),
          _buildLabelValue('Phone', phone),
          _buildLabelValue('Username', username),
          _buildLabelValue('Address', address),
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.verticalSize * 0.1),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: CustomColors.primary, // tagline in primary color
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: Colors.black, // value in black
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
