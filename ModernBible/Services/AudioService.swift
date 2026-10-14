import AVFoundation
import Combine

/// Streams audio Bible chapters by default; supports explicit per-chapter download for offline use.
final class AudioService: ObservableObject {
    static let shared = AudioService()

    @Published var isPlaying = false
    @Published var currentReference: VerseReference?
    @Published var playbackProgress: Double = 0 // 0...1

    private var player: AVPlayer?
    private var timeObserver: Any?

    func play(bookId: Int, chapter: Int, translation: Translation) {
        guard let url = audioURL(bookId: bookId, chapter: chapter, translation: translation) else { return }
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.play()
        isPlaying = true
        observeProgress()
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        player?.play()
        isPlaying = true
    }

    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        playbackProgress = 0
    }

    /// Downloads a chapter's audio for offline playback. Returns local file URL when complete.
    func downloadForOffline(bookId: Int, chapter: Int, translation: Translation, completion: @escaping (URL?) -> Void) {
        guard let remoteURL = streamingURL(bookId: bookId, chapter: chapter, translation: translation) else {
            completion(nil); return
        }
        let localURL = localAudioURL(bookId: bookId, chapter: chapter, translation: translation)
        URLSession.shared.downloadTask(with: remoteURL) { tempURL, _, error in
            guard let tempURL, error == nil else { completion(nil); return }
            try? FileManager.default.createDirectory(at: localURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? FileManager.default.removeItem(at: localURL)
            try? FileManager.default.moveItem(at: tempURL, to: localURL)
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            var url = localURL
            try? url.setResourceValues(resourceValues)
            completion(localURL)
        }.resume()
    }

    private func audioURL(bookId: Int, chapter: Int, translation: Translation) -> URL? {
        let local = localAudioURL(bookId: bookId, chapter: chapter, translation: translation)
        if FileManager.default.fileExists(atPath: local.path) { return local }
        return streamingURL(bookId: bookId, chapter: chapter, translation: translation)
    }

    private func localAudioURL(bookId: Int, chapter: Int, translation: Translation) -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return appSupport
            .appendingPathComponent("Audio/\(translation.id)/\(bookId)/\(chapter).m4a")
    }

    private func streamingURL(bookId: Int, chapter: Int, translation: Translation) -> URL? {
        // Wire this up to your chosen audio provider (e.g. Faith Comes By Hearing / bible.is) —
        // see docs/DATA_SOURCES.md for licensing considerations.
        nil
    }

    private func observeProgress() {
        guard let player else { return }
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self, let duration = player.currentItem?.duration.seconds, duration.isFinite, duration > 0 else { return }
            self.playbackProgress = time.seconds / duration
        }
    }
}
