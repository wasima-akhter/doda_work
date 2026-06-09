class ApiEndPoints {
  // static final mainDomain = 'http://3.96.86.190:3001';
  static final mainDomain = 'https://api.dodawork.com';
  static final baseUrl = '$mainDomain/';

  //GOOGLE MAP API KEY
  static const String googleApiKeyAndroid =
      "AIzaSyAXGE6m2DSrdc-F21kQXMdwfni5KZNsCLI";
  static const String googleApiKeyIos =
      "AIzaSyAXGE6m2DSrdc-F21kQXMdwfni5KZNsCLI";

  /// API End Points
  // Auth
  static const login = 'auth/login';
  static const register = 'auth/register';
  static const verifyEmail = 'auth/activate-account';

  static const forgotOtpVerify = 'auth/forget-pass-otp-verify';

  static const resendOtpCode = 'auth/activation-code-resend';
  static const resetPassword = 'auth/reset-password';
  static const forgotPassword = 'auth/forgot-password';
  static const providerRegister = 'provider/provider-register';

  //home
  static const banner = 'banner/get';
  static const privacy = 'manage/get-privacy-policy';
  static const terms = 'manage/get-terms-conditions';
  static const allEbookGet = 'ebooks/get';
  static const blockUser = 'chat/block/';
  static const unBlockUser = 'chat/unblock/';
  static const deleteMessage = 'ebooks/get';
  static const getAllBookCategory = 'book-categories/get';
  static const singlePost = 'home/book';

  //user_category
  static const getAllCategory = 'category/active-categories';
  static const getFavoritesCategory = 'category/favorites';
  static const patchToggleToFavorites = 'category/toggle-to-favorites';
  static const getSubCategoriesByCategory =
      'category/subcategories-by-category?categoryId=68c6f418136f3599e8c394b4';

  static const categoryPreview = 'categories/books';
  static const serviceCategory = 'category/active-categories';
  static const getAllAudioBook = 'audio-books/get';
  static const faqGet = 'manage/get-faq';

  //profile
  static const changePassword = 'auth/change-password';
  static const userProfile = 'user/profile';
  static const providerProfile = 'provider/profile';
  static const userUpdateProfile = 'user/edit-profile';
  static const providerUpdateProfile = 'provider/update-profile';
  static const deleteProfile = 'user/delete-account';

  //chat

  static const allMessage = 'chat/get-conversation?partnerId=';

  //bookmark
  static const bookMark = 'home/save';
  static const bookMarkData = 'home/saved';
  static const userProgress = 'user-progress/continue';

  static final getTerms = '${baseUrl}manage/get-terms-conditions';
  static final getPrivacy = '${baseUrl}manage/get-privacy-policy';
  static final updateProviderLicence = '${baseUrl}provider/update-profile';

  static final categoryAll = '${baseUrl}category/active-categories';
  static final providerReports = '${baseUrl}provider/reports';

  // static String getServiceRequestAll({required int page}) {
  //   return '${baseUrl}service-requests/my-requests?page=$page';
  // }

  static serviceCreate() => '${baseUrl}service-requests/create';

  static myService({required String status, required int page}) =>
      '${baseUrl}service-requests/my-requests?status=$status&page=$page&limit=20';

  // static myService({required String status, required int page}) =>
  //     '${baseUrl}service-requests/my-requests';

  //service-requests/my-requests

  static providerService({required String status, required int page}) =>
      '${baseUrl}provider/potential-requests?providerStatus=$status&page=$page&limit=20';

  static providerChangeStatus() => 'provider/handle-request';

  static notification({required int page}) =>
      '${baseUrl}notification/get-all-notifications?page=$page&limit=20';

  var notificationId = "";

  //====================Notification=========================
  static final getAllNotification =
      '${baseUrl}notification/get-all-notifications';
  static final getNotification =
      '${baseUrl}notification/get-notification?notificationId=notificationId';
  static final deleteNotification =
      '${baseUrl}notification/delete-notification';

  //=================Review=================================
  static final postPostReview = '${baseUrl}review/post-review';
  static final getAllReview = '${baseUrl}review/get-all-reviews';

  static String getReview({required String reviewId}) =>
      '${baseUrl}review/get-review?reviewId=$reviewId';
  static final getReviewProvider = 'review/get-provider-reviews';

  // ================== Chat ==================
  static String getConversationList = 'chat/get-conversation-list';

  static String getConversationById(String conversationId) =>
      'chat/get-conversation/$conversationId';

  static String postBlockUser(String targetUserId) =>
      '$baseUrl/chat/block/$targetUserId';

  static String postUnblockUser(String targetUserId) =>
      '$baseUrl/chat/unblock/$targetUserId';

  //
  // static final postBlockUser = '${baseUrl}chat/block/:targetUserId';
  // static final postUnblockUser = '${baseUrl}chat/unblock/:targetUserId';
  static final postDeleteMessage = '${baseUrl}chat/delete-message/:messageId';
  static final postChatImageORVideo = '${baseUrl}chat/chat-images-video';
}
