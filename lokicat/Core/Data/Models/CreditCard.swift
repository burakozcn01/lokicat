import Foundation

struct CreditCard: VaultItem {
    let id: UUID
    var title: String
    let createdAt: Date
    var modifiedAt: Date
    var isFavorite: Bool
    var categoryId: UUID?
    var tags: [UUID]

    var cardholderName: String
    var cardNumber: String
    var expirationMonth: Int
    var expirationYear: Int
    var cvv: String
    var pin: String?
    var notes: String?

    var type: VaultItemType { .creditCard }

    init(
        id: UUID = UUID(),
        title: String,
        cardholderName: String,
        cardNumber: String,
        expirationMonth: Int,
        expirationYear: Int,
        cvv: String,
        pin: String? = nil,
        notes: String? = nil,
        categoryId: UUID? = nil,
        tags: [UUID] = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.cardholderName = cardholderName
        self.cardNumber = cardNumber
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.cvv = cvv
        self.pin = pin
        self.notes = notes
        self.categoryId = categoryId
        self.tags = tags
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
}

extension CreditCard {
    var maskedCardNumber: String {
        guard cardNumber.count >= 4 else { return cardNumber }
        let lastFour = cardNumber.suffix(4)
        return "•••• \(lastFour)"
    }

    var cardType: CardType {
        guard let firstDigit = cardNumber.first else { return .unknown }
        switch firstDigit {
        case "4": return .visa
        case "5": return .mastercard
        case "3": return .amex
        case "6": return .discover
        default: return .unknown
        }
    }

    var expirationDate: String {
        String(format: "%02d/%d", expirationMonth, expirationYear)
    }

    var isExpired: Bool {
        let now = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        if expirationYear < currentYear {
            return true
        }
        if expirationYear == currentYear && expirationMonth < currentMonth {
            return true
        }
        return false
    }

    var searchableContent: String {
        [title, cardholderName, maskedCardNumber, notes]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()
    }
}

enum CardType: String {
    case visa = "Visa"
    case mastercard = "Mastercard"
    case amex = "American Express"
    case discover = "Discover"
    case unknown = "Unknown"

    var iconName: String {
        switch self {
        case .visa: return "creditcard.fill"
        case .mastercard: return "creditcard.fill"
        case .amex: return "creditcard.fill"
        case .discover: return "creditcard.fill"
        case .unknown: return "creditcard"
        }
    }
}
