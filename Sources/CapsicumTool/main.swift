import Capsicum

print("BEGIN *************************")
print("Capability status: \(try! Capsicum.status())")
let _ = try! Capsicum.enter()
print("Capability status: \(try! Capsicum.status())")
print("END *************************")