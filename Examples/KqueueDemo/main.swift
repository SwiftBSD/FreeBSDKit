/*
 * Kqueue Demo
 *
 * Demonstrates the kqueue API including:
 * - EVFILT_SIGNAL: Signal handling
 * - EVFILT_TIMER: Timers
 * - EVFILT_VNODE: File monitoring
 * - EVFILT_PROC: Process monitoring
 * - EVFILT_USER: User-defined events
 */

import Capabilities
import Descriptors
import SignalDispatchers
import FreeBSDKit
import Foundation
import Glibc

@main
struct KqueueDemo {
    static func main() throws {
        let args = CommandLine.arguments
        let command = args.count > 1 ? args[1] : "help"

        switch command {
        case "signal":
            try signalDemo()
        case "timer":
            try timerDemo()
        case "file":
            try fileDemo()
        case "proc":
            try procDemo()
        case "user":
            try userDemo()
        case "all":
            try allDemo()
        case "help", "-h", "--help":
            printHelp()
        default:
            print("Unknown command: \(command)")
            printHelp()
        }
    }

    static func printHelp() {
        print("""
        Kqueue Demo - FreeBSDKit Kqueue API Demonstration

        Usage: kqueue-demo <command>

        Commands:
          signal    Demonstrate EVFILT_SIGNAL (signal handling)
          timer     Demonstrate EVFILT_TIMER (timers)
          file      Demonstrate EVFILT_VNODE (file monitoring)
          proc      Demonstrate EVFILT_PROC (process monitoring)
          user      Demonstrate EVFILT_USER (user-defined events)
          all       Run all demonstrations
          help      Show this help message

        Examples:
          swift run kqueue-demo signal
          swift run kqueue-demo timer
          swift run kqueue-demo file
        """)
    }

    // MARK: - Signal Demo

    static func signalDemo() throws {
        let pid = getpid()

        print("=== EVFILT_SIGNAL Demo ===")
        print("PID: \(pid)")
        print()
        print("From another terminal, send signals with:")
        print("  kill -USR1 \(pid)")
        print("  kill -USR2 \(pid)")
        print("  kill -INT \(pid)  (to exit)")
        print()

        // Block signals
        try KqueueCapability.blockSignals([.usr1, .usr2, .int])

        // Create kqueue and register signals
        let kq = try KqueueCapability.makeKqueue()
        try kq.register(KEvent.signal(.usr1))
        try kq.register(KEvent.signal(.usr2))
        try kq.register(KEvent.signal(.int))

        print("Waiting for signals...")
        print(String(repeating: "-", count: 50))

        var running = true
        while running {
            let results = try kq.wait(maxEvents: 8)

            for result in results {
                switch result {
                case .signal(let sig, let count, _):
                    let ts = ISO8601DateFormatter().string(from: Date())
                    print("[\(ts)] \(sig) (count: \(count))")
                    if sig == .int {
                        running = false
                    }
                default:
                    print("Unexpected event: \(result)")
                }
            }
        }

        print("\nSignal demo complete.")
    }

    // MARK: - Timer Demo

    static func timerDemo() throws {
        print("=== EVFILT_TIMER Demo ===")
        print()

        let kq = try KqueueCapability.makeKqueue()

        // Add a repeating timer (every 500ms)
        try kq.addTimer(id: 1, interval: 500, unit: .milliseconds)
        print("Added repeating timer (500ms interval)")

        // Add a one-shot timer (fires once after 2 seconds)
        try kq.addOneshotTimer(id: 2, timeout: 2, unit: .seconds)
        print("Added one-shot timer (2 second delay)")

        print()
        print("Waiting for timer events...")
        print(String(repeating: "-", count: 50))

        var repeatingCount = 0
        var oneshotFired = false

        while repeatingCount < 10 || !oneshotFired {
            let results = try kq.wait(maxEvents: 8, timeout: 5.0)

            if results.isEmpty {
                print("Timeout - no events")
                break
            }

            for result in results {
                switch result {
                case .timer(let id, let expirations, _):
                    let ts = ISO8601DateFormatter().string(from: Date())
                    if id == 1 {
                        repeatingCount += 1
                        print("[\(ts)] Repeating timer fired (count: \(repeatingCount), expirations: \(expirations))")
                    } else if id == 2 {
                        oneshotFired = true
                        print("[\(ts)] One-shot timer fired!")
                    }
                default:
                    print("Unexpected event: \(result)")
                }
            }
        }

        try kq.cancelTimer(id: 1)
        print("\nTimer demo complete.")
    }

    // MARK: - File Demo

