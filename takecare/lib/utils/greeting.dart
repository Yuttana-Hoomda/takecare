
class GreetingHelper {
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "สวัสดีตอนเช้า,";
    if (hour < 17) return "สวัสดีตอนบ่าย,";
    return "สวัสดีตอนเย็น,";
  }
}