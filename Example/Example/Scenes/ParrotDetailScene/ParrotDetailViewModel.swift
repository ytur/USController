//
//  ParrotDetailViewModel.swift
//  Example
//
//  Created by Yasin TURKOGLU on 25.05.2020.
//  Copyright © 2020 Yasin TURKOGLU. All rights reserved.
//

import Foundation

protocol ParrotDetailViewModelDelegate: class { }

protocol ParrotDetailViewModelDataSource: class {
    var parrotSelectionToggleHandler: (() -> Void)? { get set }
    var barButtonStatusUpdater: ((Bool) -> Void)? { get set }
    var selectedParrot: ParrotModel? { get set }
    var parrotDetailUpdater: ((ParrotModel) -> Void)? { get set }
}

protocol ParrotDetailViewModelProtocol: ParrotDetailViewModelDelegate, ParrotDetailViewModelDataSource { }

class ParrotDetailViewModel: ParrotDetailViewModelProtocol {

    var parrotSelectionToggleHandler: (() -> Void)?
    var barButtonStatusUpdater: ((Bool) -> Void)?
    var parrotDetailUpdater: ((ParrotModel) -> Void)?
    var selectedParrot: ParrotModel? {
        didSet {
            guard let parrot = selectedParrot,
            let currentParrotDetailUpdater = parrotDetailUpdater else { return }
            currentParrotDetailUpdater(parrot)
        }
    }

}
