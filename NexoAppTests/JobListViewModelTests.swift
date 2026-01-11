//
//  JobListViewModelTests.swift
//  NexoAppTests
//
//  Created by Agah Ozdemir on 11.01.2026.
//

import XCTest
@testable import NexoApp

final class JobListViewModelTests: XCTestCase {
    
    private var viewModel: JobListViewModel!
    private var repository: FakeJobRepository!
    
    override func setUp() {
        super.setUp()
        
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
    
    func test_viewDidLoad_whenRepositoryReturnsJobs_setsStateToLoaded() {
        // when
        viewModel.viewDidLoad()
        
        // then
        switch viewModel.state {
        case .loaded(let jobs):
            XCTAssertEqual(jobs.count, 1)
            XCTAssertEqual(jobs.first?.title, "iOS Developer")
        default:
            XCTFail("Expected state to be loaded, but got \(viewModel.state)")
        }
    }
    
    func test_viewDidLoad_triggersOnStateChangeWithLoadedState() {
        var receivedState: JobListViewState?
        
        viewModel.onStateChange = { state in
            receivedState = state
        }
        
        viewModel.viewDidLoad()
        
        switch receivedState {
        case .loaded(let jobs):
            XCTAssertEqual(jobs.count, 1)
        default:
            XCTFail("Expected loaded state to be emitted")
        }
    }
}
