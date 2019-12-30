//
//  ContentView.swift
//  WordScramble
//
//  Created by Mihai Leonte on 10/23/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
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
    @State private var subsets: [String] = []
    @State private var solutions: [String] = []
    
    
    
    var body: some View {
        NavigationView {
            VStack {

                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
//                List(usedWords, id:\.self) {
//                    //NavigationLink(destination: UIReferenceLibraryController(word: String($0))) {
//                        //HStack {
//                    Image(systemName: "\($0.count).circle")
//                    Text($0)
//                        //}
//                    //}
//                }.listStyle(GroupedListStyle())
                
                // improvement for accesibility
                
                
                List(self.usedWords, id: \.self) { word in
                    GeometryReader { proxy in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                                .foregroundColor(self.changeColorOnScroll(for: proxy))
                            Text(word)
                            Spacer()
                        }
                        .offset(x: proxy.frame(in: .global).minY < 600 ? 0 : (proxy.frame(in: .global).minY - 600), y: 0.0)
                        .accessibilityElement(children: .ignore)
                        .accessibility(label: Text("\(word), \(word.count) letters"))
                        
                    }
                }
                
                Text("Score: \(score) total letters.")
                    .foregroundColor(.gray)
                    .font(.headline)
                
            }.navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarItems(leading: Button(action: { self.startGame() }) { Text("New Word") },
                                trailing: Button(action: {
                                    self.usedWords.removeAll()
                                    self.subsetPermutation(word: self.rootWord)
                                }) { Text("Show All") })

            }
    }
    
    func changeColorOnScroll(for proxy: GeometryProxy) -> Color {
        let minY = Double(proxy.frame(in: .global).minY)
        let hue = minY / 800
        //print("\(minY) / \(800) = \(hue)")
        return Color(hue: hue, saturation: 0.8, brightness: 0.8)
    }

    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        newWord = ""
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know?")
            return
        }
        
        guard isSpelledCorrectly(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word")
            return
        }
        
        guard isNotStartingWord(word: answer) else {
            wordError(title: "Starting word", message: "Come up with something else")
            return
        }
        
        guard isLongerThanTwoLetters(word: answer) else {
            wordError(title: "Word too short", message: "Come up with something longer than two letters")
            return
        }
        
        usedWords.insert(answer, at: 0)
        score += answer.count
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                
                newWord = ""
                score = 0
                usedWords.removeAll()
                rootWord = allWords.randomElement() ?? "silkworm"
                //rootWord = "daffodil"
                
                return
            }
        }
        fatalError("could not load")
    }
    
    // call all the different sub-words
    func subsetPermutation(word: String) {
        subsets.append(word)
        print("subsetPermutation \(word)")
        let chars = Array(word)
        permuteWirth(chars, chars.count - 1)
        
        if chars.count > 3 {
            for i in 0...chars.count-1 {
                var subset = chars
                subset.remove(at: i)

                if !subsets.contains(String(subset)) {
                    subsetPermutation(word: String(subset))
                    
                }
            }
        }
    }

    // try all the different permutations
    // let letters = ["a", "b", "c"]
    // permuteWirth(letters, letters.count - 1)
    func permuteWirth<T>(_ a: [T], _ n: Int) {
        if n == 0 {
            var newWord = String(a as! [Character])
            if isSpelledCorrectly(word: newWord) {
                if !solutions.contains(String(newWord)) {
                    print("newWord \(newWord)")
                    usedWords.insert(newWord, at: 0)
                }
            }
        } else {
            var a = a
            permuteWirth(a, n - 1)
            for i in 0..<n {
                a.swapAt(i, n)
                permuteWirth(a, n - 1)
                a.swapAt(i, n)
            }
        }
    }
    

    func isOriginal(word: String) -> Bool { !usedWords.contains(word) }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isSpelledCorrectly(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func isReal(word: String) -> Bool {
        if UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: word) {
            return true
        } else {
            return false
        }
    }
    
    func isNotStartingWord(word: String) -> Bool {
        return word != rootWord
    }
    func isLongerThanTwoLetters(word: String) -> Bool {
        return word.count >= 3
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
