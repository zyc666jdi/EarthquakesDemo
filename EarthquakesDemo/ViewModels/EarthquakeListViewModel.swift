import Foundation

// MARK: - View state
// All possible states for the earthquake list screen.
enum EarthquakeListState: Equatable {
    case idle
    case loading
    case loaded([EarthquakeFeature])
    case error(String)

    static func == (lhs: EarthquakeListState, rhs: EarthquakeListState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.loaded(let a), .loaded(let b)):
            return a.map(\.id) == b.map(\.id)
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: - ViewModel

// Owns all business logic for `EarthquakeListViewController`.
final class EarthquakeListViewModel {

    // MARK: Binding
    var onStateChange: ((EarthquakeListState) -> Void)?

    private(set) var state: EarthquakeListState = .idle {
        didSet {
            let snapshot = state
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.onStateChange?(snapshot)
            }
        }
    }

    // MARK: Dependencies
    private let service: EarthquakeServiceProtocol

    init(service: EarthquakeServiceProtocol = EarthquakeService()) {
        self.service = service
    }

    // MARK: Intents
    func loadEarthquakes() {
        guard case .loading = state else {
            state = .loading
            fetch()
            return
        }
    }

    // MARK: Private
    private func fetch() {
        service.fetchEarthquakes { [weak self] result in
            switch result {
            case .success(let features):
                let sorted = features.sorted { $0.properties.time > $1.properties.time }
                self?.state = .loaded(sorted)
            case .failure(let error):
                self?.state = .error(error.localizedDescription)
            }
        }
    }

    // MARK: View helpers
    var earthquakes: [EarthquakeFeature] {
        guard case .loaded(let items) = state else { return [] }
        return items
    }

    // Returns `true` when the quake's magnitude meets the "severe" visual threshold (≥ 7.5).
    static func isSevere(_ feature: EarthquakeFeature) -> Bool {
        feature.properties.mag >= 7.5
    }
}
