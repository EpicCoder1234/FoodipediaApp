import SwiftUI

struct FoodieTestView: View {
    @State private var foodChoices: [FoodChoice] = []
    @State private var selectedFood: FoodChoice?
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            if !foodChoices.isEmpty {
                List(foodChoices) { food in
                    HStack {
                        Text(food.title)
                        Spacer()
                        Button(action: {
                            self.selectedFood = food
                            self.storeChoice(food: food)
                        }) {
                            Text("Select")
                        }
                    }
                }
            } else {
                Text("Loading food choices...")
            }
        }
        .onAppear(perform: fetchFoodChoices)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func fetchFoodChoices() {
        guard let url = URL(string: "http://127.0.0.1:5000/random_food_choices") else { return }
        
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
                            self.showAlert = true
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
            }
        }
    }
    
    func storeChoice(food: FoodChoice) {
        guard let url = URL(string: "http://127.0.0.l:5000/store_choice") else { return }
        
        let choice = ["selected_food": food]
        
        do {
            let body = try JSONEncoder().encode(choice)
            
            NetworkManager.shared.postRequest(url: url, body: body) { result in
                switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.alertMessage = "Choice stored successfully."
                            self.showAlert = true
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.alertMessage = error.localizedDescription
                            self.showAlert = true
                        }
                }
            }
        } catch {
            self.alertMessage = "Error encoding choice."
            self.showAlert = true
        }
    }
}

struct FoodieTestView_Previews: PreviewProvider {
    static var previews: some View {
        FoodieTestView()
    }
}
