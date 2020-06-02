//
//  ParrotSelectionController.swift
//  Example
//
//  Created by Yasin TURKOGLU on 25.05.2020.
//  Copyright © 2020 Yasin TURKOGLU. All rights reserved.
//

import UIKit

class ParrotSelectionController: UIViewController {

    private var viewModel: ParrotSelectionViewModel!

    init(viewModel: ParrotSelectionViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.register(ParrotSelectionTableViewCell.self, forCellReuseIdentifier: "parrotCell")
        tableView.separatorInset = .zero
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "parrots"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
    }

    func setupUI() {
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        let topAnchor: NSLayoutYAxisAnchor = topLayoutGuide.bottomAnchor
        var bottomAnchor: NSLayoutYAxisAnchor = view.bottomAnchor
        let leadingAnchor: NSLayoutXAxisAnchor = view.leadingAnchor
        let trailingAnchor: NSLayoutXAxisAnchor = view.trailingAnchor
        if #available(iOS 11.0, *) {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        }
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.layoutIfNeeded()
        if tableView.indexPathForSelectedRow == nil {
            if let parrotSelectionHandler = viewModel.parrotSelectionHandler,
                let firstParrot = viewModel.parrots.first {
                parrotSelectionHandler(firstParrot)
                tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
            }
        }
    }

}

extension ParrotSelectionController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.parrots.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "parrotCell", for: indexPath)
        if let parrotCell = cell as? ParrotSelectionTableViewCell {
            let parrot = viewModel.parrots[indexPath.row]
            parrotCell.parrotImageData = parrot.data
            return parrotCell
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            if selectedIndexPath == indexPath {
                return nil
            }
        }
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let parrotSelectionHandler = viewModel.parrotSelectionHandler {
            parrotSelectionHandler(viewModel.parrots[indexPath.row])
        }
    }

}
