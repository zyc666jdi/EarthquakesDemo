import Foundation

// MARK: - Protocol
// Abstracts the network layer so the ViewModel (and tests) can swap implementations.
protocol EarthquakeServiceProtocol {
    // Fetches the earthquake list
    func fetchEarthquakes(completion: @escaping (Result<[EarthquakeFeature], Error>) -> Void)
}

// MARK: - Errors
enum EarthquakeServiceError: LocalizedError {
    case noData

    var errorDescription: String? {
        switch self {
        case .noData: return "The server returned an empty response."
        }
    }
}

// MARK: - Live implementation
final class EarthquakeService: EarthquakeServiceProtocol {
    // Injecting URLSession makes the network layer mockable in integration tests.
    private let session: URLSession

    private static let apiURL: URL = {
        var components = URLComponents(string: "https://earthquake.usgs.gov/fdsnws/event/1/query")!
        components.queryItems = [
            URLQueryItem(name: "format",       value: "geojson"),
            URLQueryItem(name: "starttime",    value: "2023-01-01"),
            URLQueryItem(name: "endtime",      value: "2024-01-01"),
            URLQueryItem(name: "minmagnitude", value: "7"),
        ]
        return components.url!
    }()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchEarthquakes(completion: @escaping (Result<[EarthquakeFeature], Error>) -> Void) {
        // Skip the URL cache so the list always reflects server state.
        var request = URLRequest(url: Self.apiURL)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        session.dataTask(with: request) { data, _, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let data else {
                completion(.failure(EarthquakeServiceError.noData))
                return
            }
            do {
                let collection = try JSONDecoder().decode(EarthquakeCollection.self, from: data)
                completion(.success(collection.features))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
