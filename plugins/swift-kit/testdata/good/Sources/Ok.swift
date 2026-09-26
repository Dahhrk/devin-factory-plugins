// Good fixture: optional bind, documented allow.

func firstOk(_ values: [String?]) -> String? {
    guard let first = values.first else { return nil }
    return first ?? "missing"
}

func tryOk(_ raw: String) throws -> Int {
    guard let value = Int(raw) else {
        throw NSError(domain: "fixture", code: 1)
    }
    return value
}

// Documented intentional seam (boot probe); keep allow on the smell line.
func documentedLegacy(_ value: String?) -> String {
    return value!  // swift-rg-allow: fixture documents allow marker for intentional force unwrap seam
}
