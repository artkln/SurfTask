//
//  CategoryNewsViewController.swift
//  SurfTask
//
//  Created by Артём Калинин on 15.09.2021.
//

import UIKit
import RealmSwift

class CategoryNewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    lazy var tableView: UITableView = {
        let table = UITableView()
        table.rowHeight = 120
        table.frame = view.bounds
        return table
    }()

    private let cellID = "newsCell"
    var category = ""
    var news: [News]?

    private let dataChangedNotification = Notification.Name("dataChanged")

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: cellID)
        view.addSubview(tableView)

        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)),
                                               name: dataChangedNotification, object: nil)
    }

    @objc func updateUI(_ notification: Notification) {

        let newsToUpdate = notification.userInfo?["data"] as? [News]
        news = newsToUpdate?.filter {
            $0.sectionId == category
        }
        tableView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: dataChangedNotification, object: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableNews = news else { return 0 }
        return tableNews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? NewsTableViewCell
        guard let newsTableViewCell = cell else { return UITableViewCell() }
        guard let tableNews = news else { return UITableViewCell() }

        newsTableViewCell.headlineLabel.text = tableNews[indexPath.row].headline

        if let stringURL = tableNews[indexPath.row].thumbnail {
            newsTableViewCell.thumbnail = URL(string: stringURL)
        }
        return newsTableViewCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let tableNews = news else { return }
        tableView.deselectRow(at: indexPath, animated: true)

        let publicationViewController = PublicationViewController()
        publicationViewController.publication = tableNews[indexPath.row]

        navigationController?.pushViewController(publicationViewController, animated: true)
    }
}
