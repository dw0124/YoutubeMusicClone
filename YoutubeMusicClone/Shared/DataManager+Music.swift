//
//  DataManager+Music.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/07/31.
//

import Foundation
import CoreData

extension DataManager {
    
    func toMusic() -> Result {
        let newMusic = MusicEntity(context: self.mainContext)
        return Result(
            trackId: Int(newMusic.trackId),
            trackName: newMusic.trackName ?? "",
            artistName: newMusic.artistName ?? "",
            previewUrl: newMusic.previewUrl ?? "",
            artworkUrl30: newMusic.artworkUrl30 ?? "",
            artworkUrl60: newMusic.artworkUrl60 ?? "",
            artworkUrl100: newMusic.artworkUrl100 ?? ""
        )
    }
    
    func createMusicList(music: Result, index: Int) {
        mainContext.perform {
            let newMusic = MusicEntity(context: self.mainContext)
            newMusic.index = Int16(index)
            newMusic.trackId = Int32(music.trackId)
            newMusic.trackName = music.trackName
            newMusic.artistName = music.artistName
            newMusic.previewUrl = music.previewUrl
            newMusic.artworkUrl30 = music.artworkUrl30
            newMusic.artworkUrl60 = music.artworkUrl60
            newMusic.artworkUrl100 = music.artworkUrl100

            self.saveMainContext()
        }
    }
    
    func createMusicListList(musicList: [Result], completion: @escaping () -> ()) {
        for (index, music) in musicList.enumerated() {
            mainContext.performAndWait {
                let newMusic = MusicEntity(context: self.mainContext)
                newMusic.index = Int16(index)
                newMusic.trackId = Int32(music.trackId)
                newMusic.trackName = music.trackName
                newMusic.artistName = music.artistName
                newMusic.previewUrl = music.previewUrl
                newMusic.artworkUrl30 = music.artworkUrl30
                newMusic.artworkUrl60 = music.artworkUrl60
                newMusic.artworkUrl100 = music.artworkUrl100
                
                self.saveMainContext()
            }
        }
        completion()
    }

    func fetchMusicList() -> [MusicEntity] {
        var musicResult = [MusicEntity]()
        
        mainContext.performAndWait {
            let request: NSFetchRequest<MusicEntity> = MusicEntity.fetchRequest()
            
            let sortByIndex = NSSortDescriptor(key: #keyPath(MusicEntity.index), ascending: true)
            request.sortDescriptors = [sortByIndex]
            
            do {
                musicResult = try mainContext.fetch(request)
            } catch {
                print(error)
            }
        }
        return musicResult
    }
    
    func updateMuiscList() {
        
    }

    func swapMusicEntity(firstEntity: MusicEntity, secondEntity: MusicEntity, soureIndex: Int ,destinationIndex: Int) {
        mainContext.perform {
            firstEntity.index = Int16(destinationIndex)
            secondEntity.index = Int16(soureIndex)
            
            self.saveMainContext()
        }
    }
    
    func delete(entity: MusicEntity) {
        mainContext.perform {
            self.mainContext.delete(entity)
            self.saveMainContext()
        }
    }
    
    func deleteAll() {
        let fetchRequest = DataManager.shared.fetchMusicList()
        
        for item in fetchRequest {
            mainContext.delete(item)
        }
        self.saveMainContext()
    }
}
