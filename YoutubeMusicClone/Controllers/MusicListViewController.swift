//
//  MusicListTableViewController.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/07/19.
//

import UIKit
import Foundation
import SnapKit

class MusicListViewController: UIViewController {
    
    var musicListTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MusicPlayerSingleton.shared.music.bind { music in
            DispatchQueue.main.async {
                self.musicListTableView.reloadData()
            }
        }
        
        musicListTableView.delegate = self
        musicListTableView.dataSource = self
        
        
        view.addSubview(musicListTableView)

        musicListTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        musicListTableView.reloadData()
    }
    
}

extension MusicListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MusicPlayerSingleton.shared.music.value?.resultCount ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        cell.textLabel?.text = MusicPlayerSingleton.shared.music.value?.results[indexPath.row].trackName

        return cell
    }


}

extension MusicListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MusicPlayerSingleton.shared.didSelectedMusicAt(indexPath: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
            let deleteAction = UIContextualAction(style: .destructive, title: "delete") { action, view, completion in
                completion(true)
                MusicPlayerSingleton.shared.removeMusicAt(indexPath: indexPath.row)
                self.musicListTableView.reloadData()
            }
            
            deleteAction.image = UIImage(systemName: "trash")
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            
            configuration.performsFirstActionWithFullSwipe = true
            
            return configuration
        
    }
    
}