    static func fileDemo() throws {
        print("=== EVFILT_VNODE Demo ===")
        print()

        let testFile = "/tmp/kqueue_test_\(getpid()).txt"

        // Create test file
        FileManager.default.createFile(atPath: testFile, contents: nil)
        defer { try? FileManager.default.removeItem(atPath: testFile) }

        print("Created test file: \(testFile)")
        print()
        print("From another terminal, modify the file:")
        print("  echo 'hello' >> \(testFile)")
        print("  touch \(testFile)")
        print("  rm \(testFile)  (to exit)")
        print()

        // Open the file
        let fd = open(testFile, O_RDONLY)
        guard fd >= 0 else {
            print("Failed to open file")
            return
        }
        defer { close(fd) }

        // Create kqueue and watch the file
        let kq = try KqueueCapability.makeKqueue()
        try kq.watchFile(fd, events: .all)

        print("Watching for file events...")
        print(String(repeating: "-", count: 50))

        var running = true
        while running {
            let results = try kq.wait(maxEvents: 8, timeout: 30.0)

            if results.isEmpty {
                print("Timeout - no events in 30 seconds")
                break
            }

            for result in results {
                switch result {
                case .vnode(_, let events, _):
                    let ts = ISO8601DateFormatter().string(from: Date())
                    print("[\(ts)] File event: \(events)")
                    if events.contains(.delete) {
                        print("File deleted, exiting...")
                        running = false
                    }
                default:
                    print("Unexpected event: \(result)")
                }
            }
        }

        print("\nFile demo complete.")
    }

    // MARK: - Process Demo

    static func procDemo() throws {
        print("=== EVFILT_PROC Demo ===")
        print()

        let kq = try KqueueCapability.makeKqueue()

        // Fork a child process
        print("Forking child process...")
        let childPid = fork()

        if childPid == 0 {
            // Child process
            sleep(1)
            print("  [child] Exiting with code 0...")
            exit(0)
        }

        guard childPid > 0 else {
            print("Fork failed")
            return
        }

        print("Child PID: \(childPid)")

        // Watch the child process
        try kq.watchProcess(childPid, events: [.exit, .exec])

        print("Watching child process...")
        print(String(repeating: "-", count: 50))

        var exited = false
        while !exited {
            let results = try kq.wait(maxEvents: 8, timeout: 10.0)

            if results.isEmpty {
                print("Timeout - child didn't exit?")
                break
            }

            for result in results {
                switch result {
                case .process(let pid, let events, let status, _):
                    let ts = ISO8601DateFormatter().string(from: Date())
                    print("[\(ts)] Process \(pid): \(events)")

                    if events.contains(.exit), let status = status {
                        if ProcessEvents.exitedNormally(status) {
                            let code = ProcessEvents.exitCode(status) ?? -1
                            print("  Exit code: \(code)")
                        } else if ProcessEvents.wasSignaled(status) {
                            let sig = ProcessEvents.termSignal(status) ?? -1
                            print("  Killed by signal: \(sig)")
                        }
                        exited = true
                    }
                default:
                    print("Unexpected event: \(result)")
                }
            }
        }

        // Reap the child
        var status: Int32 = 0
        waitpid(childPid, &status, 0)

        print("\nProcess demo complete.")
    }

    // MARK: - User Event Demo

    static func userDemo() throws {
        print("=== EVFILT_USER Demo ===")
        print()

        let kq = try KqueueCapability.makeKqueue()

        // Add a user event
        try kq.addUserEvent(id: 42)
        print("Added user event with id: 42")

        // Check that no event is pending yet
        let initial = try kq.wait(maxEvents: 8, timeout: 0.1)
        print("Initial check: \(initial.count) events (should be 0)")

        // Trigger the event
        print("Triggering user event...")
        try kq.triggerUserEvent(id: 42)

        // Now we should see the event
        let results = try kq.wait(maxEvents: 8, timeout: 1.0)
        print("After trigger: \(results.count) event(s)")

        for result in results {
            switch result {
            case .user(let id, let fflags, _):
                print("  User event id=\(id), fflags=0x\(String(fflags, radix: 16))")
            default:
                print("  Unexpected: \(result)")
            }
        }

        // Clean up
        try kq.removeUserEvent(id: 42)

        print("\nUser event demo complete.")
    }

    // MARK: - All Demos

    static func allDemo() throws {
        print("Running all demos (non-interactive versions)...\n")

        // Timer demo (short version)
        print("=== Timer Demo (short) ===")
        let kq = try KqueueCapability.makeKqueue()
        try kq.addTimer(id: 1, interval: 100, unit: .milliseconds)
        try kq.addOneshotTimer(id: 2, timeout: 250, unit: .milliseconds)

        for _ in 0..<5 {
            let results = try kq.wait(maxEvents: 8, timeout: 1.0)
            for result in results {
                print("  \(result)")
            }
        }
        try kq.cancelTimer(id: 1)
        print()

        // User event demo
        print("=== User Event Demo ===")
        try kq.addUserEvent(id: 100)
        try kq.triggerUserEvent(id: 100)
        let userResults = try kq.wait(maxEvents: 8, timeout: 0.1)
        for result in userResults {
            print("  \(result)")
        }
        try kq.removeUserEvent(id: 100)
        print()

        // Process demo
        print("=== Process Demo ===")
        fflush(stdout)
        let childPid = fork()
        if childPid == 0 {
            // Child: just exit silently
            _exit(42)
        }
        try kq.watchProcess(childPid, events: .exit)
        let procResults = try kq.wait(maxEvents: 8, timeout: 1.0)
        for result in procResults {
            print("  \(result)")
        }
        var status: Int32 = 0
        waitpid(childPid, &status, 0)
        print()

        print("All demos complete!")
    }
}
