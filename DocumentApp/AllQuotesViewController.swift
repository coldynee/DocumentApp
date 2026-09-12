//
//  AllQuotesViewController.swift
//  DocumentApp
//
//  Created by Никита Морозов on 13.09.2026.
//

import UIKit
import Combine

final class AllQuotesViewController: UIViewController {
    private let viewModel: AllQuotesViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "QuoteCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    init(viewModel: AllQuotesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Все цитаты"
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        bindViewModel()
        viewModel.loadQuotes()
    }
    
    private func bindViewModel() {
        viewModel.$quotes.sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &cancellables)
    }
}

extension AllQuotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        let quote = viewModel.quotes[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = quote.text
        content.secondaryText = quote.createdAt.formatted(date: .abbreviated, time: .shortened)
        cell.contentConfiguration = content
        return cell
    }
}
