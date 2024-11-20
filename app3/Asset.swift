import Foundation

struct Asset: Identifiable {
    let id: UUID
    let name: String
    let amount: Double
    let date: Date
    
    init(name: String, amount: Double) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.date = Date()
    }
}

// 添加貸款模型
struct Loan: Identifiable {
    let id: UUID
    var name: String
    var amount: Double
    var date: Date
    
    init(name: String, amount: Double) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.date = Date()
    }
} 