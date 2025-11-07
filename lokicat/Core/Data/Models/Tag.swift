import Foundation

struct Tag: Identifiable, Codable {
    let id: UUID
    var name: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String
    ) {
        self.id = id
        self.name = name
        self.createdAt = Date()
    }
}
