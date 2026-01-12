//
//  JobListViewState.swift
//  Nexo-App-UIKit
//
//  Created by Agah Ozdemir on 11.01.2026.
//

enum JobListViewState {
    case loading
    case empty
    case loaded(jobs: [Job])
    case error(message: String, retry: (() -> Void)? = nil)
}
