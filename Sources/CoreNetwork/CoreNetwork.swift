// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

protocol JsonDecoder {
    func decode<Model: Decodable>(data: Data, modelType: Model.Type)async throws -> Model
}

extension JsonDecoder {
    func decode<Model: Decodable>(data: Data, modelType: Model.Type)async throws -> Model {
        
        let jsonDeocder = JSONDecoder()
        return try jsonDeocder.decode(modelType.self, from: data)
    }
}


enum NetworkingErrors: Error {
    case invalidUrl(String)
    case invalidResponse(String)
    case dataError
}

protocol Networking {
    func getData(urlPath: String) async throws -> Data
}

public struct NetworkManager: Networking, JsonDecoder {
    static let apiUrl = "https://api.themoviedb.org/3/movie/now_playing?api_key=757e85be4b3665dab13c9c7588bb99c0"
    
    public init(){}
    
    func getData(urlPath: String) async throws -> Data {
        
        guard let url = URL(string: urlPath) else {
            throw NetworkingErrors.invalidUrl("The url path entered is not valid.")
        }
        
        let data = try await URLSession.shared.data(from: url)
        let response = data.1 as? HTTPURLResponse
        guard let _response = response , (200...299).contains(_response.statusCode) else {
            throw NetworkingErrors.invalidResponse("Url session returned with response: \(response?.statusCode ?? 0)")
        }
        
        return data.0
    }

    
    public func get<Model: Decodable>(model: Model.Type)async throws-> Model {
        let data = try await getData(urlPath: "https://api.themoviedb.org/3/movie/now_playing?api_key=757e85be4b3665dab13c9c7588bb99c0")
        
          return try await decode(data: data, modelType: model.self)
    }
}
