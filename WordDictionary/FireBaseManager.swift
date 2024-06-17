import Foundation
import Firebase

class FirebaseManager {
    static let shared = FirebaseManager()
    let ref = Database.database().reference()
    
    func addWord(word: String, translation: String) {
        let wordRef = ref.child("words").childByAutoId()
        wordRef.setValue(["word": word, "translation": translation])
    }
    
    func deleteWord(wordID: String) {
        ref.child("words").child(wordID).removeValue()
    }
}
