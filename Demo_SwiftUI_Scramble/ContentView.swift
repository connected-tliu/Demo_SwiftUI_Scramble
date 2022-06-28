//
//  ContentView.swift
//  Demo_SwiftUI_Scramble
//
//  Created by Tak Liu on 2022-06-27.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .textInputAutocapitalization(.none)
                List(usedWords, id: \.self) { usedWord in
                    HStack {
                        Image(systemName: "\(usedWord.count).circle")
                        Text(usedWord)
                    }
                }
                Spacer()
                Text("Your score: \(score)")
                    .fontWeight(.heavy)
                    .font(.largeTitle)
            }
            .navigationTitle(rootWord)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Restart") {
                        startGame()
                        resetGameBoard()
                    }
                }
            }
        }
        .onAppear(perform: startGame)
        .alert(isPresented: $showingError) {
            Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", messsage: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recongnized", messsage: "You can't just make them up, you know!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", messsage: "that isn't a real word")
            return
        }
        
        usedWords.insert(answer, at: 0)
        score = gainScore(with: answer)
        newWord = ""
    }
    
    func resetGameBoard() {
        score = 0
        usedWords = []
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkorm"
                
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        guard word.count >= 3 else { return false }
        guard word != rootWord else { return false }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
       
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, messsage: String) {
        errorTitle = title
        errorMessage = messsage
        showingError = true
    }
    
    func gainScore(with word: String) -> Int {
        let wordPoint = 1
        let letterPoint = word.count
        
        return wordPoint + letterPoint + score
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
