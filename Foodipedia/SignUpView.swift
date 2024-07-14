import SwiftUI

struct SignUpView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var successMessage = ""
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            VStack {
                    Text("Sign Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                    
                    
                
                if successMessage.isEmpty {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                       
                    
                    Button(action: signUp) {
                        Text("Sign Up")
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Color.white)
                            .cornerRadius(10.0)
                            .shadow(radius: 10)
                    }
                } else {
                    Text(successMessage)
                        .foregroundColor(.white)
                        .padding()
                    
                    NavigationLink(destination: SignInView()) {
                        Text("Go to Sign In")
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Color.white)
                            .cornerRadius(10.0)
                            .shadow(radius: 10)
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
