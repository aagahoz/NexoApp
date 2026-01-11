//
//  JobListViewModel.swift
//  Nexo-App-UIKit
//
//  Created by Agah Ozdemir on 11.01.2026.
//

final class JobListViewModel {
    
    private let repository: JobRepository
    
    private(set) var state: JobListViewState = .loading {
        didSet {
            onStateChange?(state)
        }
    }
    
    var onStateChange: ((JobListViewState) -> Void)?
   
    init(repository: JobRepository) {
        self.repository = repository
    }
    
    func viewDidLoad() {
        let jobs = repository.fetchJobs()
        
        if jobs.isEmpty {
            state = .empty
        } else {
            state = .loaded(jobs: jobs)
        }
    }
}
