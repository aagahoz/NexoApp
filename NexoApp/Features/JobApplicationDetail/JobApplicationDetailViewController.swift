//
//  JobApplicationDetailViewController.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 11.01.2026.
//

import UIKit

final class JobApplicationDetailViewController: UIViewController {

    private let jobApplication: JobApplication

    init(jobApplication: JobApplication) {
        self.jobApplication = jobApplication
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = jobApplication.title
    }
}
