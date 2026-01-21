//
//  StatusSummaryViewModel.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 18.01.2026.
//

import UIKit

final class StatusSummaryViewModel {

    let items: [StatusSummaryItem]

    init(applications: [JobApplication]) {
        let grouped = Dictionary(grouping: applications, by: { $0.status })

        self.items = JobApplicationStatus.allCases.map { status in
            StatusSummaryItem(
                status: status,
                count: grouped[status]?.count ?? 0
            )
        }
    }
}
