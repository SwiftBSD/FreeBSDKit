import Capsicum
import Glibc

do {
    print("Testing sanbox.")
    // Verify starting state
    let before = try Capsicum.status()
    if before {
        fputs("Already in capability mode\n", stderr)
        exit(2)
    }

    // Enter capability mode
    try Capsicum.enter()

    // Verify final state
    let after = try Capsicum.status()
    if !after {
        fputs("Failed to enter capability mode\n", stderr)
        exit(3)
    }
    print("End sandbox testing.")
    // Success
    exit(0)

} catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}
