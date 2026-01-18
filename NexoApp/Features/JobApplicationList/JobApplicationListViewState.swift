//
//  JobApplicationListViewState.swift
//  Nexo-App-UIKit
//
//  Created by Agah Ozdemir on 11.01.2026.
//

enum JobApplicationListViewState {
    case loading
    case empty
    case loaded(jobApplications: [JobApplication])
    case error(message: String, retry: (() -> Void)? = nil)
}
