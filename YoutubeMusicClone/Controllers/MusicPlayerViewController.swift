//
//  MusicPlayerViewController.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/07/10.
//

import UIKit
import SnapKit
import Foundation
import FloatingPanel
import AVFoundation


class MusicPlayerViewController: UIViewController {
    
    let fpc = FloatingPanelController()
    
    var checkFpcState: FloatingPanelState = .full
    
    let imageView = UIImageView()
    let slider = UISlider()
    var titleLabel = UILabel()
    let playButton = UIButton()
    let nextButton = UIButton()
    let prevButton = UIButton()
    var stackView: UIStackView = {
        let stackView = UIStackView()
        //stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    var artist = ""
    
    var musicPlayer = MusicPlayerSingleton.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if artist == "" {
            MusicPlayerSingleton.shared.getImage()
            MusicPlayerSingleton.shared.getMusicFile()
        } else {
            musicPlayer.artist = artist
        }
        
        setUp()
        setBinding()
        //addPeriodicTimeObserver()
        openMusicListFloatingPanel()
    }
    
}

// MARK: - MusicPlayerViewController
extension MusicPlayerViewController {
    // playButton 조작버튼
    @objc func touchPlayButton(_ sender: Any) {
        musicPlayer.isPlaying.toggle()
        playButton.isSelected.toggle()
    }
    
    @objc func touchNextButton(_ sender: Any) {
        musicPlayer.nextMusic()
        playButton.isSelected = true
        
        titleLabel.text = MusicPlayerSingleton.shared.music.value?.results[MusicPlayerSingleton.shared.currentIndex].trackName
    }
    
    @objc func touchPrevButton(_ sender: Any) {
        let currentTime = musicPlayer.player?.currentTime().seconds ?? 0
        
        // 현재 재생 시간이 3초보다 작을 경우 이전 노래 재생
        if currentTime < 3 {
            musicPlayer.prevMusic()
            playButton.isSelected = musicPlayer.isPlaying ? true : false
        } else {
            // 현재 재생 시간이 3초보다 클 경우 현재 노래 처음부분으로 이동
            let time = CMTime(seconds: 0, preferredTimescale: 1000)
            musicPlayer.player?.seek(to: time)
        }
        titleLabel.text = MusicPlayerSingleton.shared.music.value?.results[MusicPlayerSingleton.shared.currentIndex].trackName
    }
    
