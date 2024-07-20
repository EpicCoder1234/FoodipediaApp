import Foundation
// Define your models if they are not already defined
struct Ingredient: Identifiable, Decodable, Hashable {
    // Define the properties according to your JSON structure
    let id: UUID
    let name: String
}

struct Recipe: Identifiable, Decodable {
    let id: UUID
    let title: String
    let image: String
    let ingredients: String
    let nutrition: String
    let time: Int
    let instructions: String
}

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    @Published var ingredients: [String: [Ingredient]] = [:]
    @Published var selectedIngredients: Set<String> = []
    @Published var recipes = [Recipe]()

    init() {}
    
    func makeRequest(url: URL, method: String, body: Data? = nil, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add Authorization header
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Print the response for debugging
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
            completion(data, response, error)
        }
        task.resume()
    }
    
    func postRequest(url: URL, body: Data, completion: @escaping (Result<Data, Error>) -> Void) {
        makeRequest(url: url, method: "POST", body: body) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            }
        }
    }
    
    func getRequest(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        makeRequest(url: url, method: "GET") { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            }
        }
    }
    
    func decodeResponse<T: Decodable>(_ type: T.Type, from data: Data) -> Result<T, Error> {
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return .success(decodedData)
        } catch {
            return .failure(error)
        }
    }
    
    func fetchIngredients(completion: @escaping (Result<[String: [Ingredient]], Error>) -> Void) {
        guard let url = URL(string: "https://foodipedia.onrender.com/get_ingredients") else { return }
        getRequest(url: url) { result in
            switch result {
            case .success(let data):
                completion(self.decodeResponse([String: [Ingredient]].self, from: data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchRecipes(ingredients: String) {
        guard let url = URL(string: "https://foodipedia.onrender.com/get_recipes") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Retrieve the token from UserDefaults or your token storage mechanism
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("No token found")
            return
        }

        let parameters: [String: Any] = ["ingredients": ingredients]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            
            // Check for 401 Unauthorized status code
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                DispatchQueue.main.async {
                    print("Unauthorized: Invalid or missing token")
                    // Handle the unauthorized case, e.g., prompt for login or refresh token
                }
                return
            }
            
            if let response = try? JSONDecoder().decode([Recipe].self, from: data) {
                DispatchQueue.main.async {
                    self.recipes = response
                }
            }
        }.resume()
    }

}
