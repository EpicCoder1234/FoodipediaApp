import SwiftUI

struct SignInView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToTest = false
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            
            Button(action: signIn) {
                Text("Sign In")
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10.0)
            }
            
            NavigationLink(destination: FoodieTestView(), isActive: $navigateToTest) {
                EmptyView()
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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
