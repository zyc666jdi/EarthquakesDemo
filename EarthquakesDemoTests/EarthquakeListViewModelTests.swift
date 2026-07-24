import XCTest
@testable import EarthquakesDemo

// Unit tests for `EarthquakeListViewModel`.
final class EarthquakeListViewModelTests: XCTestCase {

    // MARK: - Severity threshold
    func test_isSevere_returnsFalseBelow7_5() {
        let feature = EarthquakeFeature.make(mag: 7.4)
        XCTAssertFalse(EarthquakeListViewModel.isSevere(feature))
    }

    func test_isSevere_returnsTrueAt7_5() {
        let feature = EarthquakeFeature.make(mag: 7.5)
        XCTAssertTrue(EarthquakeListViewModel.isSevere(feature))
    }

    func test_isSevere_returnsTrueAbove7_5() {
        let feature = EarthquakeFeature.make(mag: 7.8)
        XCTAssertTrue(EarthquakeListViewModel.isSevere(feature))
    }

    // MARK: - Initial state
    func test_initialState_isIdle() {
        let vm = makeViewModel()
        if case .idle = vm.state {
            
        } else {
            XCTFail("Expected .idle, got \(vm.state)")
        }
    }

    // MARK: - Loading state
    func test_loadEarthquakes_transitionsToLoading() {
        class HangingService: EarthquakeServiceProtocol {
            func fetchEarthquakes(completion: @escaping (Result<[EarthquakeFeature], Error>) -> Void) {
            
            }
        }
        let exp = expectation(description: ".loading observed")
        let vm = EarthquakeListViewModel(service: HangingService())
        vm.onStateChange = { state in
            if case .loading = state { exp.fulfill() }
        }
        vm.loadEarthquakes()
        waitForExpectations(timeout: 1)
    }

    func test_loadEarthquakes_doesNotRefetchWhileLoading() {
        let service = MockEarthquakeService()
        var callCount = 0
        service.result = .success([])
        let vm = makeViewModel(service: service)
        class CountingService: EarthquakeServiceProtocol {
            var count = 0
            func fetchEarthquakes(completion: @escaping (Result<[EarthquakeFeature], Error>) -> Void) {
                count += 1
            }
        }
        let counter = CountingService()
        let vm2 = EarthquakeListViewModel(service: counter)
        vm2.loadEarthquakes()
        vm2.loadEarthquakes()
        vm2.loadEarthquakes()
        XCTAssertEqual(counter.count, 1)
    }

    // MARK: - Loaded state

    func test_loadEarthquakes_transitionsToLoadedOnSuccess() {
        let exp = expectation(description: "state = .loaded")
        let features = [EarthquakeFeature.make(id: "a"), EarthquakeFeature.make(id: "b")]
        let service = MockEarthquakeService()
        service.result = .success(features)
        let vm = makeViewModel(service: service)
        vm.onStateChange = { state in
            if case .loaded = state { exp.fulfill() }
        }
        vm.loadEarthquakes()
        waitForExpectations(timeout: 1)
    }

    func test_loadEarthquakes_earthquakesAccessorReturnsItems() {
        let exp = expectation(description: "loaded")
        let features = [EarthquakeFeature.make(id: "x")]
        let service = MockEarthquakeService()
        service.result = .success(features)
        let vm = makeViewModel(service: service)

        vm.onStateChange = { state in
            if case .loaded = state { exp.fulfill() }
        }
        vm.loadEarthquakes()
        waitForExpectations(timeout: 1)

        XCTAssertEqual(vm.earthquakes.count, 1)
        XCTAssertEqual(vm.earthquakes.first?.id, "x")
    }

    func test_loadEarthquakes_sortsByNewestFirst() {
        let exp = expectation(description: "loaded")
        // Older earthquake first in service response
        let older = EarthquakeFeature.make(id: "old", timeMs: 1_000_000)
        let newer = EarthquakeFeature.make(id: "new", timeMs: 2_000_000)
        let service = MockEarthquakeService()
        service.result = .success([older, newer])
        let vm = makeViewModel(service: service)

        vm.onStateChange = { state in
            if case .loaded = state { exp.fulfill() }
        }
        vm.loadEarthquakes()
        waitForExpectations(timeout: 1)

        XCTAssertEqual(vm.earthquakes.first?.id, "new")
        XCTAssertEqual(vm.earthquakes.last?.id, "old")
    }

    // MARK: - Error state
    func test_loadEarthquakes_transitionsToErrorOnFailure() {
        let exp = expectation(description: "state = .error")
        let service = MockEarthquakeService()
        service.result = .failure(EarthquakeServiceError.noData)
        let vm = makeViewModel(service: service)
        vm.onStateChange = { state in
            if case .error = state { exp.fulfill() }
        }
        vm.loadEarthquakes()
        waitForExpectations(timeout: 1)
    }

    func test_loadEarthquakes_errorContainsMessage() {
        let exp = expectation(description: "error message")
        let service = MockEarthquakeService()
        service.result = .failure(EarthquakeServiceError.noData)
        let vm = makeViewModel(service: service)
        var capturedMessage = ""
        vm.onStateChange = { state in
            if case .error(let msg) = state {
                capturedMessage = msg
                exp.fulfill()
            }
        }
        vm.loadEarthquakes()
        waitForExpectations(timeout: 1)
        XCTAssertFalse(capturedMessage.isEmpty)
    }

    // MARK: - earthquakes accessor when not loaded
    func test_earthquakes_returnsEmptyWhenIdle() {
        let vm = makeViewModel()
        XCTAssertTrue(vm.earthquakes.isEmpty)
    }

    // MARK: - Helpers
    private func makeViewModel(service: EarthquakeServiceProtocol = MockEarthquakeService()) -> EarthquakeListViewModel {
        EarthquakeListViewModel(service: service)
    }
}
