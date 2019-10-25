//
//  UIReferenceLibrary.swift
//  WordScramble
//
//  Created by Mihai Leonte on 10/24/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI
import UIKit

struct UIReferenceLibraryController: UIViewControllerRepresentable {
    var word: String
    
    func makeUIViewController(context: Context) -> UIReferenceLibraryViewController {
            return UIReferenceLibraryViewController(term: word)
    }
    
    func updateUIViewController(_ referenceViewController: UIReferenceLibraryViewController, context: Context) {
        UIReferenceLibraryViewController(term: word)
    }
    
}
