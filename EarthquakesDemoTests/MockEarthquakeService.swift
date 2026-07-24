import Foundation
@testable import EarthquakesDemo

final class MockEarthquakeService: EarthquakeServiceProtocol {
    var result: Result<[EarthquakeFeature], Error> = .success([])

    func fetchEarthquakes(completion: @escaping (Result<[EarthquakeFeature], Error>) -> Void) {
        completion(result)
    }
}

// MARK: - Factory helpers
extension EarthquakeFeature {
    static func make(
        id: String = "test-id",
        mag: Double = 7.0,
        place: String = "Test Location",
        timeMs: Int64 = 1_680_000_000_000,
        tsunami: Int = 0,
        longitude: Double = 0.0,
        latitude: Double = 0.0,
        depthKm: Double = 10.0
    ) -> EarthquakeFeature {
        EarthquakeFeature(
            id: id,
            properties: EarthquakeProperties(
                mag: mag,
                place: place,
                time: timeMs,
                alert: nil,
                tsunami: tsunami
            ),
            geometry: EarthquakeGeometry(coordinates: [longitude, latitude, depthKm])
        )
    }
}
