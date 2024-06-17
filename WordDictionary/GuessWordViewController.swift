import UIKit

class GuessWordViewController: UIViewController {
    var words: [String] = []
    var currentWord: String = ""
    var meaningLabel: UILabel!
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

        // 뜻을 표시하는 레이블 추가
        meaningLabel = UILabel()
        meaningLabel.textAlignment = .center
        meaningLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        meaningLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(meaningLabel)

        // 답 입력을 위한 텍스트 필드 추가
        answerTextField = UITextField()
        answerTextField.placeholder = "Enter the word"
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
            meaningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            meaningLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            answerTextField.topAnchor.constraint(equalTo: meaningLabel.bottomAnchor, constant: 20),
            answerTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            answerTextField.widthAnchor.constraint(equalToConstant: 200),
            checkButton.topAnchor.constraint(equalTo: answerTextField.bottomAnchor, constant: 20),
            checkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // 초기 뜻 설정
        showNextMeaning()
    }

    @objc func checkAnswer() {
        guard let answer = answerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }

        let word = currentWord.components(separatedBy: ":").first?.trimmingCharacters(in: .whitespacesAndNewlines)

        if answer == word {
            showAlert(title: "Correct!", message: "You got it right.") { [weak self] in
                self?.showNextMeaning()
            }
        } else {
            showAlert(title: "Incorrect", message: "Try again.")
        }
    }

    func showNextMeaning() {
        guard let randomWord = words.randomElement() else {
            return
        }
        currentWord = randomWord
        meaningLabel.text = currentWord.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespacesAndNewlines)
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

