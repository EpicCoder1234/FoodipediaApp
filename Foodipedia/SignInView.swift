import SwiftUI

struct SignInView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToTest = false
    
    var body: some View {
        NavigationView {
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
                    Text("Welcome to Foodipedia")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                    
                    // Username text field
                    TextField("Username", text: $username)
                        .frame(width: 300, height: 25) // Adjust width and height as needed

                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(5.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5.0)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                    
                    // Password secure field
                    SecureField("Password", text: $password)
                        .frame(width: 300, height: 25) // Adjust width and height as needed

                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(5.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5.0)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                    
                    // Sign-in button
                    Button(action: signIn) {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10.0)
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, 20)
                    
                    // Navigation link to the next view
                    NavigationLink(destination: FoodieTestView(), isActive: $navigateToTest) {
                        EmptyView()
                    }
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    
    func signIn() {
        guard let url = URL(string: "https://foodipedia.onrender.com/signin") else { return }
        
        let credentials = ["username": username, "password": password]
        
        do {
            let body = try JSONEncoder().encode(credentials)
            
            NetworkManager.shared.postRequest(url: url, body: body) { result in
                switch result {
                case .success(let data):
                    switch NetworkManager.shared.decodeResponse(SignInResponse.self, from: data) {
                    case .success(let response):
                        UserDefaults.standard.set(response.access_token, forKey: "access_token")
                        DispatchQueue.main.async {
                            self.navigateToTest = true
                        }
                    case .failure:
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
        } catch {
            self.alertMessage = "Error encoding credentials."
            self.showAlert = true
        }
    }
}

struct SignInResponse: Codable {
    let access_token: String
    
    enum CodingKeys: String, CodingKey {
        case access_token = "access_token"
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
