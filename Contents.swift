//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

struct ViewData {
    let leadingTitle: String
    let centerTitle: String
    let trailingTitle: String
}
class CellViewModel {
    let data: [ViewData] = [
        ViewData(leadingTitle: "1", centerTitle: "1", trailingTitle: "1"),
        ViewData(leadingTitle: "2", centerTitle: "2", trailingTitle: "2"),
        ViewData(leadingTitle: "3", centerTitle: "3", trailingTitle: "3"),
        ViewData(leadingTitle: "4", centerTitle: "4", trailingTitle: "4"),
        ViewData(leadingTitle: "5", centerTitle: "5", trailingTitle: "5"),
    ]
}

final class DynamicTableViewCell: UITableViewCell {
    static let identifier = "DynamicTableViewCell"
    var viewModel: CellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            
//            verticalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                viewModel.data.forEach { (singleElement) in
                    let row = self.createRow(firstTitle: singleElement.leadingTitle, secondTitle: singleElement.centerTitle, thirdTitle: singleElement.trailingTitle)
                    self.verticalStackView.addArrangedSubview(row)
                }
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }
    
    private let marketPicker: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.text = "Example title"
        return label
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.backgroundColor = .red
        stackView.clipsToBounds = true
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension DynamicTableViewCell {
    enum DesignConstants {
        enum Matrix {
            static let topPadding: CGFloat = 26
            static let singleRowHeight: CGFloat = 24
        }
    }
    
    func configureView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        let titleRow = self.createRow(firstTitle: "Maker %", secondTitle: "Taker %", thirdTitle: "Your volume MXN")
        verticalStackView.addArrangedSubview(titleRow)
        
        contentView.addSubview(marketPicker)
        contentView.addSubview(verticalStackView)
        
        applyConstraints()
    }
    
    func applyConstraints() {
        NSLayoutConstraint.activate([
            marketPicker.topAnchor.constraint(equalTo: contentView.topAnchor),
            marketPicker.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            marketPicker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            marketPicker.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: marketPicker.bottomAnchor, constant: DesignConstants.Matrix.topPadding),
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    func createRow(firstTitle: String, secondTitle: String, thirdTitle: String) -> UIView {
        let horizontalStackView = UIStackView()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.alignment = .fill
        
        let firstLabel = createRowLabel(with: firstTitle, alignment: .left)
        horizontalStackView.addArrangedSubview(firstLabel)
        
        let secondLabel = createRowLabel(with: secondTitle, alignment: .center)
        horizontalStackView.addArrangedSubview(secondLabel)
        
        let thirdLabel = createRowLabel(with: thirdTitle, alignment: .right)
        horizontalStackView.addArrangedSubview(thirdLabel)
        
        horizontalStackView.heightAnchor.constraint(equalToConstant: DesignConstants.Matrix.singleRowHeight).isActive = true
        horizontalStackView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        horizontalStackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        return horizontalStackView
    }
    
    func createRowLabel(with text: String, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .blue
        label.text = text
        label.textAlignment = alignment
        return label
    }
}


class MyViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(DynamicTableViewCell.self, forCellReuseIdentifier: DynamicTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DynamicTableViewCell.identifier, for: indexPath) as! DynamicTableViewCell
        cell.viewModel = CellViewModel()
        return cell
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
