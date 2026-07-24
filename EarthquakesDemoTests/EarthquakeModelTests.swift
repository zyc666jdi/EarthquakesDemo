import XCTest
@testable import EarthquakesDemo

// Tests that the Codable models parse the real USGS GeoJSON format correctly.
final class EarthquakeModelTests: XCTestCase {

    // MARK: - EarthquakeCollection decoding

    func test_decodeCollection_parsesFeatureCount() throws {
        let collection = try JSONDecoder().decode(EarthquakeCollection.self, from: sampleJSON)
        XCTAssertEqual(collection.features.count, 2)
    }

    func test_decodeFeature_parsesID() throws {
        let feature = try firstFeature()
        XCTAssertEqual(feature.id, "us7000lgwp")
    }

    func test_decodeProperties_parsesMagnitude() throws {
        let props = try firstFeature().properties
        XCTAssertEqual(props.mag, 7.1, accuracy: 0.001)
    }

    func test_decodeProperties_parsesPlace() throws {
        let props = try firstFeature().properties
        XCTAssertEqual(props.place, "118 km S of Isangel, Vanuatu")
    }

    func test_decodeProperties_convertsTimeToDate() throws {
        let props = try firstFeature().properties
        // time = 1701953790184 ms → 1701953790.184 s
        let expected = Date(timeIntervalSince1970: 1_701_953_790.184)
        XCTAssertEqual(props.date.timeIntervalSince1970, expected.timeIntervalSince1970, accuracy: 0.001)
    }

    func test_decodeProperties_parsesNullAlert() throws {
        let props = try firstFeature().properties
        // The sample has "alert": null
        XCTAssertNil(props.alert)
    }

    func test_decodeProperties_parsesTsunami() throws {
        let props = try firstFeature().properties
        XCTAssertEqual(props.tsunami, 1)
    }

    // MARK: - Geometry convenience accessors

    func test_geometry_longitude() throws {
        let feature = try firstFeature()
        XCTAssertEqual(feature.longitude, 169.3089, accuracy: 0.0001)
    }

    func test_geometry_latitude() throws {
        let feature = try firstFeature()
        XCTAssertEqual(feature.latitude, -20.6152, accuracy: 0.0001)
    }

    func test_geometry_depth() throws {
        let feature = try firstFeature()
        XCTAssertEqual(feature.depthKm, 48, accuracy: 0.1)
    }

    // MARK: - Second feature (M 7.6)

    func test_secondFeature_parsesAlert() throws {
        let collection = try JSONDecoder().decode(EarthquakeCollection.self, from: sampleJSON)
        XCTAssertNil(collection.features[1].properties.alert) // null in sample
    }

    // MARK: - Helpers

    private func firstFeature() throws -> EarthquakeFeature {
        let collection = try JSONDecoder().decode(EarthquakeCollection.self, from: sampleJSON)
        return collection.features[0]
    }

    // Minimal two-feature GeoJSON slice matching the real API shape.
    private let sampleJSON = Data("""
    {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "properties": {
            "mag": 7.1,
            "place": "118 km S of Isangel, Vanuatu",
            "time": 1701953790184,
            "updated": 1707608860040,
            "tz": null,
            "url": "https://earthquake.usgs.gov/earthquakes/eventpage/us7000lgwp",
            "detail": "https://earthquake.usgs.gov/fdsnws/event/1/query?eventid=us7000lgwp&format=geojson",
            "felt": 17,
            "cdi": 7.2,
            "mmi": 5.906,
            "alert": null,
            "status": "reviewed",
            "tsunami": 1,
            "sig": 788,
            "net": "us",
            "code": "7000lgwp",
            "ids": ",at00s5ary7,us7000lgwp,",
            "sources": ",at,us,",
            "types": ",dyfi,",
            "nst": 146,
            "dmin": 2.637,
            "rms": 1.08,
            "gap": 20,
            "magType": "mww",
            "type": "earthquake",
            "title": "M 7.1 - 118 km S of Isangel, Vanuatu"
          },
          "geometry": {
            "type": "Point",
            "coordinates": [169.3089, -20.6152, 48]
          },
          "id": "us7000lgwp"
        },
        {
          "type": "Feature",
          "properties": {
            "mag": 7.6,
            "place": "19 km E of Gamut, Philippines",
            "time": 1701527824454,
            "updated": 1777917204474,
            "tz": null,
            "url": "https://earthquake.usgs.gov/earthquakes/eventpage/us7000lff4",
            "detail": "https://earthquake.usgs.gov/fdsnws/event/1/query?eventid=us7000lff4&format=geojson",
            "felt": 599,
            "cdi": 9.1,
            "mmi": 7.184,
            "alert": null,
            "status": "reviewed",
            "tsunami": 1,
            "sig": 1434,
            "net": "us",
            "code": "7000lff4",
            "ids": ",pt23336002,us7000lff4,",
            "sources": ",pt,us,",
            "types": ",dyfi,",
            "nst": 128,
            "dmin": 1.668,
            "rms": 0.98,
            "gap": 43,
            "magType": "mww",
            "type": "earthquake",
            "title": "M 7.6 - 19 km E of Gamut, Philippines"
          },
          "geometry": {
            "type": "Point",
            "coordinates": [126.4161, 8.5266, 40]
          },
          "id": "us7000lff4"
        }
      ]
    }
    """.utf8)
}
