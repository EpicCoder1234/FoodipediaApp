import SwiftUI

struct IngredientSelectionView: View {
    @State private var ingredientText: String = ""
    @ObservedObject var networkManager = NetworkManager()

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                TextField("Enter ingredients separated by commas", text: $ingredientText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    self.networkManager.fetchRecipes(ingredients: self.ingredientText)
                }) {
                    Text("Find Recipes")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                // Recipe Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(networkManager.recipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                RecipeBlockView(recipe: recipe)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Ingredient Search")
        }
    }
}

struct RecipeBlockView: View {
    let recipe: Recipe

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: recipe.image)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipped()
            } placeholder: {
                ProgressView()
            }
            Text(recipe.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.top, 5)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                AsyncImage(url: URL(string: recipe.image)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: 250)
                        .clipped()
                } placeholder: {
                    ProgressView()
                }

                Text("Ingredients")
                    .font(.headline)
                Text(recipe.ingredients)

                Text("Nutrition")
                    .font(.headline)
                Text(recipe.nutrition)

                Text("Time to make: \(recipe.time) minutes")
                    .font(.headline)

                Text("Instructions")
                    .font(.headline)
                Text(recipe.instructions)
            }
            .padding()
        }
        .navigationTitle(recipe.title)
    }
}

struct IngredientSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientSelectionView()
    }
}
