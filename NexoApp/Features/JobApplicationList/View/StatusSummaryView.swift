//
//  StatusSummaryView.swift
//  NexoApp
//
//  Created by Agah Ozdemir on 17.01.2026.
//

import UIKit

final class StatusSummaryView: UIView {

    private var items: [StatusSummaryItem] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(StatusCardCell.self, forCellWithReuseIdentifier: StatusCardCell.reuseIdentifier)
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func update(applications: [JobApplication]) {
        let grouped = Dictionary(grouping: applications, by: { $0.status })

        items = JobApplicationStatus.allCases.map { status in
            StatusSummaryItem(status: status, count: grouped[status]?.count ?? 0)
        }

        collectionView.reloadData()
    }
}

extension StatusSummaryView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: StatusCardCell.reuseIdentifier,
                for: indexPath
            ) as? StatusCardCell
        else { return UICollectionViewCell() }

        cell.configure(with: items[indexPath.item])
        return cell
    }
}

extension StatusSummaryView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 120, height: collectionView.bounds.height)
    }
}
