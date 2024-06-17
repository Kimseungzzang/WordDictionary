import UIKit
import Firebase

class QuizViewController: UIViewController {
    var words: [String] = [] // 사용될 단어 목록
    var wordIDs: [String] = [] // 단어 ID 목록
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        // Firebase에서 단어 목록 가져오기
        FirebaseManager.shared.fetchWords { [weak self] words, wordIDs in
            self?.words = words
            self?.wordIDs = wordIDs
        }
        
        // 퀴즈 시작 버튼 추가
        let startQuizButton = UIButton(type: .system)
        startQuizButton.setTitle("Start Quiz", for: .normal)
        startQuizButton.setTitleColor(.white, for: .normal)
        startQuizButton.backgroundColor = UIColor(red: 0.22, green: 0.49, blue: 0.87, alpha: 1.0)
        startQuizButton.layer.cornerRadius = 25
        startQuizButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        startQuizButton.addTarget(self, action: #selector(startQuiz), for: .touchUpInside)
        startQuizButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startQuizButton)
        
        // 버튼 레이아웃 설정
        NSLayoutConstraint.activate([
            startQuizButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startQuizButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startQuizButton.widthAnchor.constraint(equalToConstant: 200),
            startQuizButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func startQuiz() {
        // 퀴즈 타입 선택 알림창 표시
        let alertController = UIAlertController(title: "Choose Quiz Type", message: nil, preferredStyle: .actionSheet)
        
        // 뜻 맞추기 액션 추가
        let guessMeaningAction = UIAlertAction(title: "Guess Meaning", style: .default) { _ in
            self.startMeaningQuiz()
        }
        alertController.addAction(guessMeaningAction)
        
        // 단어 맞추기 액션 추가
        let guessWordAction = UIAlertAction(title: "Guess Word", style: .default) { _ in
            self.startWordQuiz()
        }
        alertController.addAction(guessWordAction)
        
        // 취소 액션 추가
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func startMeaningQuiz() {
        // 뜻 맞추기 퀴즈 시작
        let randomWords = getRandomWords(count: 20)
        let guessMeaningVC = GuessMeaningViewController(words: randomWords)
        present(guessMeaningVC, animated: true, completion: nil)
    }
    
    func startWordQuiz() {
        // 단어 맞추기 퀴즈 시작
        let randomWords = getRandomWords(count: 20)
        let guessWordVC = GuessWordViewController(words: randomWords)
        present(guessWordVC, animated: true, completion: nil)
    }
    
    func getRandomWords(count: Int) -> [String] {
        guard count > 0 else { return [] }
        // 단어 목록에서 랜덤으로 선택
        let shuffledWords = words.shuffled()
        return Array(shuffledWords.prefix(count))
    }
}

