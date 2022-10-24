//
//  NewsView.swift
//  vvp
//
//  Created by Fabio Mauersberger on 17.10.22.
//

import Foundation
import WPKit
import UIKit
//import SafariServices

class NewsView: UIViewController, UITextViewDelegate {
    var post: WPPost?
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var published: UILabel!
    @IBOutlet weak var author: UIButton!
    @IBOutlet weak var articleText: UITextView!
    
    @IBAction func sharePost(_ sender: Any) {
        
        guard let item = post?.link else { return }
        wplog("Share initialized with ", item.absoluteString)
        let activityVC = UIActivityViewController(activityItems: [item] as [Any], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
        
        if #available(iOS 13, *) {
            activityVC.activityItemsConfiguration = [
                UIActivity.ActivityType.message
            ] as? UIActivityItemsConfigurationReading
            activityVC.isModalInPresentation = true
        }
        present(activityVC, animated: true)
    }
    
    override func viewDidLoad() {
        if let post = post {
            headline.text = post.title?.rendered.deHTMLize().string.uppercased()
            articleText.attributedText = post.content?.rendered.deHTMLize(optimizedFor: self.articleText.bounds.width)
            if let url = post._embedded?.wp_featuredmedia.first?.media_details?.sizes.large.source_url {
                PersistenceManager.shared.download(url) { result in
                    DispatchQueue.main.async {
                        self.thumbnail.image = UIImage(contentsOfFile: result.path)
                    }
                }
            }
            
            author.setAttributedTitle(NSAttributedString(string: post._embedded?.author.first?.name ?? "", attributes: [.underlineStyle: NSUnderlineStyle.thick]), for: .normal) 
            
            if let date = post.date_gmt {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy"
                published.text = NSLocalizedString("published on", comment: "publishedDate") + " " + formatter.string(from: date)
            } else {
                published.text = "No date available!"
            }
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        headline.text = post?.title?.rendered.deHTMLize().string.uppercased()
        articleText.attributedText = post?.content?.rendered.deHTMLize(optimizedFor: self.articleText.bounds.width)
    }
}
