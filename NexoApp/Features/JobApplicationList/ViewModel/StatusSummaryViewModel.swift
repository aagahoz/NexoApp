//
//  StatusSummaryViewModel.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 18.01.2026.
//

import UIKit

import UIKit

struct StatusSummaryViewModel: Hashable {
    let items: [StatusSummaryItem]

    init(applications: [JobApplication]) {
        let counts = Dictionary(grouping: applications, by: { $0.status })
            .mapValues { $0.count }

        self.items = JobApplicationStatus.allCases.map { status in
            StatusSummaryItem(status: status, count: counts[status, default: 0])
        }
    }
}
