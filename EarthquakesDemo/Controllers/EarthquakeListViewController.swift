import UIKit

final class EarthquakeListViewController: UIViewController {
    // MARK: - Dependencies
    private let viewModel: EarthquakeListViewModel
    // MARK: - Subviews
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(EarthquakeCell.self, forCellReuseIdentifier: EarthquakeCell.reuseIdentifier)
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 80
        return tv
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        return ai
    }()
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 15)
        label.isHidden = true
        return label
    }()

    // MARK: - Init
    init(viewModel: EarthquakeListViewModel = EarthquakeListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadEarthquakes()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Earthquakes 2023"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
    }

    // MARK: - Rendering
    private func render(_ state: EarthquakeListState) {
        switch state {
        case .idle:
            break
        case .loading:
            activityIndicator.startAnimating()
            tableView.isHidden = true
            errorLabel.isHidden = true
        case .loaded:
            activityIndicator.stopAnimating()
            tableView.isHidden = false
            errorLabel.isHidden = true
            tableView.reloadData()
        case .error(let message):
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            errorLabel.text = message
            errorLabel.isHidden = false
        }
    }
}

// MARK: - UITableViewDataSource
extension EarthquakeListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.earthquakes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: EarthquakeCell.reuseIdentifier,
            for: indexPath
        ) as? EarthquakeCell {
            cell.configure(with: viewModel.earthquakes[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension EarthquakeListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let feature = viewModel.earthquakes[indexPath.row]
        let detailVC = EarthquakeDetailViewController(feature: feature)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
