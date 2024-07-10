import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func makeRequest(url: URL, method: String, body: Data? = nil, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
}
