//
//  ParrotSelectionViewModel.swift
//  Example
//
//  Created by Yasin TURKOGLU on 25.05.2020.
//  Copyright © 2020 Yasin TURKOGLU. All rights reserved.
//

import Foundation

protocol ParrotSelectionViewModelDelegate: class {
    func createParrotsList()
}

protocol ParrotSelectionViewModelDataSource: class {
    var parrots: [ParrotModel] { get set }
    var parrotSelectionHandler: ((ParrotModel) -> Void)? { get set }
}

protocol ParrotSelectionViewModelProtocol: ParrotSelectionViewModelDelegate, ParrotSelectionViewModelDataSource { }

class ParrotSelectionViewModel: ParrotSelectionViewModelProtocol {

    var parrots = [ParrotModel]()
    var parrotSelectionHandler: ((ParrotModel) -> Void)?

    func createParrotsList() {
        parrots.removeAll()
        guard var parrotURLs = Bundle.main.urls(forResourcesWithExtension: "gif", subdirectory: nil) else { return }
        parrotURLs.sort { (parrot1, parrot2) -> Bool in
            let parrot1Name = parrot1.deletingPathExtension().lastPathComponent
            let parrot2Name = parrot2.deletingPathExtension().lastPathComponent
            return parrot1Name < parrot2Name
        }
        parrotURLs.forEach { (url) in
            guard let parrotData = try? Data(contentsOf: url) else { return }
            let name = url.deletingPathExtension().lastPathComponent
            parrots.append(ParrotModel(name: name, data: parrotData))
        }
    }

}
