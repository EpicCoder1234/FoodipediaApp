import SwiftUI

struct SignUpView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var selectedDietaryRestrictions: Set<String> = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var successMessage = ""
    @State private var showPassword = false // State for toggling password visibility
    
    let dietaryRestrictions = ["Gluten-Free", "Vegan", "Vegetarian", "Keto", "Paleo", "Nut Allergy", "Dairy-Free", "Shellfish Allergy", "Soy Allergy", "Egg Allergy"]

    var body: some View {
        ZStack {
            // Background color
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            // Background image with gradient overlay
            Image("food_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .overlay(Color.black.opacity(0.5))
                .opacity(0.2)
            
            VStack {
                // Title
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                    .transition(.scale) // Animation transition
                
                if successMessage.isEmpty {
                    Group {
                        // Username section
                        Text("Username")
                            .font(.headline)
                            .foregroundColor(.white)
                        TextField("Enter your username", text: $username)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: 25) // Adjusted width
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(5.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5.0)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                            .padding(.bottom, 10)
                            .transition(.slide) // Animation transition

                        // Password section
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(.white)
                        HStack {
                            if showPassword {
                                TextField("Enter your password", text: $password)
                                    .foregroundColor(.white)
                            } else {
                                SecureField("Enter your password", text: $password)
                                    .foregroundColor(.white)
                            }
                            Button(action: {
                                self.showPassword.toggle()
                            }) {
                                Image(systemName: self.showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 25) // Adjusted width
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(5.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5.0)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.bottom, 10)
                        .transition(.slide) // Animation transition

                        // Dietary preferences section
                        Text("Dietary Preferences")
                            .font(.headline)
                            .foregroundColor(.white)
                        ScrollView {
                            VStack {
                                ForEach(dietaryRestrictions, id: \.self) { restriction in
                                    MultipleSelectionRow(title: restriction, isSelected: selectedDietaryRestrictions.contains(restriction)) {
                                        if selectedDietaryRestrictions.contains(restriction) {
                                            selectedDietaryRestrictions.remove(restriction)
                                        } else {
                                            selectedDietaryRestrictions.insert(restriction)
                                        }
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.8) // Adjust the width to fit the screen
                                }
                            }
                        }
                        .frame(maxHeight: 200) // Limit the height of the list
                        .padding(.bottom, 10)
                        .transition(.slide) // Animation transition
                    }
                    .padding(.horizontal, 20) // Add horizontal padding to adjust layout

                    // Sign-up button
                    Button(action: signUp) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10.0)
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                            .transition(.opacity) // Animation transition
                    }
                    .padding(.top, 20)
                } else {
                    // Success message
                    Text(successMessage)
                        .foregroundColor(.white)
                        .padding()
                    
                    // Navigation to sign-in view
                    NavigationLink(destination: SignInView()) {
                        Text("Go to Sign In")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10.0)
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                }
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .animation(.default) // Apply default animation
        }
    }
    
    func signUp() {
        guard let url = URL(string: "https://foodipedia.onrender.com/signup") else { return }
        
        let dietaryLimitations = selectedDietaryRestrictions.joined(separator: ", ")
        let credentials = ["username": username, "password": password, "dietary_limitations": dietaryLimitations] // Include dietary limitations
        
        do {
            let body = try JSONEncoder().encode(credentials)
            
            NetworkManager.shared.postRequest(url: url, body: body) { result in
                switch result {
                case .success(let data):
                    if let response = String(data: data, encoding: .utf8), response.contains("User already exists") {
                        DispatchQueue.main.async {
                            self.alertMessage = "User already exists."
                            self.showAlert = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.successMessage = "User registered successfully."
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                }
            }
        } catch {
            self.alertMessage = "Error encoding credentials."
            self.showAlert = true
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(5.0)
            .overlay(
                RoundedRectangle(cornerRadius: 5.0)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
