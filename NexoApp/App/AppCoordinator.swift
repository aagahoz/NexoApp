//
//  AppCoordinator.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 14.01.2026.
//

import UIKit

final class AppCoordinator: Coordinator {

    var navigationController: UINavigationController
    private var childCoordinators: [Coordinator] = []
    
    private let jobApplicationRepository: JobApplicationRepository

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
//        self.jobApplicationRepository = MockJobApplicationRepository()

//        self.jobApplicationRepository = LocalJobApplicationRepository(localDataSource: CoreDataJobApplicationLocalDataSource())
        
        let session = MockAuthenticatedSessionProvider()
        let remoteDataSource = FirebaseJobApplicationRemoteDataSource()
        self.jobApplicationRepository = RemoteJobApplicationRepository(
            remoteDataSource: remoteDataSource,
            session: session
        )
        
        
    }

    func start() {
        showJobApplicationList()
    }

    private func showJobApplicationList() {
        let jobApplicationListCoordinator = JobApplicationListCoordinator(
            navigationController: navigationController,
            repository: jobApplicationRepository
        )

        childCoordinators.append(jobApplicationListCoordinator)
        jobApplicationListCoordinator.start()
    }
}
                             
