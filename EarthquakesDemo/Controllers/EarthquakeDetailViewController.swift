import UIKit
import MapKit

// Detail screen: displays the earthquake epicenter on a full-screen map, with a summary card anchored to the bottom edge.
final class EarthquakeDetailViewController: UIViewController {
    private let feature: EarthquakeFeature
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsCompass = true
        map.showsScale = true
        return map
    }()
    // Floating card that overlays the bottom of the map with key stats.
    private let infoCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        return view
    }()

    // MARK: - Init
    init(feature: EarthquakeFeature) {
        self.feature = feature
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureMap()
    }

    // MARK: - Setup
    private func setupUI() {
        title = feature.properties.place
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
        view.addSubview(infoCard)
        let statStack = buildStatStack()
        infoCard.addSubview(statStack)
        let cardHeight: CGFloat = 100
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            infoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            infoCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            infoCard.heightAnchor.constraint(equalToConstant: cardHeight + view.safeAreaInsets.bottom),
            statStack.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 16),
            statStack.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            statStack.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
        ])
    }

    // Builds a horizontal stack of three labelled stat columns.
    private func buildStatStack() -> UIStackView {
        let severe = EarthquakeListViewModel.isSevere(feature)
        let mag = statColumn(title: "Magnitude", value: String(format: "%.1f", feature.properties.mag), valueColor: severe ? .systemRed : .label)
        let depth = statColumn(title: "Depth", value: String(format: "%.0f km", feature.depthKm))
        let date  = statColumn(title: "Date", value: DateFormatter.mediumDate.string(from: feature.properties.date))
        let stack = UIStackView(arrangedSubviews: [mag, depth, date])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }

    // Creates a vertical stack with a greyed-out title above a bold value.
    private func statColumn(title: String, value: String, valueColor: UIColor = .label) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 11, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        valueLabel.textColor = valueColor
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7
        let col = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        col.axis = .vertical
        col.spacing = 2
        return col
    }

    // MARK: - Map configuration
    private func configureMap() {
        let coordinate = CLLocationCoordinate2D(
            latitude: feature.latitude,
            longitude: feature.longitude
        )
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = feature.properties.place
        pin.subtitle = String(format: "M %.1f • %.0f km deep", feature.properties.mag, feature.depthKm)
        mapView.addAnnotation(pin)
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 800_000,
            longitudinalMeters: 800_000
        )
        mapView.setRegion(region, animated: false)
        mapView.selectAnnotation(pin, animated: false)
    }
}

// MARK: - DateFormatter helpers
private extension DateFormatter {
    static let mediumDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
}
