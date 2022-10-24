//
//  WPPublicAPI+Counter.swift
//  vvp
//
//  Created by Fabio Mauersberger on 01.10.22.
//

import Foundation
import WPKit

extension WPPublicAPI {
    
    internal struct WPAPICounterResult: Codable {
        
        struct Result: Codable {
            struct ValueEntry: Codable {
                var value: Int
            }
            var pageviews: ValueEntry
        }
        var results: Result
    }
    
    func fetchViewcount(of post: WPPost) throws -> Int {
        guard let req = URLRequest(host: host,
                                   path: "/counter/api/stats" + ((post.link ?? post.excerpt?.rendered.urls(in: ["href"]).first)?.path ?? "") + "/",
                                   using: .GET,
                                   with: [:]) else { throw WPError.badRequest }
        return try request(req, expected: WPAPICounterResult.self).results.pageviews.value
    }
    
    func fetchViewcount(of post: WPPost, completionHandler: @escaping (Int?, Error?) -> Void) {
        if let req = URLRequest(host: host,
                                   path: "/counter/api/stats" + ((post.link ?? post.excerpt?.rendered.urls(in: ["href"]).first)?.path ?? "") + "/",
                                   using: .GET,
                                   with: [:]) {
            request(req, expected: WPAPICounterResult.self) { result, error in
                completionHandler(result?.results.pageviews.value, error)
            }
        } else {
            completionHandler(nil, WPError.badRequest)
        }
    }
}
