//
//  JobDetailViewController.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 11.01.2026.
//

import UIKit

final class JobDetailViewController: UIViewController {

    private let job: Job

    init(job: Job) {
        self.job = job
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = job.title
    }
}
