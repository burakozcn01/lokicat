import Foundation
import SwiftUI

struct Category: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var color: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "folder.fill",
        color: String = "blue"
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.createdAt = Date()
    }
}

extension Category {
    static let defaultCategories: [Category] = [
        Category(name: "Personal", icon: "person.fill", color: "blue"),
        Category(name: "Work", icon: "briefcase.fill", color: "purple"),
        Category(name: "Finance", icon: "dollarsign.circle.fill", color: "green"),
        Category(name: "Social", icon: "bubble.left.and.bubble.right.fill", color: "pink")
    ]
}
