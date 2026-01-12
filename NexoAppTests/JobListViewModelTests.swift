//
//  JobListViewModelTests.swift
//  NexoAppTests
//
//  Created by Agah Ozdemir on 12.01.2026.
//

import XCTest
@testable import NexoApp

@MainActor
final class JobListViewModelTests: XCTestCase {

    private var viewModel: JobListViewModel!
    private var repository: FakeJobRepository!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        // Başlangıçta repository her zaman 1 iOS Developer job döndürecek şekilde ayarlanıyor
        repository = FakeJobRepository(
            jobsToReturn: [
                Job(id: 1, title: "iOS Developer", company: "Nexo")
            ]
        )
        viewModel = JobListViewModel(repository: repository)
    }

    override func tearDown() {
        viewModel = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Basic Loading Tests

    /// Repository başarılı bir job listesi döndürdüğünde
    /// ViewModel state'i .loaded(jobs:) olmalıdır.
    func test_load_whenRepositoryReturnsJobs_setsLoadedStateWithJobs() async {
        await viewModel.load()

        switch viewModel.state {
        case .loaded(let jobs):
            XCTAssertEqual(jobs.count, 1)
            XCTAssertEqual(jobs.first?.title, "iOS Developer")
        default:
            XCTFail("Expected loaded state with jobs")
        }
    }

    /// load() çağrısı sırasında önce .loading, sonra .loaded state'leri yayılmalıdır.
    func test_load_emitsLoadingThenLoadedStates() async {
        let repository = FakeJobRepository(jobsToReturn: [Job(id: 1, title: "iOS Developer", company: "Nexo")])
        let viewModel = JobListViewModel(repository: repository)

        var receivedStates: [JobListViewState] = []
        viewModel.onStateChange = { state in
            receivedStates.append(state)
        }

        await viewModel.load()

        XCTAssertEqual(receivedStates.count, 2)
        if case .loading = receivedStates[0] {} else { XCTFail("Expected first state to be loading") }
        if case .loaded = receivedStates[1] {} else { XCTFail("Expected second state to be loaded") }
    }

    /// Repository boş bir liste döndürdüğünde önce .loading, sonra .empty state'i yayılmalıdır.
    func test_load_emitsLoadingThenEmptyStates() async {
        let repository = FakeJobRepository(jobsToReturn: [])
        let viewModel = JobListViewModel(repository: repository)

        var receivedStates: [JobListViewState] = []
        viewModel.onStateChange = { state in
            receivedStates.append(state)
        }

        await viewModel.load()

        XCTAssertEqual(receivedStates.count, 2)
        if case .loading = receivedStates[0] {} else { XCTFail("Expected first state to be loading") }
        if case .empty = receivedStates[1] {} else { XCTFail("Expected second state to be empty") }
    }

    /// Network hatası durumunda state .error(message:) olmalıdır.
    func test_load_whenNetworkError_setsNetworkErrorMessage() async {
        let repository = FakeJobRepository(jobsToReturn: [], errorToThrow: .network)
        let viewModel = JobListViewModel(repository: repository)

        await viewModel.load()

        if case .error(let message) = viewModel.state {
            XCTAssertEqual(message, "Network connection failed")
        } else {
            XCTFail("Expected error state")
        }
    }

    // MARK: - Retry Flow Tests

    /// İlk load hata döndürdüğünde, retry sonrası loading → loaded akışı kontrol edilir.
    func test_retryAfterError_emitsCorrectStateSequenceWithData() async {
        let repository = FakeJobRepository(
            jobsToReturn: [Job(id: 1, title: "iOS Developer", company: "Nexo")],
            errorToThrow: .network
        )
        let viewModel = JobListViewModel(repository: repository)

        var receivedStates: [JobListViewState] = []
        viewModel.onStateChange = { state in
            receivedStates.append(state)
        }

        // İlk load → hata
        await viewModel.load()
        // Retry → başarılı veri
        await viewModel.load()

        XCTAssertEqual(receivedStates.count, 4)

        // 0 → loading
        if case .loading = receivedStates[0] {} else { XCTFail("Expected first state to be loading") }

        // 1 → error
        if case .error(let message) = receivedStates[1] {
            XCTAssertEqual(message, "Network connection failed")
        } else { XCTFail("Expected error state") }

        // 2 → loading (retry)
        if case .loading = receivedStates[2] {} else { XCTFail("Expected loading state after retry") }

        // 3 → loaded(jobs)
        if case let .loaded(jobs) = receivedStates[3] {
            XCTAssertEqual(jobs.count, 1)
            XCTAssertEqual(jobs.first?.company, "Nexo")
        } else { XCTFail("Expected loaded state with jobs after retry") }
    }

    /// Retry sonrası loaded(jobs:) state'i üzerinden veri doğrulaması
    func test_retryAfterError_emitsLoadingThenLoadedStates_withJobs() async {
        let expectedJobs = [Job(id: 1, title: "iOS Developer", company: "Nexo")]

        let repository = FakeJobRepository(jobsToReturn: expectedJobs, errorToThrow: .network)
        let viewModel = JobListViewModel(repository: repository)

        var receivedStates: [JobListViewState] = []
        viewModel.onStateChange = { state in
            receivedStates.append(state)
        }

        await viewModel.load() // hata
        await viewModel.load() // retry

        XCTAssertEqual(receivedStates.count, 4)

        XCTAssertTrue({ if case .loading = receivedStates[0] { return true } else { return false } }())
        XCTAssertTrue({ if case .error = receivedStates[1] { return true } else { return false } }())
        XCTAssertTrue({ if case .loading = receivedStates[2] { return true } else { return false } }())
        XCTAssertTrue({
            if case let .loaded(jobs) = receivedStates[3] {
                return jobs == expectedJobs
            } else { return false }
        }())
    }
}
