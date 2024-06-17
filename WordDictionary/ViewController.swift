import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var addButton: UIButton!
    var tableView: UITableView!
    var words: [String] = [] // 전체 단어 목록
    var filteredWords: [String] = [] // 필터링된 단어 목록
    var quizButton: UIButton!
    var searchBar: UISearchBar!
    var wordIDs: [String] = [] // 단어 ID 목록

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background Color
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        // Add Button
        addButton = UIButton(type: .system)
        addButton.setTitle("+ Add", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = UIColor(red: 0.22, green: 0.49, blue: 0.87, alpha: 1.0)
        addButton.layer.cornerRadius = 25
        addButton.addTarget(self, action: #selector(showAddWordModal), for: .touchUpInside)
        addButton.frame = CGRect(x: view.frame.width - 80, y: 50, width: 70, height: 50)
        view.addSubview(addButton)
        
        // Quiz Button
        quizButton = UIButton(type: .system)
        quizButton.setTitle("Start Quiz", for: .normal)
        quizButton.setTitleColor(.white, for: .normal)
        quizButton.backgroundColor = UIColor(red: 0.22, green: 0.49, blue: 0.87, alpha: 1.0)
        quizButton.layer.cornerRadius = 25
        quizButton.addTarget(self, action: #selector(startQuiz), for: .touchUpInside)
        quizButton.frame = CGRect(x: 20, y: 50, width: 120, height: 50)
        view.addSubview(quizButton)
        
        // Search Bar
        searchBar = UISearchBar()
        searchBar.placeholder = "Search words"
        searchBar.delegate = self
        searchBar.frame = CGRect(x: 20, y: 110, width: view.frame.width - 40, height: 50)
        view.addSubview(searchBar)
        
        // TableView
        tableView = UITableView(frame: CGRect(x: 20, y: 170, width: view.frame.width - 40, height: view.frame.height - 200))
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 10
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none // 셀 간 구분선 제거
        tableView.register(WordTableViewCell.self, forCellReuseIdentifier: WordTableViewCell.identifier)
        view.addSubview(tableView)
        
        // Firebase에서 데이터 가져오기
        FirebaseManager.shared.fetchWords { [weak self] words, wordIDs in
            self?.words = words
            self?.filteredWords = words // 초기화 시 필터링된 목록도 동일하게 설정
            self?.wordIDs = wordIDs
            self?.tableView.reloadData()
        }
    }
    
    @objc func startQuiz() {
        let quizViewController = QuizViewController()
        present(quizViewController, animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WordTableViewCell.identifier, for: indexPath) as! WordTableViewCell
        let wordAndMeaning = filteredWords[indexPath.row].components(separatedBy: ": ") // 단어와 뜻을 ":"로 분리
        let word = wordAndMeaning[0]
        let meaning = wordAndMeaning[1]
        cell.wordLabel.text = word
        cell.meaningLabel.text = meaning
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70 // 셀의 높이 조정
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // 선택된 셀을 다시 선택 해제
        // 여기에 선택된 셀에 대한 작업 추가
    }
    
    // 스와이프하여 삭제 기능 추가
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let wordToDelete = filteredWords[indexPath.row]
            let wordIDToDelete = wordIDs[indexPath.row]
            FirebaseManager.shared.deleteWord(wordID: wordIDToDelete) { [weak self] success in
                if success {
                    self?.words.removeAll { $0 == wordToDelete }
                    self?.filteredWords.removeAll { $0 == wordToDelete }
                    self?.wordIDs.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc func showAddWordModal() {
        let addWordViewController = AddWordViewController()
        addWordViewController.modalPresentationStyle = .formSheet
        addWordViewController.delegate = self
        present(addWordViewController, animated: true, completion: nil)
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredWords = words
        } else {
            filteredWords = words.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
}

extension ViewController: AddWordDelegate {
    func didAddWord(word: String, meaning: String) {
        FirebaseManager.shared.addWord(word: word, translation: meaning) { [weak self] wordID in
            guard let wordID = wordID else { return }
            self?.words.append("\(word): \(meaning)")
            self?.filteredWords = self?.words ?? []
            self?.wordIDs.append(wordID)
            self?.tableView.reloadData()
        }
    }
}

class FirebaseManager {
    static let shared = FirebaseManager()
    let ref = Database.database().reference()
    
    func addWord(word: String, translation: String, completion: @escaping (String?) -> Void) {
        let wordRef = ref.child("words").childByAutoId()
        let wordID = wordRef.key
        wordRef.setValue(["word": word, "translation": translation]) { error, _ in
            if let error = error {
                print("Error adding word: \(error)")
                completion(nil)
            } else {
                completion(wordID)
            }
        }
    }
    
    func deleteWord(wordID: String, completion: @escaping (Bool) -> Void) {
        ref.child("words").child(wordID).removeValue { error, _ in
            if let error = error {
                print("Error deleting word: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func fetchWords(completion: @escaping ([String], [String]) -> Void) {
        ref.child("words").observeSingleEvent(of: .value) { snapshot in
            var words: [String] = []
            var wordIDs: [String] = []
            for case let child as DataSnapshot in snapshot.children {
                if let value = child.value as? [String: String],
                   let word = value["word"],
                   let translation = value["translation"] {
                    words.append("\(word): \(translation)")
                    wordIDs.append(child.key)
                }
            }
            completion(words, wordIDs)
        }
    }
}

class WordTableViewCell: UITableViewCell {
    static let identifier = "WordTableViewCell"
    
    let wordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let meaningLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        stackView.addArrangedSubview(wordLabel)
        stackView.addArrangedSubview(meaningLabel)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

