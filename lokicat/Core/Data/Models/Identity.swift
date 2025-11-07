import Foundation

struct Identity: VaultItem {
    let id: UUID
    var title: String
    let createdAt: Date
    var modifiedAt: Date
    var isFavorite: Bool
    var categoryId: UUID?
    var tags: [UUID]

    var firstName: String
    var lastName: String
    var middleName: String?
    var dateOfBirth: Date?
    var gender: Gender?
    var nationality: String?

    var identityType: IdentityType
    var identityNumber: String
    var issuingCountry: String?
    var issueDate: Date?
    var expiryDate: Date?

    var address: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?

    var phoneNumber: String?
    var email: String?
    var notes: String?

    var type: VaultItemType { .identity }

    init(
        id: UUID = UUID(),
        title: String,
        firstName: String,
        lastName: String,
        middleName: String? = nil,
        dateOfBirth: Date? = nil,
        gender: Gender? = nil,
        nationality: String? = nil,
        identityType: IdentityType,
        identityNumber: String,
        issuingCountry: String? = nil,
        issueDate: Date? = nil,
        expiryDate: Date? = nil,
        address: String? = nil,
        city: String? = nil,
        state: String? = nil,
        postalCode: String? = nil,
        country: String? = nil,
        phoneNumber: String? = nil,
        email: String? = nil,
        notes: String? = nil,
        categoryId: UUID? = nil,
        tags: [UUID] = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.nationality = nationality
        self.identityType = identityType
        self.identityNumber = identityNumber
        self.issuingCountry = issuingCountry
        self.issueDate = issueDate
        self.expiryDate = expiryDate
        self.address = address
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
        self.phoneNumber = phoneNumber
        self.email = email
        self.notes = notes
        self.categoryId = categoryId
        self.tags = tags
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}

enum IdentityType: String, Codable, CaseIterable {
    case passport = "Passport"
    case driverLicense = "Driver's License"
    case nationalId = "National ID"
    case other = "Other"
}

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

extension Identity {
    var fullName: String {
        [firstName, middleName, lastName]
            .compactMap { $0 }
            .joined(separator: " ")
    }

    var isExpired: Bool {
        guard let expiryDate = expiryDate else { return false }
        return expiryDate < Date()
    }

    var searchableContent: String {
        [title, fullName, identityNumber, phoneNumber, email, notes]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()
    }
}
