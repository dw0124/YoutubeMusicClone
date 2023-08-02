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
        musicListTableView.register(MusicListTableViewCell.self, forCellReuseIdentifier: MusicListTableViewCell.identifier)
        
        musicListTableView.delegate = self
        musicListTableView.dataSource = self
        musicListTableView.dragInteractionEnabled = true
        musicListTableView.dragDelegate = self
        musicListTableView.dropDelegate = self
        
        view.addSubview(musicListTableView)
        
        musicListTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        MusicPlayerSingleton.shared.music.bind { music in
            DispatchQueue.main.async {
                self.musicListTableView.reloadData()
            }
            
            guard let musicResult = MusicPlayerSingleton.shared.music.value else { return }

//            for (index,music) in musicResult.results.enumerated() {
//                DataManager.shared.createMusicList(music: music, index: index)
//            }
            
        }
        //        musicListTableView.setEditing(true, animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //musicListTableView.reloadData()
    }
}

extension MusicListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MusicPlayerSingleton.shared.music.value?.results.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = musicListTableView.dequeueReusableCell(withIdentifier: MusicListTableViewCell.identifier) as? MusicListTableViewCell else {
            return UITableViewCell()
        }
        
        guard let value = MusicPlayerSingleton.shared.music.value else {
            return UITableViewCell()
        }
        
        cell.singerLabel.text = value.results[indexPath.row].artistName
        cell.titleLabel.text = value.results[indexPath.row].trackName
        cell.titleLabel.textColor = .white
        
        //cell.configure(with: value, index: indexPath.row) // 두 번째 매개변수로 artwork 이미지를 전달할 수 있습니다.
        
        // 기존 코드에서 artwork 이미지를 가져오는 비동기 로직을 처리해야 한다면 아래와 같이 하면 됩니다.
        
        if let url = URL(string: value.results[indexPath.row].artworkUrl100) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        let image = UIImage(data: data)
                        DispatchQueue.main.async {
                            cell.musicImageView.image = image
                        }
                    }
                }
            }
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(red: 0.149019599, green: 0.149019599, blue: 0.149019599, alpha: 1)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

extension MusicListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        musicListTableView.cellForRow(at: IndexPath(row: MusicPlayerSingleton.shared.currentIndex, section: 0))?.backgroundColor = UIColor(red: 0.149019599, green: 0.149019599, blue: 0.149019599, alpha: 1)
        
        MusicPlayerSingleton.shared.didSelectedMusicAt(indexPath: indexPath.row)
        musicListTableView.cellForRow(at: IndexPath(row: MusicPlayerSingleton.shared.currentIndex, section: 0))?.backgroundColor = .darkGray
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

extension MusicListViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        //dragItem.localObject = list[indexPath.row]
        //print(dragItem.localObject)
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        print(coordinator.items)
    }
}
