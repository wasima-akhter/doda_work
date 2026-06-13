import '../../../../core/utils/basic_import.dart';
import '../../../../widgets/web_vew_page_widget.dart';
import '../controller/register_controller.dart';

class ButtonAndTextSectionView extends GetView<RegisterController> {
  const ButtonAndTextSectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Space.height.v20,
        TermsAndPolicyWidget(
          isChecked: controller.isCheck,
          isError: controller.isError,
          mainText: 'DodaWork',
          termsTap: () {
            Get.to(
              () => const WebViewScreen(
                url: 'https://dodawork.ca/terms',
                title: 'Terms & Conditions',
              ),
            );
          },
          policyTap: () {
            Get.to(
              () => const WebViewScreen(
                url: 'https://dodawork.ca/privacy',
                title: 'Privacy Policy',
              ),
            );
          },
        ),

        Space.height.v20,
        Obx(
          () => PrimaryButtonWidget(
            isLoading: controller.isLoading.value,
            title: "Next",
            onPressed: () {
              if (controller.fromKey.currentState!.validate()) {
                if (controller.isCheck.value) {
                  controller.registerProcess();
                } else {
                  controller.isError.value = true;
                  CustomSnackBar.error(
                    'Please review the Privacy Policy and accept the Terms and Conditions to proceed',
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }
}

class TermsAndPolicyWidget extends StatelessWidget {
  final RxBool isChecked;
  final RxBool isError;
  final String mainText;
  final VoidCallback termsTap;
  final VoidCallback policyTap;

  const TermsAndPolicyWidget({
    super.key,
    required this.isChecked,
    required this.isError,
    required this.mainText,
    required this.termsTap,
    required this.policyTap,
  });

  void _toggle() {
    isChecked.value = !isChecked.value;
    if (isChecked.value) {
      isError.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    const errorColor = Colors.red;
    const normalColor = Colors.grey;

    return InkWell(
      onTap: _toggle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => SizedBox(
              height: 24.h,
              width: 24.w,
              child: Checkbox(
                value: isChecked.value,
                activeColor: primaryColor,

                side: BorderSide(
                  color: isError.value ? errorColor : CustomColors.disableColor,
                  width: 1.4.w,
                ),
                onChanged: (_) => _toggle(),
              ),
            ),
          ),
          Space.width.v10,
          Expanded(
            child: Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(
                  isError.value ? 10 : 0,
                  0,
                  0,
                ),
                child: Wrap(
                  children: [
                    _text(
                      "I have read and agree to $mainText's ",
                      color: isError.value ? errorColor : normalColor,
                    ),
                    _link(
                      "Terms & Conditions",
                      termsTap,
                      isError.value ? errorColor : primaryColor,
                    ),
                    _text(
                      " and ",
                      color: isError.value ? errorColor : normalColor,
                    ),
                    _link(
                      "Privacy Policy",
                      policyTap,
                      isError.value ? errorColor : primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Normal text
  Widget _text(String text, {required Color color}) {
    return Text(text, style: TextStyle(fontSize: 14, color: color));
  }

  // Clickable link text
  Widget _link(String text, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
