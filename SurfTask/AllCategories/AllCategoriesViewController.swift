//
//  AllCategoriesViewController.swift
//  SurfTask
//
//  Created by Артём Калинин on 14.09.2021.
//

import UIKit
import RealmSwift

class AllCategoriesViewController: UIViewController, UITableViewDelegate,
                                   UITableViewDataSource, UISearchBarDelegate {

    private let networkManager = NetworkManager.shared

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.rowHeight = 50
        table.frame = view.bounds
        table.separatorStyle = .none
        return table
    }()

    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.searchBarStyle = UISearchBar.Style.default
        bar.showsCancelButton = false
        bar.placeholder = " Search categories..."
        bar.sizeToFit()
        bar.isTranslucent = false
        return bar
    }()

    private let cellID = "categoryCell"

    private let jsonCategories = ["world", "science", "technology", "business",
                                     "environment", "football", "books", "music",
                                     "tv-and-radio", "artanddesign", "film", "games",
                                     "fashion", "food", "travel", "money"]

    private let displayCategories = ["🌍 World", "🔭 Science", "💻 Tech", "💼 Business",
                                        "🌿 Environment", "⚽️ Football", "📚 Books", "🎧 Music",
                                        "📺 TV & radio", "🎨 Art & design", "🎬 Film", "🎮 Games",
                                        "🕺🏼 Fashion", "🍕 Food", "✈️ Travel", "💵 Money"]

    private var filteredCategories = [String]()

    private var currentNews: [News]? {
        willSet {
            let dataChangedNotification = Notification.Name("dataChanged")
            NotificationCenter.default.post(name: dataChangedNotification,
                                            object: nil, userInfo: ["data": newValue ?? 0])
        }
    }
    private var newsToDB = [News]()

    let connectedNotification = Notification.Name("connected")
    let disconnectedNotification = Notification.Name("disconnected")
    let inNetworkNotification = Notification.Name("inNetwork")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Categories"

        searchBar.delegate = self
        navigationItem.titleView = searchBar

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.addSubview(tableView)

        filteredCategories = displayCategories

        NotificationCenter.default.addObserver(self, selector: #selector(loadDataConnected),
                                               name: inNetworkNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(loadDataConnected),
                                               name: connectedNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(loadDataDisconnected),
                                               name: disconnectedNotification, object: nil)

        ConnectionMonitor.shared.startMonitoring()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: connectedNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: disconnectedNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: inNetworkNotification, object: nil)
    }

    @objc func loadDataConnected() {
        if let news = networkManager.getNewsRealm() {
            currentNews = Array(news)
        }

        loadDataFromRequest()
        checkNewData()
    }

    @objc func loadDataDisconnected() {
        let alert = UIAlertController(title: "Oops 🤔\nSeems like you've been"
            + "disconnected from the Internet for a while.",
            message: "We will show you relevant news when you last visited the network," +
                " and update the news, when you're back online. ", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)

        if let news = networkManager.getNewsRealm() {
            currentNews = Array(news)
        }
    }

    func loadDataFromRequest() {
        self.networkManager.getNewsRequest(self.jsonCategories) { actualNews in
            if let data = actualNews {
                let sortedData = data.sorted { $0.sectionId ?? "" < $1.sectionId ?? "" }
                self.newsToDB = sortedData
            }
        }
    }

    func checkNewData() {
        if currentNews != newsToDB && !newsToDB.isEmpty {
            currentNews = newsToDB
            saveToRealm(newsToDB)
        }
    }

    func saveToRealm(_ news: [News]) {
        do {
            let realm = try Realm()

            try realm.write {
                realm.deleteAll()
                realm.add(news)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCategories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellID)

        cell.textLabel?.text = filteredCategories[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedName = filteredCategories[indexPath.row]
        var indexInAllNames = Int()

        for name in displayCategories where name == selectedName {
            indexInAllNames = displayCategories.firstIndex(of: name)!
        }

        let newsToSend = currentNews?.filter {
            $0.sectionId == jsonCategories[indexInAllNames]
        }

        let categoryNewsViewController = CategoryNewsViewController()
        categoryNewsViewController.title = displayCategories[indexInAllNames]
        categoryNewsViewController.category = jsonCategories[indexInAllNames]
        categoryNewsViewController.news = newsToSend

        navigationController?.pushViewController(categoryNewsViewController, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String) {
        searchBar.showsCancelButton = true

        filteredCategories.removeAll(keepingCapacity: false)

        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", textSearched)
        let array = (displayCategories as NSArray).filtered(using: searchPredicate)

        guard let results = array as? [String] else { return }
        filteredCategories = results

        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false

        searchBar.text = ""
        filteredCategories = displayCategories

        tableView.reloadData()
    }
}
