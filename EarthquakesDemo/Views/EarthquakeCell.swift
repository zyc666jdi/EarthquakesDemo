import UIKit

// List cell showing earthquake:
final class EarthquakeCell: UITableViewCell {

    static let reuseIdentifier = "EarthquakeCell"

    // MARK: - Subviews
    private let magnitudeBadge: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.layer.cornerRadius = 24
        label.layer.masksToBounds = true
        return label
    }()

    private let placeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let tsunamiTag: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .systemTeal
        label.text = "TSUNAMI WARNING"
        label.isHidden = true
        return label
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    private func setupLayout() {
        let textStack = UIStackView(arrangedSubviews: [placeLabel, dateLabel, tsunamiTag])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.alignment = .leading

        contentView.addSubview(magnitudeBadge)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            magnitudeBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            magnitudeBadge.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            magnitudeBadge.widthAnchor.constraint(equalToConstant: 48),
            magnitudeBadge.heightAnchor.constraint(equalToConstant: 48),
            textStack.leadingAnchor.constraint(equalTo: magnitudeBadge.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    // MARK: - Configuration
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    func configure(with feature: EarthquakeFeature) {
        let mag = feature.properties.mag
        let severe = EarthquakeListViewModel.isSevere(feature)
        magnitudeBadge.text = String(format: "%.1f", mag)
        magnitudeBadge.backgroundColor = severe ? .systemRed : .systemBlue
        placeLabel.text = feature.properties.place
        dateLabel.text = Self.dateFormatter.string(from: feature.properties.date)
        tsunamiTag.isHidden = feature.properties.tsunami == 0
        contentView.backgroundColor = severe
            ? UIColor.systemRed.withAlphaComponent(0.07)
            : .systemBackground
        accessoryType = .disclosureIndicator
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        tsunamiTag.isHidden = true
        contentView.backgroundColor = .systemBackground
    }
}
