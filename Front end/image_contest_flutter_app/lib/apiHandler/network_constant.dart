class NetworkConstantsUtil {
  static String baseUrl = 'https://fwdtechnology.co/image_selling/api/web/v1/';

  static String login = 'users/login';
  static String socialLogin = 'users/login-social';
  static String forgotPassword = 'users/forgot-password-request';
  static String resetPassword = 'users/set-new-password';
  static String resendOTP = 'users/resend-otp';

  static String verifyRegistrationOTP = 'users/verify-registration-otp';
  static String verifyFwdPWDOTP = 'users/forgot-password-verify-otp';

  static String register = 'users/register';
  static String checkUserName = 'users/check-username';

  static String getCompetitions = 'competitions?expand=post,post.user,winnerPost.user';
  static String joinCompetition = 'competitions/join';

  static String addPost = 'posts';
  static String uploadPostImage ='posts/upload-gallary';
  static String addCompetitionPost = 'posts/competition-image';
  static String searchPost = 'posts/search-post?expand=user';
  static String likePost = 'posts/like';
  static String unlikePost = 'posts/unlike';

  static String getComments = 'posts/comment-list';
  static String addComment = 'posts/add-comment';
  static String reportPost = 'posts/report-post';

  static String otherUser = 'users/';
  static String followUser = 'followers';
  static String unfollowUser = 'followers/unfollow';
  static String searchUsers = 'users/search-user';
  static String getUserProfile = 'users/profile?expand=following.followingUserDetail,follower.followerUserDetail';
  static String updateUserProfile = 'users/profile-update';
  static String updateProfileImage = 'users/update-profile-image';

  static String getCountries = 'countries';
  static String reportUser = 'users/report-user';

  static String getPackages = 'packages';
  static String subscribePackage = 'payments/package-subscription';
  static String updatePaymentDetail = 'users/update-payment-detail';
  static String withdrawHistory = 'payments/withdrawal-history';
  static String withdrawalRequest = 'payments/withdrawal';
}
