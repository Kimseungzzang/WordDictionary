import UIKit

class GuessMeaningViewController: UIViewController {
    var words: [String] = []
    var currentWord: String = ""
    var wordLabel: UILabel!
    var answerTextField: UITextField!

    init(words: [String]) {
        super.init(nibName: nil, bundle: nil)
        self.words = words
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // 단어를 표시하는 레이블 추가
        wordLabel = UILabel()
        wordLabel.textAlignment = .center
        wordLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wordLabel)

        // 답 입력을 위한 텍스트 필드 추가
        answerTextField = UITextField()
        answerTextField.placeholder = "Enter the meaning"
        answerTextField.borderStyle = .roundedRect
        answerTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(answerTextField)

        // 확인 버튼 추가
        let checkButton = UIButton(type: .system)
        checkButton.setTitle("Check", for: .normal)
        checkButton.addTarget(self, action: #selector(checkAnswer), for: .touchUpInside)
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(checkButton)

        // 레이블, 텍스트 필드, 버튼 레이아웃 설정
        NSLayoutConstraint.activate([
            wordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            wordLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            answerTextField.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 20),
            answerTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            answerTextField.widthAnchor.constraint(equalToConstant: 200),
            checkButton.topAnchor.constraint(equalTo: answerTextField.bottomAnchor, constant: 20),
            checkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // 초기 단어 설정
        showNextWord()
    }

    @objc func checkAnswer() {
        guard let answer = answerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }

        let meaning = currentWord.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespacesAndNewlines)

        if answer == meaning {
            showAlert(title: "Correct!", message: "You got it right.") { [weak self] in
                self?.showNextWord()
            }
        } else {
            showAlert(title: "Incorrect", message: "Try again.")
        }
    }

    func showNextWord() {
        guard let randomWord = words.randomElement() else {
            return
        }
        currentWord = randomWord
        wordLabel.text = currentWord.components(separatedBy: ":").first // 단어만 표시
        answerTextField.text = ""
    }

    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

