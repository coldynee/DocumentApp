//
//  ViewController.swift
//  DocumentApp
//
//  Created by Никита Морозов on 05.08.2026.
//

import UIKit

final class DocumentsViewController: UIViewController {

    private let fileManagerService: FileManagerServiceProtocol
    private let directoryURL: URL
    private var items: [ContentItem] = []
    private let cellIdentifier = "ContentCell"

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        return table
    }()

    private lazy var createFolderButton = UIBarButtonItem(
        image: UIImage(systemName: "folder.badge.plus"),
        style: .plain,
        target: self,
        action: #selector(didTapCreateFolder)
    )

    private lazy var addPhotoButton = UIBarButtonItem(
        image: UIImage(systemName: "plus"),
        style: .plain,
        target: self,
        action: #selector(didTapAddPhoto)
    )

    init(fileManagerService: FileManagerServiceProtocol,
         directoryURL: URL,
         screenTitle: String? = nil) {
        self.fileManagerService = fileManagerService
        self.directoryURL = directoryURL
        super.init(nibName: nil, bundle: nil)
        self.title = screenTitle ?? directoryURL.lastPathComponent
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadContent()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItems = [addPhotoButton, createFolderButton]

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func loadContent() {
        do {
            items = try fileManagerService.contentsOfDirectory(at: directoryURL)
        } catch {
            items = []
            presentErrorAlert(error)
        }
        tableView.reloadData()
    }

    @objc private func didTapCreateFolder() {
        let alert = UIAlertController(
            title: "Create new foler",
            message: nil,
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Folder name"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self else { return }
            guard let name = alert.textFields?.first?.text else { return }

            do {
                try self.fileManagerService.createDirectory(named: name, in: self.directoryURL)
                self.loadContent()
            } catch {
                self.presentErrorAlert(error)
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(createAction)
        present(alert, animated: true)
    }

    @objc private func didTapAddPhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    private func presentErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "Eror",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension DocumentsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        cell.contentConfiguration = content

        switch item.type {
        case .folder:
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        case .file:
            cell.accessoryType = .none
            cell.selectionStyle = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            do {
                try self.fileManagerService.removeContent(at: self.items[indexPath.row].url)
                self.loadContent()
                completion(true)
            } catch {
                self.presentErrorAlert(error)
                completion(false)
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension DocumentsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = items[indexPath.row]
        guard item.type == .folder else { return }

        let folderVC = DocumentsViewController(
            fileManagerService: fileManagerService,
            directoryURL: item.url
        )
        navigationController?.pushViewController(folderVC, animated: true)
    }
}

extension DocumentsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }

        do {
            try fileManagerService.createFile(image: image, in: directoryURL)
            loadContent()
        } catch {
            presentErrorAlert(error)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
