import UIKit

protocol AddWordDelegate: AnyObject {
    func didAddWord(word: String, meaning: String)
}

class AddWordViewController: UIViewController {
    weak var delegate: AddWordDelegate?
    var wordTextField: UITextField!
    var meaningTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        // Configure wordTextField
        wordTextField = UITextField()
        wordTextField.placeholder = "Enter word"
        wordTextField.borderStyle = .roundedRect
        wordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wordTextField)
        
        // Configure meaningTextField
        meaningTextField = UITextField()
        meaningTextField.placeholder = "Enter meaning"
        meaningTextField.borderStyle = .roundedRect
        meaningTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(meaningTextField)
        
        // Configure addButton
        let addButton = UIButton(type: .system)
        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = UIColor(red: 0.22, green: 0.49, blue: 0.87, alpha: 1.0)
        addButton.layer.cornerRadius = 5
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addWord), for: .touchUpInside)
        view.addSubview(addButton)
        
        // Configure cancelButton
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = .red
        cancelButton.layer.cornerRadius = 5
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        // Auto Layout constraints
        NSLayoutConstraint.activate([
            wordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            wordTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            wordTextField.widthAnchor.constraint(equalToConstant: 300),
            wordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            meaningTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            meaningTextField.topAnchor.constraint(equalTo: wordTextField.bottomAnchor, constant: 20),
            meaningTextField.widthAnchor.constraint(equalTo: wordTextField.widthAnchor),
            meaningTextField.heightAnchor.constraint(equalTo: wordTextField.heightAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: wordTextField.leadingAnchor),
            addButton.topAnchor.constraint(equalTo: meaningTextField.bottomAnchor, constant: 20),
            addButton.widthAnchor.constraint(equalToConstant: 130),
            addButton.heightAnchor.constraint(equalToConstant: 40),
            
            cancelButton.trailingAnchor.constraint(equalTo: wordTextField.trailingAnchor),
            cancelButton.topAnchor.constraint(equalTo: meaningTextField.bottomAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalTo: addButton.widthAnchor),
            cancelButton.heightAnchor.constraint(equalTo: addButton.heightAnchor)
        ])
    }
    
    @objc func addWord() {
        guard let word = wordTextField.text, !word.isEmpty, let meaning = meaningTextField.text, !meaning.isEmpty else {
            showAlert(title: "Error", message: "Please fill in both fields")
            return
        }
        delegate?.didAddWord(word: word, meaning: meaning)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

