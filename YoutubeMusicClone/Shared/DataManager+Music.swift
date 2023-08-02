//
//  DataManager+Music.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/07/31.
//

import Foundation
import CoreData

extension DataManager {
//    func createPerson(name: String, age: Int? = nil, completion: (() -> ())? = nil) {
//        mainContext.perform {
//            let newMusic = MusicEntity(context: self.mainContext)
//            //let newPerson = PersonEntity(context: self.mainContext)
//            //newPerson.setValue(name, forKey: "name")
//            newMusic.trackName = name
//
//            self.saveMainContext()
//
//            completion?()
//        }
//    }
//    func createMusicList(music: Music) {
//        mainContext.perform {
//            let newMusic = MusicEntity(context: self.mainContext)
//            newMusic.trackName = music.results[0].trackName
//
//            for result in music.results {
//                print(result)
//                newMusic.trackId = Int16(result.trackId)
//                newMusic.trackName = result.trackName
//                newMusic.artistName = result.artistName
//                newMusic.previewUrl = result.previewUrl
//                newMusic.artworkUrl30 = result.artworkUrl30
//                newMusic.artworkUrl60 = result.artworkUrl60
//                newMusic.artworkUrl100 = result.artworkUrl100
//
//                self.saveMainContext()
//            }
//
//        }
//    }
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

            print(music.trackName)
            
            self.saveMainContext()
        }
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
//
//    func updatePerson(entity: PersonEntity, name: String, age: Int? = nil, completion: (() -> ())? = nil) {
//        mainContext.perform {
//            entity.name = name
//            if let age = age {
//                entity.age = Int16(age)
//            }
//
//            self.saveMainContext()
//            completion?()
//        }
//
//    }
    func updateMuiscList() {
        
    }
//
//    func delete(entity: PersonEntity) {
//        mainContext.perform {
//            self.mainContext.delete(entity)
//            self.saveMainContext()
//        }
//    }
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
