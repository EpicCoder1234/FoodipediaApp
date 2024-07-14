import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
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
    
    func fetchRecipes(ingredients: [String], completion: @escaping (Result<[Recipe], Error>) -> Void) {
        guard let url = URL(string: "https://foodipedia.onrender.com/get_recipes") else { return }
        let body: [String: Any] = ["ingredients": ingredients]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        
        postRequest(url: url, body: jsonData!) { result in
            switch result {
            case .success(let data):
                completion(self.decodeResponse([Recipe].self, from: data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
