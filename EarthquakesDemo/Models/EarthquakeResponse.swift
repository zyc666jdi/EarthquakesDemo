import Foundation

// MARK: GeoJSON response
struct EarthquakeCollection: Decodable {
    let features: [EarthquakeFeature]
}

struct EarthquakeFeature: Decodable {
    let id: String
    let properties: EarthquakeProperties
    let geometry: EarthquakeGeometry
    var longitude: Double { geometry.coordinates[0] }
    var latitude: Double { geometry.coordinates[1] }
    var depthKm: Double { geometry.coordinates[2] }
}

// MARK: - Properties
struct EarthquakeProperties: Decodable {
    let mag: Double
    let place: String
    let time: Int64
    let alert: String?
    let tsunami: Int

    // MARK: Derived
    var date: Date {
        Date(timeIntervalSince1970: Double(time) / 1_000)
    }
}

// MARK: - Geometry
struct EarthquakeGeometry: Decodable {
    let coordinates: [Double]
}
