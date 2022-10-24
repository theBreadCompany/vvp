//
//  DownloadManager.swift
//  vvp
//
//  Created by Fabio Mauersberger on 28.08.22.
//

import Foundation
import WPKit
import SystemConfiguration
import UIKit

class PersistenceManager: NSObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case continueArchiving, root, files, viewCountDB, name, postDB
    }
    
    required init(from decoder: Decoder) throws {
        let container       = try decoder.container(keyedBy: CodingKeys.self)
        self.name           = try container.decode(String.self, forKey: CodingKeys.name)
        self.root           = try container.decode(URL.self, forKey: CodingKeys.root)
        self.files          = try container.decode(Dictionary<URL,URL>.self, forKey: CodingKeys.files)
        self.postDB         = try container.decode(Array<WPPost>.self, forKey: CodingKeys.postDB)
        self.viewCountDB    = try container.decode(Dictionary<Int,Dictionary<Int,Date>>.self, forKey: CodingKeys.viewCountDB)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: CodingKeys.name)
        try container.encode(self.root, forKey: CodingKeys.root)
        try container.encode(self.files, forKey: CodingKeys.files)
        try container.encode(self.postDB, forKey: CodingKeys.postDB)
        try container.encode(viewCountDB, forKey: CodingKeys.viewCountDB)
    }
    
    
    public static var shared = PersistenceManager(name: "shared")
    
    private var continueArchiving = false
    private var root: URL
    private var files: [URL:URL]
    private var viewCountDB: [Int: [Int: Date]]
    public var name: String
    private var postDB: Array<WPPost>
    public var posts: Array<WPPost> = []
    
    private var apiManager: APIManager {
        APIManager.shared
    }
    
    public init(root: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!, name: String) {
        self.root = root
        self.files = [:]
        self.name = name
        self.postDB = []
        self.viewCountDB = Dictionary<Int, Dictionary<Int, Date>>()
        
        wplog("Trying to recover persistence manager '", name, " from savestate.")
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: root.path, isDirectory: &isDir) && isDir.boolValue &&
            FileManager.default.fileExists(atPath: root.appendingPathComponent("PersistenceManager_" + name).appendingPathExtension("json").path, isDirectory: nil) {
            if let data = try? Data(contentsOf: root.appendingPathComponent("PersistenceManager_" + name).appendingPathExtension("json")), let pman = try? JSONDecoder().decode(Self.self, from: data) {
                wplog("Recovery successful, found ", pman.files.count, " files and ", pman.postDB.count, " postDB.")
                self.files = pman.files
                self.postDB = Array(Set(pman.postDB))
                self.viewCountDB = pman.viewCountDB
                wplog("Found ", self.viewCountDB.count, " view entries")
            } else {
                wplog("Recovery failed, there was either no savestate or its contents were messed up.")
            }
        }
        super.init()
        //self.fetchPosts(limit: 10, completionHandler: {_ in})
    }
    
    public func save() throws {
        var isDir: ObjCBool = false
        wplog("Saving PersistenceManager_", name, "...")
        wplog("Checking if its root dir exists...")
        if FileManager.default.fileExists(atPath: root.path, isDirectory: &isDir) && isDir.boolValue {
            wplog("root exists.")
        } else {
            wplog("root does not exist! Trying to create...")
            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
            wplog("Sucessfully created root.")
        }
        wplog("Trying to save to root...")
        try JSONEncoder().encode(self).write(to: root.appendingPathComponent("PersistenceManager_" + name).appendingPathExtension("json"))
        wplog("Saving succeeded!")
    }
    
    
    /**
     Basically the same as ``download(_:completionHandler:)``, but without the downloading aspect.
     The ``AttributedString.deHTMLize(optimizedFor:)`` function uses this to point image sources to a local URL instead of a remote one.
     */
    public func urlForRemote(_ url: URL) -> URL {
        root.appendingPathComponent(url.lastPathComponent)
    }
    
    /**
     Download a resource and use it as soon as it is available locally.
     */
    public func download(_ url: URL, completionHandler: @escaping (URL) -> Void) {
        wplog("Searching for resource ", url.absoluteString, "...")
        if let ressource = files[url] {
            wplog("Found resource ", url.absoluteString, "!")
            completionHandler(ressource)
        } else {
            wplog("Couldnt find resource, ", url.absoluteString, " locally, trying to download...")
            let req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            let task = URLSession.shared.dataTask(with: req, completionHandler: { data, _, error in
                guard let data = data, error == nil else {
                    wplog("Failed to download ", url.absoluteString, "!")
                    return
                }
                guard let target = URL(string: url.lastPathComponent, relativeTo: self.root) else {
                    wplog("Failed to build target location for ", url.absoluteString, "!")
                    return
                }
                guard let _ = try? data.write(to: target) else {
                    wplog("Failed to save ", url.lastPathComponent, " at ", target.absoluteString, "!")
                    return
                }
                wplog("Downloading ", url.absoluteString, " succeeded, returning executing complectionHandler!")
                self.files.updateValue(target, forKey: url)
                completionHandler(target)
            })
            task.resume()
        }
    }
    
    public func add(_ postDB: [WPPost]) {
        wplog("Adding ", postDB.count, " postDB...")
        postDB.forEach { post in
            if !self.postDB.contains(where: {post.id == $0.id}) {
                self.postDB.append(post)
                self.getViewcount(for: post) { _ in }
            }
        }
        try? self.save()
    }
    
    public func fetchPosts(limit: Int, completionHandler: @escaping (Int) -> ()) {
        if apiManager.connected {
            apiManager.wpAPI.fetchPosts(limit: limit, having: apiManager.requiredProperties) { postDB, _ in
                self.add(postDB ?? [])
                try? self.save()
                completionHandler(limit)
            }
        } else {
            completionHandler(0)
        }
    }
    
    public func getpostDB(limit: Int = -1, sortedBy: Int = 0, having category: String = "") -> [WPPost] {
        return postDB
            .filter({category.isEmpty ? true : $0._embedded?.wp_term.contains(where: {$0.name == category}) ?? false})
            .sorted(by: {($0.date_gmt ?? Date()) > ($1.date_gmt ?? Date())})
    }
    
    public func getViewcount(for post: WPPost, completionHandler: @escaping (Int) -> Void) {
        wplog("Fetching viewcount for post ", post.id)
        if
            let viewcountKVpair = viewCountDB[post.id],
            let viewcount = viewcountKVpair.keys.first,
            let lastUpdated = viewcountKVpair.values.first,
            lastUpdated.timeIntervalSinceNow > -3600 {
            wplog("Found viewcount! Returning to completionHandler...")
            completionHandler(viewcount)
        } else {
            wplog("Couldn't find viewcount! Fetching...")
            apiManager.wpAPI.fetchViewcount(of: post) { views, error in
                if let views = views, error == nil {
                    self.viewCountDB.updateValue([views:Date()], forKey: post.id)
                    try? self.save()
                } else {
                    completionHandler(0)
                }
            }
        }
    }
    
    public func getViewcount(for post: WPPost) -> Int? {
        viewCountDB[post.id]?.keys.first
    }
    
    func archiveActivationSwitchToggled() {
        wplog("Archiving intialized...")
        continueArchiving = true
        DispatchQueue.global(qos: .background).async { [self] in
            while self.postDB.count < apiManager.wpAPI.availablePosts && self.continueArchiving {
                self.add((try? apiManager.wpAPI.fetchPosts(limit: 100, having: apiManager.requiredProperties, offset: self.postDB.count)) ?? [])
            }
            wplog(self.continueArchiving ? "Archiving done..." : "Got forced to stop archiving...")
            self.continueArchiving = false
        }
    }
    
    func stopArchiving() {
        wplog("Forcing archiving to stop...")
        self.continueArchiving = false
    }
    
    
    deinit {
        do {
            try self.save()
        } catch {
            wplog("Couldnt save persistent manager! Will try to recover on next init.")
        }
    }
    
}

fileprivate class APIManager {
    
    var wpAPI = WPPublicAPI(fetchAvailableCount: true)
    var requiredProperties: [WPPost.Property] = [.date_gmt, .title, .content, .excerpt, .featured_media, ._links, .categories, ._embedded, .slug, .link]
    let host = "https://www.volksverpetzer.de"
    var connected: Bool {
        let nr = SCNetworkReachabilityCreateWithName(nil, host)!
        var flag = SCNetworkReachabilityFlags()
        return SCNetworkReachabilityGetFlags(nr, &flag)
    }
    
    static public var shared = APIManager()
}