    // setUp
    func setUp() {
        view.backgroundColor = .black
        
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.text = "title"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        nextButton.setImage(UIImage(systemName: "chevron.right.2"), for: .normal)
        nextButton.setImage(UIImage(systemName: "chevron.right.2"), for: .highlighted)
        nextButton.setImage(UIImage(systemName: "chevron.right.2"), for: .selected)
        nextButton.tintColor = .white
        nextButton.addTarget(self, action: #selector(touchNextButton(_:)), for: .touchUpInside)
        
        prevButton.setImage(UIImage(systemName: "chevron.left.2"), for: .normal)
        prevButton.setImage(UIImage(systemName: "chevron.left.2"), for: .highlighted)
        prevButton.setImage(UIImage(systemName: "chevron.left.2"), for: .selected)
        prevButton.tintColor = .white
        prevButton.addTarget(self, action: #selector(touchPrevButton(_:)), for: .touchUpInside)
        
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.setImage(UIImage(systemName: "pause"), for: .highlighted)
        playButton.setImage(UIImage(systemName: "pause"), for: .selected)
        playButton.tintColor = .white
        playButton.addTarget(self, action: #selector(touchPlayButton(_:)), for: .touchUpInside)
        
        imageView.backgroundColor = .gray
        
        stackView.addArrangedSubview(prevButton)
        stackView.addArrangedSubview(playButton)
        stackView.addArrangedSubview(nextButton)
        
        view.addSubview(imageView)
        view.addSubview(stackView)
        view.addSubview(slider)
        view.addSubview(titleLabel)
        
        stackView.snp.makeConstraints { stackView in
            stackView.width.equalTo(300)
            stackView.centerX.equalToSuperview()
            stackView.centerY.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { imageView in
            imageView.bottom.equalTo(stackView.snp.top)
            imageView.height.equalTo(300)
            imageView.width.equalTo(300)
            imageView.centerX.equalToSuperview()
        }
        
        slider.snp.makeConstraints { slider in
            slider.top.equalTo(stackView.snp.bottom).offset(30)
            slider.width.equalTo(imageView.snp.width)
            slider.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { title in
            title.centerX.equalToSuperview()
            title.top.equalTo(slider.snp.bottom).offset(24)
            title.width.equalTo(imageView.snp.width)
        }
    }
    
    // binding
    func setBinding() {
        MusicPlayerSingleton.shared.image.bind { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
                self?.titleLabel.text = MusicPlayerSingleton.shared.music.value?.results[MusicPlayerSingleton.shared.currentIndex].trackName
            }
            self?.addPeriodicTimeObserver()
        }
    }
    
    func openMusicListFloatingPanel() {
        let contentVC = MusicPlayerPageViewController()
        
        fpc.set(contentViewController: contentVC)
        
        fpc.layout = MusicListFloatingPanel()
        fpc.invalidateLayout()
        
        fpc.delegate = self
        
        fpc.isRemovalInteractionEnabled = false
        fpc.surfaceView.grabberHandle.isHidden = false
        fpc.surfaceView.backgroundColor = UIColor(red: 0.149019599, green: 0.149019599, blue: 0.149019599, alpha: 1)
        
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 8.0
        appearance.backgroundColor = .clear
        fpc.surfaceView.appearance = appearance
        
        fpc.addPanel(toParent: self, animated: true)
    }
    
    // 1초마다 addPeriodicTimeObserver(forInterval:queue:)를 통해 변경
    func addPeriodicTimeObserver() {
        let interval = CMTime(value: 1, timescale: 1)
        MusicPlayerSingleton.shared.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
//            guard let currentItem = MusicPlayerSingleton.shared.player?.currentItem else {
//                return
//            }
            MusicPlayerSingleton.shared.updateSlider()
            self.slider.setValue(MusicPlayerSingleton.shared.sliderValue, animated: true)
        }
    }
}

// MARK: - FloatingPanelControllerDelegate
extension MusicPlayerViewController: FloatingPanelControllerDelegate {
    
    /// 플레이어창 내부 fpc
    func insidePlayerChangedState(_ fpc: FloatingPanelController) {
        switch fpc.state {
        case .full:
            
            self.imageView.snp.removeConstraints()
            self.imageView.snp.makeConstraints { imageView in
                imageView.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
                imageView.leading.equalToSuperview().offset(12)
                imageView.height.equalTo(70)
                imageView.width.equalTo(70)
            }

            stackView.removeArrangedSubview(prevButton)
            prevButton.removeFromSuperview()
            
            slider.isHidden = true
            
            stackView.snp.removeConstraints()
            
            stackView.snp.makeConstraints { stackView in
                stackView.centerY.equalTo(self.imageView)
                stackView.trailing.equalToSuperview().offset(-12)
                stackView.width.equalTo(50)
            }
            
        case .tip:
            stackView.insertArrangedSubview(prevButton, at: 0)
            
            stackView.snp.removeConstraints()
            stackView.snp.makeConstraints { stackView in
                stackView.width.equalTo(300)
                stackView.centerX.equalToSuperview()
                stackView.centerY.equalToSuperview()
            }
            
            imageView.snp.removeConstraints()
            imageView.snp.makeConstraints { imageView in
                imageView.bottom.equalTo(self.stackView.snp.top)
                imageView.height.equalTo(300)
                imageView.width.equalTo(300)
                imageView.centerX.equalToSuperview()
            }
            slider.isHidden = false
            
        default:
            imageView.snp.removeConstraints()
            imageView.snp.makeConstraints { imageView in
                imageView.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
                imageView.leading.equalToSuperview().offset(12)
                imageView.height.equalTo(70)
                imageView.width.equalTo(70)
            }
        }
    }

    
    /// 플레이어창 fpc
    func playerChangedState(_ fpc: FloatingPanelController) {
        switch fpc.state {
        case .tip:
            view.backgroundColor = UIColor(red: 0.149019599, green: 0.149019599, blue: 0.149019599, alpha: 1)
            
            fpc.isRemovalInteractionEnabled = true
            
            self.imageView.snp.removeConstraints()
            self.imageView.snp.makeConstraints { imageView in
                imageView.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
                imageView.leading.equalToSuperview().offset(12)
                imageView.height.equalTo(70)
                imageView.width.equalTo(70)
            }

            stackView.removeArrangedSubview(prevButton)
            prevButton.removeFromSuperview()
            
            slider.isHidden = true
            
            stackView.snp.removeConstraints()
            
            stackView.snp.makeConstraints { stackView in
                stackView.centerY.equalTo(self.imageView)
                stackView.trailing.equalToSuperview().offset(-12)
                stackView.width.equalTo(50)
            }
            
            self.tabBarController?.tabBar.isHidden = false
        case .full:
            view.backgroundColor = .black
            fpc.surfaceView.backgroundColor = .black
            self.fpc.move(to: .tip, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        default:
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        
        if fpc == self.fpc {    // 플레이어 내부 fpc
            insidePlayerChangedState(self.fpc)
        } else {    // 플레이어 fpc
            playerChangedState(fpc)
        }
    }
    
    func floatingPanelWillRemove(_ fpc: FloatingPanelController) {
        // Inform the panel controller that it will be removed from the hierarchy.
        
        musicPlayer.player = nil
        musicPlayer.playerItem = nil
        musicPlayer.music.value = nil
        
        fpc.willMove(toParent: nil)
        
        // Hide the floating panel.
        fpc.hide(animated: true) {
            // Remove the floating panel view from your controller's view.
            fpc.view.removeFromSuperview()
            // Remove the floating panel controller from the controller hierarchy.
            fpc.removeFromParent()
        }
    }
    
    func floatingPanelDidRemove(_ fpc: FloatingPanelController) {
        print(#function)
    }

}
