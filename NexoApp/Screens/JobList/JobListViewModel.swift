//
//  JobListViewModel.swift
//  Nexo-App-UIKit
//
//  Created by Agah Ozdemir on 11.01.2026.
//

@MainActor
final class JobListViewModel {

    private let repository: JobRepository

    private(set) var state: JobListViewState = .loading {
        didSet { onStateChange?(state) }
    }

    var onStateChange: ((JobListViewState) -> Void)?
    var onJobSelected: ((Job) -> Void)?  // <- yeni

    init(repository: JobRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            let jobs = try await repository.fetchJobs()
            state = jobs.isEmpty ? .empty : .loaded(jobs: jobs)
        } catch let error as JobError {
            state = .error(message: mapErrorToMessage(error)) { [weak self] in
                Task { await self?.load() }
            }
        } catch {
            state = .error(message: "Unexpected error") { [weak self] in
                Task { await self?.load() }
            }
        }
    }

    func didSelectJob(at index: Int) {
        guard case let .loaded(jobs) = state,
              jobs.indices.contains(index)
        else { return }
        onJobSelected?(jobs[index])
    }
}

private func mapErrorToMessage(_ error: JobError) -> String {
    switch error {
    case .network: return "Network connection failed"
    case .unauthorized: return "You are not authorized"
    case .unknown: return "Something went wrong"
    }
}
