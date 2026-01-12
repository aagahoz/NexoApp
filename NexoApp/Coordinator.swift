//
//  Coordinator.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 12.01.2026.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func start()
}
