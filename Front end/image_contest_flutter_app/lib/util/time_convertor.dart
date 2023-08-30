import '../application_localizations.dart';
import 'navigation_service.dart';

class TimeAgo {
  static String timeAgoSinceDate(DateTime timeAgoDate,
      {bool numericDates = true}) {
    final difference = DateTime.now().difference(timeAgoDate);

    if (difference.inDays > 8) {
      int days = difference.inDays;
      if (days > 365) {
        //Years
        int years = (days / 365).round();

        return years >= 2
            ? '$years ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('monthsAgo_text')}'
            : '$years ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('monthAgo_text')}';
      } else {
        int months = (days / 30).round();
        return months >= 2
            ? '$months ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('monthsAgo_text')}'
            : '$months ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('monthAgo_text')}';
      }
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates)
          ? '1 ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('weekAgo_text')}'
          : ApplicationLocalizations.of(
                  NavigationService.instance.getCurrentStateContext())
              .translate('lastWeek_text');
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('daysAgo_text')}';
    } else if (difference.inDays >= 1) {
      return (numericDates)
          ? '1 ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('dayAgo_text')}'
          : ApplicationLocalizations.of(
                  NavigationService.instance.getCurrentStateContext())
              .translate('yesterday_text');
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('hoursAgo_text')}';
    } else if (difference.inHours >= 1) {
      return (numericDates)
          ? '1 ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('hourAgo_text')}'
          : ApplicationLocalizations.of(
                  NavigationService.instance.getCurrentStateContext())
              .translate('anHourAgo_text');
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('minutesAgo_text')}';
    } else if (difference.inMinutes >= 1) {
      return (numericDates)
          ? '1 ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('minuteAgo_text')}'
          : ApplicationLocalizations.of(
                  NavigationService.instance.getCurrentStateContext())
              .translate('aMinuteAgo_text');
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} ${ApplicationLocalizations.of(NavigationService.instance.getCurrentStateContext()).translate('secondsAgo_text')}';
    } else {
      return ApplicationLocalizations.of(
              NavigationService.instance.getCurrentStateContext())
          .translate('justNow_text');
    }
  }
}
