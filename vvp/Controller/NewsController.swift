//
//  NewsController.swift
//  vvp
//
//  Created by Fabio Mauersberger on 27.08.22.
//

import Foundation
import UIKit
import WPKit


class NewsController: UITableViewController {
    
    @IBOutlet weak var categoryView: UICollectionView!
    private var categoryViewDelegate: CategoryDelegate?
    
    override func viewDidLoad() {
        let imageView = UIImageView(image: UIImage(named: "LaunchScreen-logo"))
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        
        PersistenceManager.shared.posts = PersistenceManager.shared.getpostDB()
        tableView.dataSource = PersistenceManager.shared
        
        
        self.categoryViewDelegate = CategoryDelegate()
        self.categoryViewDelegate?.filterType = .category
        self.categoryViewDelegate?.categories = NSLocalizedString("all", comment: "all") + Array(Set(PersistenceManager.shared.posts.flatMap({$0._embedded?.wp_term.filter({$0.taxonomy == .category}).map({$0.name}) ?? []}))).sorted()
        
        self.categoryView.delegate = self.categoryViewDelegate
        self.categoryView.dataSource = self.categoryViewDelegate
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show article" {
            (segue.destination as! NewsView).post = PersistenceManager.shared.posts[self.tableView.indexPathForSelectedRow!.row]
            wplog("Clicked on post for ", PersistenceManager.shared.posts[self.tableView.indexPathForSelectedRow!.row].id)
        }
        if segue.identifier == "Show category" {
            
        }
    }
    
    @objc
    func handleRefreshControl() {
        PersistenceManager.shared.fetchPosts(limit: 10) { newPostCount in
            if newPostCount > 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
}

extension NewsController {
    
    @IBAction func categoryChanged(_ sender: Any) {
        if
            let sender = sender as? UIButton,
            let filter = sender.titleLabel?.text?.components(separatedBy: .whitespaces).filter({!$0.isEmpty}).joined(separator: " ") {
            if filter == NSLocalizedString("all", comment: "all") && self.categoryViewDelegate?.filterType == .author { self.categoryViewDelegate?.filterType = .category }
            PersistenceManager.shared.posts = PersistenceManager.shared.getpostDB()
                .filter({
                    filter == NSLocalizedString("all", comment: "all") || filter == NSLocalizedString("author missing", comment: "author missing notice")
                    ? true
                    : categoryViewDelegate?.filterType == .category
                    ? $0._embedded?.wp_term.contains(where: {$0.name == filter}) ?? false
                    : ($0._embedded?.author ?? []).contains(where: {$0.name == filter})
                })
                .sorted(by: {$0.modified_gmt > $1.modified_gmt})
            wplog("Filter changed, now displaying ", PersistenceManager.shared.posts.count, " posts.")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func authorTabbed(_ sender: Any) {
        if let sender = sender as? UIButton, let author = sender.attributedTitle(for: .normal)?.string.components(separatedBy: .whitespaces).filter({!$0.isEmpty}).joined(separator: " ") {
            self.categoryViewDelegate?.categories = [NSLocalizedString("all", comment: "all"), author]
            self.categoryViewDelegate?.filterType = .author
            self.categoryView.reloadData()
            
            let avc = UIAlertController(title: NSLocalizedString("about", comment: "about author") + " " + author, message: PersistenceManager.shared.getpostDB().lazy.first(where: {$0._embedded?.author.first?.name == author})?._embedded?.author.first?.description, preferredStyle: .alert)
            avc.addAction(UIAlertAction(title: NSLocalizedString("filter by author", comment: "filter action"), style: .default, handler: { action in
                if action.isEnabled {
                    self.categoryChanged(sender)
                }
            }))
            avc.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel action"), style: .cancel))
            self.present(avc, animated: true)
        }
    }
}

extension PersistenceManager: UITableViewDataSourcePrefetching, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        for path in indexPaths {
            let post = posts[path.row]
            PersistenceManager.shared.getViewcount(for: post) { _ in }
            if let url = post._embedded?.wp_featuredmedia.first?.media_details?.sizes.large.source_url {
                PersistenceManager.shared.download(url) { _ in }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.isEmpty {
            let emptyLabel = UILabel(frame: CGRect(origin: .zero, size: tableView.bounds.size))
            emptyLabel.text = NSLocalizedString("No posts available, please check your internet connection.\n\nPull down to try again.", comment: "empty postDB notice")
            emptyLabel.textAlignment = .center
            emptyLabel.lineBreakMode = .byWordWrapping
            emptyLabel.numberOfLines = 0
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = .none
            tableView.separatorStyle = .singleLine
        }
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsEntry", for: indexPath) as! NewsEntry
        let post = posts[indexPath.row]
        
        cell.headline.attributedText = post.title?.rendered.deHTMLize()
        cell.author.setAttributedTitle(NSAttributedString(string: post._embedded?.author.first?.name ?? NSLocalizedString("author missing", comment: "author missing notice"), attributes: [.underlineStyle: NSUnderlineStyle.single]), for: .normal)
        
        if let date = post.date_gmt {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            cell.date.text = formatter.string(from: date)
        } else {
            cell.date.text = "No date available!"
        }
        
        if let viewcount = PersistenceManager.shared.getViewcount(for: post)?.description {
            cell.views.text = viewcount
        } else {
            PersistenceManager.shared.getViewcount(for: post) { _ in
                DispatchQueue.main.async {
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
        
        if let url = post._embedded?.wp_featuredmedia.first?.media_details?.sizes.large.source_url {
            if let image = UIImage(contentsOfFile: PersistenceManager.shared.urlForRemote(url).path) {
                cell.thumbnail.image = image
                
            } else {
                PersistenceManager.shared.download(url) { _ in
                    DispatchQueue.main.async {
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
        }
        return cell
    }
}
