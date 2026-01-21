//
//  AddJobApplicationViewController.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 18.01.2026.
//

import UIKit

final class AddJobApplicationViewController: UIViewController {

    private let viewModel: AddJobApplicationViewModel

    // MARK: - UI

    private let titleField = UITextField()
    private let companyField = UITextField()
    private let statusControl = UISegmentedControl()
    private let saveButton = UIButton(type: .system)

    // MARK: - Init

    init(viewModel: AddJobApplicationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Add Application"

        setupUI()
        bind()
    }

    // MARK: - UI Setup

    private func setupUI() {
        titleField.placeholder = "Job title"
        titleField.borderStyle = .roundedRect

        companyField.placeholder = "Company"
        companyField.borderStyle = .roundedRect

        JobApplicationStatus.allCases.forEach {
            statusControl.insertSegment(
                withTitle: $0.displayTitle,
                at: statusControl.numberOfSegments,
                animated: false
            )
        }
        statusControl.selectedSegmentIndex = 0

        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            titleField,
            companyField,
            statusControl,
            saveButton
        ])
        stack.axis = .vertical
        stack.spacing = 16

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Actions

    @objc private func saveTapped() {
        guard
            let title = titleField.text, !title.isEmpty,
            let company = companyField.text, !company.isEmpty
        else {
            return
        }

        let status = JobApplicationStatus.allCases[statusControl.selectedSegmentIndex]

        Task {
            await viewModel.save(
                title: title,
                company: company,
                status: status
            )
        }
    }

    // MARK: - Binding

    private func bind() {
        viewModel.onStateChange = { [weak self] state in
            switch state {
            case .saving:
                self?.saveButton.isEnabled = false

            case .success:
                self?.navigationController?.popViewController(animated: true)

            case .error(let message):
                print(message)
                self?.saveButton.isEnabled = true

            case .idle:
                break
            }
        }
    }
}
