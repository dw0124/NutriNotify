import UIKit
import SnapKit

class SuppComposeViewController: UIViewController, ViewModelBindableType {

    var viewModel: SuppComposeViewModel!
    
    private let tableView = UITableView()
    private let nameTextField = UITextField()
    private let descriptionTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationItem()
        setLayout()
        
        bindViewModel()
    }

}

extension SuppComposeViewController {
    // ViewModel 바인딩
    func bindViewModel() {
        guard let supplement = viewModel.supplement else { return }
        
        nameTextField.text = supplement.name
        descriptionTextView.text = supplement.desc
        
        guard let suppAlerts = supplement.suppAlert?.array as? [SuppAlertEntity] else { return }
        viewModel.alertTimes = suppAlerts.compactMap { $0.alertTime }
        
        tableView.reloadData()
    }
    
    func setNavigationItem() {
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action:#selector(dismissVC))
        let saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action:#selector(saveSupp))
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc func saveSupp() {
        viewModel.name = nameTextField.text ?? "이름없음"
        viewModel.description = descriptionTextView.text ?? "설명없음"
        viewModel.saveSupp() {
            self.dismiss(animated: true)
        }
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true)
    }
    
    @objc func addCell() {
        viewModel.alertTimeAppend()
        tableView.reloadData()
    }
    
    // UI설정 및 레이아웃
    func setLayout() {
        view.backgroundColor = .white
        
        // 텍스트 필드
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        nameTextField.placeholder = "영양제 이름"
        nameTextField.borderStyle = .roundedRect

        // 텍스트 뷰
        view.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        descriptionTextView.text = "설명"
        descriptionTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.cornerRadius = 5

        // 알림 추가 버튼
        let addButton = UIButton(type: .system)
        addButton.setTitle("알림 추가", for: .normal)
        addButton.addTarget(self, action: #selector(addCell), for: .touchUpInside)
        view.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(descriptionTextView.snp.bottom).offset(30)
        }
        
        // 테이블 뷰
        view.addSubview(tableView)
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: DatePickerCell.identifier)
        tableView.isEditing = true
        tableView.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

extension SuppComposeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.alertTimes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerCell.identifier) as? DatePickerCell else { return UITableViewCell() }
        
        cell.alertTextLabel.text = "알림\(indexPath.row + 1)"
        cell.datePicker.date = viewModel.alertTimes[indexPath.row]
        
        cell.didSelectTime = { [weak self] time in
            // 선택한 시간을 ViewModel에 전달
            self?.viewModel.alertTimes[indexPath.row] = time
            print(time)
        }
        
        return cell
    }
}

extension SuppComposeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        viewModel.alertTimes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}

