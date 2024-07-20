import SwiftUI

struct SignUpView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var successMessage = ""
    
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
                    .padding(.bottom, 40)
                
                if successMessage.isEmpty {
                    // Username text field
                    TextField("Username", text: $username)
                        .frame(width: 300, height: 25) // Adjust width and height as needed

                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white) // Change the foreground color to black or another contrasting color
                        .cornerRadius(5.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5.0)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )

                    SecureField("Password", text: $password)
                        .frame(width: 300, height: 25) // Adjust width and height as needed

                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white) // Change the foreground color to black or another contrasting color
                        .cornerRadius(5.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5.0)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )

                    // Sign-up button
                    Button(action: signUp) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10.0)
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
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
        }
    }
    
    func signUp() {
        guard let url = URL(string: "https://foodipedia.onrender.com/signup") else { return }
        
        let credentials = ["username": username, "password": password]
        
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

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

extension View {
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
