//
//  SettingsViewController.swift
//  DocumentApp
//
//  Created by Никита Морозов on 05.08.2026.
//

import UIKit

final class SettingsViewController: UITableViewController {

    private let authService: AuthServiceProtocol

    private enum Row: Int, CaseIterable {
        case sortAscending = 0
        case changePassword
    }

    private var settingsManager: SettingsManagerProtocol = SettingsManager()

    init(authService: AuthServiceProtocol) {
        self.authService = authService
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let row = Row(rawValue: indexPath.row) else { return cell }

        var content = cell.defaultContentConfiguration()

        switch row {
        case .sortAscending:
            content.text = "A-Z Sort"
            cell.accessoryType = .none
            let sw = UISwitch()
            sw.isOn = settingsManager.isAscendingSort
            sw.addTarget(self, action: #selector(sortSwitchChanged(_:)), for: .valueChanged)
            cell.accessoryView = sw
        case .changePassword:
            content.text = "Change password"
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = nil
        }

        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = Row(rawValue: indexPath.row) else { return }

        switch row {
        case .sortAscending:
            break
        case .changePassword:
            presentChangePasswordScreen()
        }
    }


    @objc private func sortSwitchChanged(_ sender: UISwitch) {
        settingsManager.isAscendingSort = sender.isOn
    }

    private func presentChangePasswordScreen() {
        let vc = AuthViewController(authService: authService, mode: .changePassword)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}
