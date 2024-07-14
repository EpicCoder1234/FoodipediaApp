import Foundation

struct FoodChoice: Codable, Identifiable {
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
}

struct FoodieTestResponse: Codable {
    let wave: Int
    let choices: [FoodChoice]
}

struct Ingredient: Codable, Identifiable {
    let id: Int
    let name: String
}
