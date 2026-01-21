//
//  JobApplicationListViewModel.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 11.01.2026.
//

@MainActor
final class JobApplicationListViewModel {

    private let repository: JobApplicationRepository

    private(set) var state: JobApplicationListViewState = .loading {
        didSet { onStateChange?(state) }
    }

    var onStateChange: ((JobApplicationListViewState) -> Void)?
    var onAddTapped: (() -> Void)?
    var onJobApplicationSelected: ((JobApplication) -> Void)?

    init(repository: JobApplicationRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            let jobApplications = try await repository.fetchJobApplications()
            state = jobApplications.isEmpty ? .empty : .loaded(jobApplications: jobApplications)
        } catch let error as JobApplicationError {
            state = .error(message: mapErrorToMessage(error)) { [weak self] in
                Task { await self?.load() }
            }
        } catch {
            state = .error(message: "Unexpected error") { [weak self] in
                Task { await self?.load() }
            }
        }
    }
    
    func deleteJobApplication(at index: Int) async {
        guard case let .loaded(jobApplications) = state,
              jobApplications.indices.contains(index)
        else { return }

        let job = jobApplications[index]

        do {
            try await repository.deleteJobApplication(id: job.id)
            await load()
        } catch {
            state = .error(message: "Could not delete application")
        }
    }

    func didSelectJobApplication(at index: Int) {
        guard case let .loaded(jobApplications) = state,
              jobApplications.indices.contains(index)
        else { return }
        onJobApplicationSelected?(jobApplications[index])
    }
}

private func mapErrorToMessage(_ error: JobApplicationError) -> String {
    switch error {
    case .network: return "Network connection failed"
    case .unauthorized: return "You are not authorized"
    case .unknown: return "Something went wrong"
    }
}
