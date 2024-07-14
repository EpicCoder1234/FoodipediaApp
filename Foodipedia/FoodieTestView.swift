import SwiftUI

struct FoodieTestView: View {
    @State private var foodChoices: [FoodChoice] = []
    @State private var selectedFood: FoodChoice?
    @State private var wave = 1
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            Image("food_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.3)

            VStack {
                if wave == 15 {
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
                        ForEach(foodChoices, id: \.id) { food in
                            VStack {
                                if let url = URL(string: food.image) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                             .aspectRatio(contentMode: .fill)
                                             .frame(width: 300, height: 300)
                                             .clipShape(RoundedRectangle(cornerRadius: 10))
                                             .shadow(radius: 5)
                                             .onTapGesture {
                                                 self.selectedFood = food
                                                 self.storeChoice(food: food)
                                             }
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 300, height: 300)
                                    }
                                }
                                Text(food.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.top, 5)
                            }
                            .padding(.vertical, 10)
                        }
                    }
                } else {
                    Text("Loading food choices...")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
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
                            self.foodChoices = response.choices
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
