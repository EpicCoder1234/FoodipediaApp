import SwiftUI

struct IngredientSelectionView: View {
    @ObservedObject var viewModel = IngredientViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.ingredients.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category)) {
                        ForEach(viewModel.ingredients[category] ?? []) { ingredient in
                            MultipleSelectionRow(ingredient: ingredient, isSelected: self.viewModel.selectedIngredients.contains(where: { $0.id == ingredient.id })) {
                                if self.viewModel.selectedIngredients.contains(where: { $0.id == ingredient.id }) {
                                    self.viewModel.selectedIngredients.removeAll(where: { $0.id == ingredient.id })
                                } else {
                                    self.viewModel.selectedIngredients.append(ingredient)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Select Ingredients")
            .navigationBarItems(trailing: Button(action: {
                self.viewModel.fetchRecipes { result in
                    switch result {
                    case .success(let recipes):
                        // Handle displaying recipes
                        print("Recipes: \(recipes)")
                    case .failure(let error):
                        print("Error fetching recipes: \(error)")
                    }
                }
            }) {
                Text("Find Recipes")
            })
        }
    }
}

struct MultipleSelectionRow: View {
    var ingredient: Ingredient
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.ingredient.name)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

struct Recipe: Codable {
    let id: Int
    let title: String
    let image: String
}
