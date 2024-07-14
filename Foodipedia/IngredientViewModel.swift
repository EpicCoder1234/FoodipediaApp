import Foundation
import Combine

class IngredientViewModel: ObservableObject {
    @Published var ingredients: [String: [Ingredient]] = [:]
    @Published var selectedIngredients: [Ingredient] = []
    
    init() {
        fetchIngredients()
    }
    
    func fetchIngredients() {
        NetworkManager.shared.fetchIngredients { result in
            switch result {
            case .success(let ingredients):
                DispatchQueue.main.async {
                    self.ingredients = ingredients
                }
            case .failure(let error):
                print("Error fetching ingredients: \(error)")
            }
        }
    }
    
    func fetchRecipes(completion: @escaping (Result<[Recipe], Error>) -> Void) {
        let ingredientNames = selectedIngredients.map { $0.name }
        NetworkManager.shared.fetchRecipes(ingredients: ingredientNames, completion: completion)
    }
}
