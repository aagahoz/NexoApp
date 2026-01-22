//
//  StatusSummaryViewModel.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 18.01.2026.
//

import UIKit

struct StatusSummaryViewModel: Hashable {
    let items: [StatusSummaryItem]

    init(applications: [JobApplication]) {
        let allStatuses: [JobApplicationStatus] = [.notApplied, .applied, .reviewing, .rejected, .accepted]

        let counts = Dictionary(grouping: applications, by: { $0.status })
            .mapValues { $0.count }

        self.items = allStatuses.map { status in
            StatusSummaryItem(status: status, count: counts[status, default: 0])
        }
    }
}
