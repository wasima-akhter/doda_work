part of 'category_preview_screen.dart';

class CategoryPreviewScreenMobile extends StatelessWidget {
  const CategoryPreviewScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();
    final categoryId = Get.arguments as String;
    final category = categoryController.allCategory.firstWhereOrNull(
      (c) => c.id == categoryId,
    );

    final subcategories = category?.subcategories ?? [];

    return Scaffold(
      appBar: AuthAppBar(title: category?.name ?? 'Category'),
      body: subcategories.isEmpty
          ? Center(
              child: Text(
                "No subcategories available",
                style: TextStyle(
                  fontSize: Dimensions.titleSmall,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.separated(
              padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
              itemCount: subcategories.length,
              separatorBuilder: (_, __) => DividerWidget(),
              itemBuilder: (context, index) {
                final sub = subcategories[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  /*trailing: IconButton(
                    icon: Icon(Icons.favorite_border),
                    color: CustomColors.primary,
                    onPressed: () {
                      debugPrint("object");
                    },
                  ),*/
                  title: TextWidget(
                    sub.name ?? "Unnamed",
                    fontWeight: FontWeight.w500,
                    color: CustomColors.primary,
                    maxLines: 2,
                  ),
                );
              },
            ),
    );
  }
}
