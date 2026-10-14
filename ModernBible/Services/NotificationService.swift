import Foundation
import UserNotifications

/// Local (on-device) notifications only — no server/push infra needed for a daily verse reminder.
final class NotificationService {
    static let shared = NotificationService()
    private let dailyVerseIdentifier = "daily-verse-reminder"

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    /// Schedules a repeating daily local notification at the given time with the day's verse text.
    /// The verse text itself should be resolved from a small bundled "verse of the day" list keyed by
    /// day-of-year, so this works fully offline with no server involved.
    func scheduleDailyVerse(at time: Date, verseText: String, verseReference: String) {
        cancelDailyVerse()

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("daily_verse.notification.title", comment: "Verse of the Day")
        content.body = "\(verseText) — \(verseReference)"
        content.sound = .default

        var components = Calendar.current.dateComponents([.hour, .minute], from: time)
        components.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: dailyVerseIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelDailyVerse() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyVerseIdentifier])
    }
}
