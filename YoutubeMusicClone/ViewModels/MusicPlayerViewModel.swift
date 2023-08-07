//
//  MusicPlayerViewModel.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/07/11.
//

import UIKit
import AVFoundation
import Foundation

//class MusicPlayerViewModel {
//
//    //MARK: - Properties
//    var artist: String
//
//    var removeIndex = 0
//    var currentIndex = 0
//    var player: AVPlayer?
//    var playerItem: AVPlayerItem?
//    var image: Observable<UIImage> = Observable(UIImage())
//    var music: Observable<Music> = Observable(Music(resultCount: 0, results: []))
//
//    var currentSliderValue = 0
//
//    var isPlaying: Bool = false {
//        didSet {
//            isPlaying == true ? player?.play() : player?.pause()
//        }
//    }
//
//    //MARK: - init
//    init(artist: String) {
//        self.artist = artist
//
//        getMusic(artist: self.artist)
//    }
//
//    //MARK: - Networking
//    func getMusic(artist: String) {
//
//        let url = "https://itunes.apple.com/search?term=\(artist)&media=music"
//
//        WebService().loadData(urlStr: url) { (music: Music?) in
//            guard let music = music else { return }
//
//            self.music.value = music
//
//        }
//    }
//
//    func getImage() {
//        guard let url = self.music.value?.results[currentIndex].artworkUrl100 else { return }
//        guard let imageUrl = URL(string: url) else { return }
//        DispatchQueue.global().async {
//            if let data = try? Data(contentsOf: imageUrl) {
//                if let image = UIImage(data: data) {
//                        self.image.value = image
//                }
//            }
//        }
//    }
//
//    func getMusicFile() {
//        guard let url = self.music.value?.results[currentIndex].previewUrl else { return }
//        if let fileURL = URL(string: url) {
//            self.playerItem = AVPlayerItem(url: fileURL)
//            self.player = AVPlayer(playerItem: self.playerItem)
//        }
//    }
//
//    func nextMusic() {
//        if currentIndex + 1 < music.value?.results.count ?? 0 {
//            currentIndex += 1
//
//            getImage()
//            getMusicFile()
//
//            isPlaying = true
//        }
//    }
//
//    func prevMusic() {
//        if currentIndex > 0 {
//            currentIndex -= 1
//
//            getImage()
//            getMusicFile()
//
//            isPlaying = true
//        }
//    }
//}

class MusicPlayerSingleton {
    
    static let shared = MusicPlayerSingleton()
    
    //MARK: - Properties
    var artist: String = "" {
        didSet {
            getMusic(artist: self.artist)
        }
    }
    
    var removeIndex = 0
    var currentIndex = 0
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var image: Observable<UIImage> = Observable(UIImage())
    var music: Observable<Music> = Observable(Music(resultCount: 0, results: []))
    var sliderValue: Float = 0
    var isPlaying: Observable<Bool> = Observable(false)
    var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var currentTrackTitle: Observable<String> = Observable("")
    var currentArtist: Observable<String> = Observable("")
    
    //MARK: - init
    private init() {}
 
    //MARK: - Networking
    func getMusic(artist: String) {
        
        let url = "https://itunes.apple.com/search?term=\(artist)&media=music"
        
        WebService().loadData(urlStr: url) { (music: Music?) in
            guard let music = music else { return }
            
            self.music.value = music
            
            self.getImage()
            self.getMusicFile()
        }
    }
    
    func getImage() {
        guard let url = self.music.value?.results[currentIndex].artworkUrl100 else { return }
        guard let imageUrl = URL(string: url) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: imageUrl) {
                if let image = UIImage(data: data) {
                        self.image.value = image
                }
            }
        }
    }
    
    func getMusicFile(completion: (() -> Void)? = nil) {
        currentTrackTitle.value = music.value?.results[currentIndex].trackName
        currentArtist.value = music.value?.results[currentIndex].artistName
        
        guard let url = self.music.value?.results[currentIndex].previewUrl else { return }

        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)

        if let fileURL = URL(string: url) {
            self.playerItem = AVPlayerItem(url: fileURL)
            self.player = AVPlayer(playerItem: self.playerItem)

            NotificationCenter.default.addObserver(self, selector: #selector(nextMusic), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)

            completion?()
        }
    }
    
    @objc func nextMusic() {
        print(#function)
        
        if currentIndex + 1 < music.value?.results.count ?? 0 {
            currentIndex += 1
            
            getImage()
            getMusicFile()
            
            player?.play()
            
            NotificationCenter.default.post(name: .nextMusicPlayed, object: nil)
        } else {
            isPlaying.value = false
        }
    }
    
    func prevMusic() {
        if currentIndex > 0 {
            currentIndex -= 1
            
            getImage()
            getMusicFile()
            
            NotificationCenter.default.post(name: .prevMusicPlayed, object: nil)
        }
    }
    
    func didSelectedMusicAt(indexPath: Int) {
        currentIndex = indexPath
        
        getImage()
        getMusicFile()
    }
    
    func removeMusicAt(indexPath: Int) {
        
        if indexPath == currentIndex {
            self.music.value?.results.remove(at: indexPath)
            
            getImage()
            getMusicFile()
        } else if indexPath < currentIndex {
            self.music.value?.results.remove(at: indexPath)
            
            currentIndex -= 1
        } else {
            self.music.value?.results.remove(at: indexPath)
        }
    }
    
    func updateSlider() {
        var value: Float = 0
        if let currentTime = player?.currentTime(), let duration = playerItem?.duration {
            let currentTimeSeconds = CMTimeGetSeconds(currentTime)
            let durationSeconds = CMTimeGetSeconds(duration)
            value = Float(currentTimeSeconds / durationSeconds)
        }
        sliderValue = value
    }
    
    func seekTo() {
        guard let duration = self.playerItem?.duration else {
            return
        }
        let durationSeconds = CMTimeGetSeconds(duration)
        let seekTime = CMTime(seconds: durationSeconds * Double(sliderValue), preferredTimescale: 1000)

        // 현재 재생 시간을 지정한 시간으로 변경 AVPlayerItem.seek(to:)
        self.player?.seek(to: seekTime)
    }
}

extension Notification.Name {
    static let nextMusicPlayed = Notification.Name("NextMusicPlayed")
    static let prevMusicPlayed = Notification.Name("PrevMusicPlayed")
}
