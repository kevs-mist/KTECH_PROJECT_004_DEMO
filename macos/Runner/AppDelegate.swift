import Cocoa
import FlutterMacOS
import Darwin

@main
class AppDelegate: FlutterAppDelegate {
  // Keep the lock open for the process lifetime. All app instances sharing
  // this sandbox also share the registry, which is saved as a whole snapshot.
  private var instanceLock: Int32 = -1

  override func applicationWillFinishLaunching(_ notification: Notification) {
    let lockPath = (NSHomeDirectory() as NSString).appendingPathComponent(".ktech-registry.lock")
    instanceLock = open(lockPath, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
    guard instanceLock >= 0 && flock(instanceLock, LOCK_EX | LOCK_NB) == 0 else {
      if instanceLock >= 0 { close(instanceLock) }
      let alert = NSAlert()
      alert.messageText = "K-TECH is already running or could not acquire its instance lock."
      alert.runModal()
      exit(EXIT_FAILURE)
    }
    super.applicationWillFinishLaunching(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
