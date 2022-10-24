//
//  String+deHTMLize.swift
//  vvp
//
//  Created by Fabio Mauersberger on 02.10.22.
//

import Foundation
import UIKit
import WPKit

extension String {
    // Yes, I would've really liked to simply use the `NSAttributedString` initializer, but...
    // ths doesnt take care of dark mode and appearance customization. This eats a LOT of performance tho... Need to implement a way of caching this.
    public func deHTMLize(optimizedFor width: CGFloat = UIScreen.main.bounds.width) -> NSAttributedString {
        var cleaned = self
        
        // as UIKit doesnt have NSAttributedString.DocumentAttributeKey.excludedElements, everything that is not relevant has to be filtered out by hand (heavy calculation go brrr)
        // because the parser cant be reached using public APIs
        while
            let iframeStart = cleaned.range(of: "<iframe"),
            let iframeEnd = cleaned.range(of: "</iframe>") {
            cleaned.removeSubrange(iframeStart.lowerBound..<iframeEnd.upperBound)
        }
        
        while
            let imgStart = cleaned.range(of: "<img src="),
            let imgEnd = cleaned.range(of: "/>", range: Range(uncheckedBounds: (imgStart.upperBound, cleaned.endIndex))),
            let urlStart = cleaned[imgStart.lowerBound...imgEnd.upperBound].range(of: "src=\""),
            let urlEnd = cleaned[imgStart.lowerBound...imgEnd.upperBound].range(of: "\"", range: Range(uncheckedBounds: (urlStart.upperBound, imgEnd.lowerBound))),
            let url = URL(string: String(cleaned[urlStart.upperBound..<urlEnd.lowerBound])) {
            wplog("Found URL in post: ", url.absoluteString)
            cleaned.replaceSubrange(imgStart.lowerBound..<imgEnd.upperBound, with: PersistenceManager.shared.urlForRemote(url).absoluteString)
            PersistenceManager.shared.download(url) { _ in } // Ensure that the image is downloaded.
            
        }
        
        let new = try! NSMutableAttributedString(
            data: Data(("""
                        <!doctype html>
                        <html>
                        <head>
                        <style>
                            img {
                                max-width: \(width)px;
                                height: auto;
                                text-align:center;
                            }
                        </style>
                        <style>
                            body {
                                font-family: 'Source Sans 3', sans-serif;
                                font-size: \(Settings.shared.fontSize > 17 ? Settings.shared.fontSize : 17)px;
                                color: \(NSAttributedString.targetFontColor);
                            }
                        </style>
                        </head>
                        <body>
                        """ + cleaned + """
                        </body>
                       </html>
                       """).utf8
            ),
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ], documentAttributes: nil)
        return new
    }
    
    /**
     IMPORTANT: RANGES NEED TO GET RECALCULATED IF ONLY PARTS GET REMOVED
     TODO: build for usage in ``deHTMLize(optimizedFor:)``*/
    public func urls(in tags: [String]) -> [URL] {
        var results = Array<URL>()
        for tag in tags {
            var cleaned = self
            while
                let urlStart = cleaned.range(of: tag + "=\""),
                let urlEnd = cleaned.range(of: "\"", range: Range(uncheckedBounds: (urlStart.upperBound, cleaned.endIndex))) {
                if let url = URL(string: String(cleaned[urlStart.upperBound..<urlEnd.lowerBound])) {
                    results.append(url)
                }
                cleaned.removeSubrange(urlStart.lowerBound..<urlEnd.upperBound)
            }
        }
        return results
    }
}

extension NSAttributedString {
    static var targetFontColor: String {
        if #available(iOS 13, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark ? "#CCCCCC" : "#000000"
        } else {
            return "#000000"
        }
    }
}
