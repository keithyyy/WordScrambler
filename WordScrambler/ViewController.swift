//
//  ViewController.swift
//  WordScrambler
//
//  Created by Keith Crooc on 2021-04-17.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
    
//        this is how we tell swift to look at the "start.txt" file in our project
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
//            when Swift finds it, we create a variable/constant of startWords and it's value...well "try this" (we set it to an optional because it could be empty right)
            if let startWords = try? String(contentsOf: startWordsURL) {
//                we have a variable "allWords" that is an array. We fill that array with our startWords. Each item is separated by a line break (rep by "\n")
                allWords = startWords.components(separatedBy: "\n")
            }
            
            if allWords.isEmpty {
                allWords = ["silkworm"]
            }
        }
        
        startGame()
        
    }

    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
            
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    showErrorMessage(msg: 0)
                }
            } else {
                
                showErrorMessage(msg: 1)
        
            }
        } else {
            showErrorMessage(msg: 2)
        }
        
        

        
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
//        if word exists in the usedWords container...
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        if word.count < 3 {
            print("word count being used")
            return false
        }
        if word == title {
            print("original word being used")
            return false
        }
        return misspelledRange.location == NSNotFound
        
        
    }
    
    
    func showErrorMessage(msg: Int) {
        
        let errorTitle: String
        let errorMessage: String
        
        switch msg {
        
        case 1:
            errorTitle = "Word used already"
            errorMessage = "Be more original"
            
        case 2:
            errorTitle = "word not possible"
            errorMessage = "You can't spell that from \(title!.lowercased())"
        
        default:
            errorTitle = "Word not recognized"
            errorMessage = "You can't just make random words up buddy!"
        }
        
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        
        
    }

}


// CHALLENGE

// 1. don't allow words less than 3 letters
// 2. refactor all the else statements into a showErrorMessage() func
// 3. add left bar button item that calls startGame() - done!

// ** bonus **
// if you enter an uppercase word, then the same word but lowercase - it counts as two words. Make it count only as one
