//
//  VideoListViewController.swift
//  Liftoff
//
//  Created by Blackboxed on 2017-05-09.
//  Copyright © 2017 Blackboxed. All rights reserved.
//

import UIKit

final class VideoListViewController: UITableViewController {
    
    // MARK: UIViewController
    
    private var videos = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // List of videos
        do {
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            let mp4s = directoryContents.filter{ $0.pathExtension == "mp4" }
            videos = mp4s.filter({ FileManager.default.fileExists(atPath: $0.deletingPathExtension().appendingPathExtension("miiyoo").path) })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let url = videos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Video", for: indexPath)
        cell.textLabel?.text = url.deletingPathExtension().lastPathComponent
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = videos[indexPath.row]
        let playerViewController = storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        playerViewController.videoURL = url
        let navigationController = UINavigationController(rootViewController: playerViewController)
        present(navigationController, animated: true, completion: nil)
    }
}
