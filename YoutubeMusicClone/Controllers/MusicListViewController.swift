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
        
        musicListTableView.backgroundColor = UIColor(red: 0.149019599, green: 0.149019599, blue: 0.149019599, alpha: 1)
        
        MusicPlayerSingleton.shared.music.bind { music in
            DispatchQueue.main.async {
                self.musicListTableView.reloadData()
            }
        }
        
        musicListTableView.delegate = self
        musicListTableView.dataSource = self
        
//        musicListTableView.setEditing(true, animated: false)
        
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
        cell.backgroundColor = UIColor(red: 0.149019599, green: 0.149019599, blue: 0.149019599, alpha: 1)
        cell.textLabel?.text = MusicPlayerSingleton.shared.music.value?.results[indexPath.row].trackName
        cell.textLabel?.textColor = .white
        return cell
    }


}

extension MusicListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MusicPlayerSingleton.shared.didSelectedMusicAt(indexPath: indexPath.row)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        print(#function)
        
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
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if var music = MusicPlayerSingleton.shared.music.value {
            let movedMusic = music.results.remove(at: sourceIndexPath.row)
            music.results.insert(movedMusic, at: destinationIndexPath.row)
            MusicPlayerSingleton.shared.music.value = music
            MusicPlayerSingleton.shared.currentIndex = destinationIndexPath.row
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
}
