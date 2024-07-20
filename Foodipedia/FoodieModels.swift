import Foundation

struct FoodChoice: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let image: String
    let cuisine: [String]
}

struct UserChoice: Codable {
    let id: Int
    let user_id: Int
    let food_id: Int
    let food_title: String
    let food_image: String
    let cuisine: [String]
    let wave_number: Int
}

struct FoodieTestResponse: Codable {
    let wave: Int
    let message: String?
    let choices: [FoodChoice]
}


