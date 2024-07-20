import SwiftUI

struct FoodieTestView: View {
    @State private var foodChoices: [FoodChoice] = []
    @State private var selectedFood: FoodChoice?
    @State private var wave = 1
    @State private var alertMessage = ""
    @State private var hasPreferences = false
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            Image("food_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.3)
            
            VStack {
                if hasPreferences {
                    NavigationLink(destination: IngredientSelectionView(), isActive: $hasPreferences) {
                        EmptyView()
                    }
                } else if wave == 15 {
                    Text("You have completed all waves!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                    NavigationLink(destination: IngredientSelectionView()) {
                        Text("Go to Recipe Page")
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                } else if !foodChoices.isEmpty {
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Food Personality Test")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding()
                            ForEach(foodChoices, id: \.self) { food in
                                VStack {
                                    if let url = URL(string: food.image) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                 .aspectRatio(contentMode: .fill)
                                                 .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.width * 0.3)
                                                 .clipShape(RoundedRectangle(cornerRadius: 10))
                                                 .shadow(radius: 5)
                                                 .onTapGesture {
                                                     self.selectedFood = food
                                                     self.storeChoice(food: food)
                                                 }
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.6)
                                        }
                                    }
                                    Text(food.title)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.top, 5)
                                }
                                .padding(.horizontal, 8)
                            }
                        }
                    }
                } else {
                    Text("Loading food choices...")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .alert(isPresented: .constant(!alertMessage.isEmpty)) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear(perform: fetchFoodChoices)
    }
    
    func fetchFoodChoices() {
        guard let url = URL(string: "https://foodipedia.onrender.com/random_food_choices?wave=\(wave)") else { return }
        
        NetworkManager.shared.getRequest(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(FoodieTestResponse.self, from: data)
                    DispatchQueue.main.async {
                        if response.message == "User already has preferences" {
                            self.hasPreferences = true
                        } else {
                            self.foodChoices = response.choices
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.alertMessage = "Error decoding response."
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.alertMessage = error.localizedDescription
                }
            }
        }
    }
    

    func storeChoice(food: FoodChoice) {
        guard let url = URL(string: "https://foodipedia.onrender.com/store_choice") else { return }
        
        let choice = ["selected_food": food]
        
        do {
            let body = try JSONEncoder().encode(choice)
            
            NetworkManager.shared.postRequest(url: url, body: body) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        if self.wave < 15 {
                            self.wave += 1
                            self.fetchFoodChoices()
                        } else {
                            self.foodChoices = []
                        }
                    }

                case .failure(let error):
                    DispatchQueue.main.async {
                        self.alertMessage = error.localizedDescription
                    }
                }
            }
        } catch {
            self.alertMessage = "Error encoding choice."
        }
    }
}

struct FoodieTestView_Previews: PreviewProvider {
    static var previews: some View {
        FoodieTestView()
    }
}
