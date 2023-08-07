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
    let currentTimeLabel = UILabel()
    let totalTimeLabel = UILabel()
    let titleLabel = UILabel()
    let artistLabel = UILabel()
    let playButton = UIButton()
    let nextButton = UIButton()
    let prevButton = UIButton()
    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        //stackView.distribution = .equalSpacing
        return stackView
    }()
    
    var artist = ""
    
    var musicPlayer = MusicPlayerSingleton.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.addTarget(self, action: #selector(didChangedProgressBar(_:)), for: .touchUpInside)
        
        if artist == "" {   // coredata에 저장된 노래가 있을때
            MusicPlayerSingleton.shared.getImage()
            MusicPlayerSingleton.shared.getMusicFile()
            MusicPlayerSingleton.shared.isPlaying.value = false
        } else {    // coredata에 저장된 노래가 없고 셀을 선택해서 노래를 불러옴
            musicPlayer.artist = artist
            MusicPlayerSingleton.shared.isPlaying.value = true
        }
        
        setUp()
        setBinding()
        //addPeriodicTimeObserver()
        openMusicListFloatingPanel()
    }
    
}

// MARK: - MusicPlayerViewController
extension MusicPlayerViewController {
    
    @objc func didChangedProgressBar(_ sender: UISlider) {
        guard let duration = MusicPlayerSingleton.shared.playerItem?.duration else { return }

        let value = Float64(sender.value) * CMTimeGetSeconds(duration)
        
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        
        MusicPlayerSingleton.shared.player?.seek(to: seekTime)
    }
    
    // playButton 조작버튼
    @objc func touchPlayButton(_ sender: Any) {
        musicPlayer.isPlaying.value?.toggle()
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
            playButton.isSelected = musicPlayer.isPlaying.value ?? false
        } else {
            // 현재 재생 시간이 3초보다 클 경우 현재 노래 처음부분으로 이동
            let time = CMTime(seconds: 0, preferredTimescale: 1000)
            musicPlayer.player?.seek(to: time)
        }
        titleLabel.text = MusicPlayerSingleton.shared.music.value?.results[MusicPlayerSingleton.shared.currentIndex].trackName
    }
    
    // binding
    func setBinding() {
        MusicPlayerSingleton.shared.image.bind { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
            self?.addPeriodicTimeObserver()
        }
        
        MusicPlayerSingleton.shared.isPlaying.bind { [weak self] isPlaying in
            DispatchQueue.main.async {
                self?.playButton.isSelected = isPlaying ?? false
                
                switch isPlaying {
                case true: MusicPlayerSingleton.shared.player?.play()
                case false: MusicPlayerSingleton.shared.player?.pause()
                default: MusicPlayerSingleton.shared.player?.pause()
                }
            }
        }
        
        MusicPlayerSingleton.shared.currentTrackTitle.bind { [weak self] currentTitle in
            DispatchQueue.main.async {
                self?.titleLabel.text = currentTitle ?? "title"
            }
        }

        MusicPlayerSingleton.shared.currentArtist.bind { [weak self] currentArtist in
            DispatchQueue.main.async {
                self?.artistLabel.text = currentArtist ?? "aritst"
            }
        }
    }
    
    // addPeriodicTimeObserver(forInterval:queue:)를 통해 sliderValue 변경
    func addPeriodicTimeObserver() {
        let interval = CMTime(value: 1, timescale: 1)
        MusicPlayerSingleton.shared.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            guard let currentItem = MusicPlayerSingleton.shared.player?.currentItem else {
                return
            }
            // update CurrentTime
            let currentTime = currentItem.currentTime().seconds
            let formattedTime = MusicPlayerSingleton.shared.formatter.string(from: currentTime) ?? "00:00"
            self.currentTimeLabel.text = formattedTime
            
            if self.slider.isTracking == false {
                MusicPlayerSingleton.shared.updateSlider()
                self.slider.setValue(MusicPlayerSingleton.shared.sliderValue, animated: true)
            }
            
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
    
    // setUp
    func setUp() {
        view.backgroundColor = .black
        
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.text = "title"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        artistLabel.textAlignment = .center
        artistLabel.textColor = .lightGray
        artistLabel.text = "artist"
        artistLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
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
        
        let customThumbImage = UIImage(systemName: "circle.fill")
        slider.setThumbImage(customThumbImage, for: .normal)
        slider.tintColor = .white
        
        stackView.addArrangedSubview(prevButton)
        stackView.addArrangedSubview(playButton)
        stackView.addArrangedSubview(nextButton)
        
        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(artistLabel)
        
        view.addSubview(imageView)
        view.addSubview(labelStackView)
        view.addSubview(stackView)
        view.addSubview(slider)
        
        imageView.snp.makeConstraints { imageView in
            imageView.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            imageView.centerX.equalToSuperview()
            imageView.height.equalTo(330)
            imageView.width.equalTo(330)
        }
        
        labelStackView.snp.makeConstraints { labelStackView in
            labelStackView.centerX.equalToSuperview()
            labelStackView.top.equalTo(imageView.snp.bottom).offset(32)
            labelStackView.width.equalTo(imageView.snp.width)
        }
        
        slider.snp.makeConstraints { slider in
            //slider.top.equalTo(titleLabel.snp.bottom).offset(24)
            slider.top.equalTo(labelStackView.snp.bottom).offset(24)
            slider.width.equalTo(imageView.snp.width)
            slider.centerX.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { stackView in
            stackView.top.equalTo(slider.snp.bottom).offset(32)
            stackView.width.equalTo(imageView.snp.width)
            stackView.centerX.equalToSuperview()
        }
    }
}

// MARK: - FloatingPanelControllerDelegate
extension MusicPlayerViewController: FloatingPanelControllerDelegate {
    
    /// 플레이어창 내부 fpc
    func insidePlayerChangedState(_ fpc: FloatingPanelController) {
        switch fpc.state {
        case .full:
            
            imageView.snp.removeConstraints()
            stackView.snp.removeConstraints()
            labelStackView.snp.removeConstraints()
            
            stackView.removeArrangedSubview(prevButton)
            prevButton.removeFromSuperview()
            
            slider.isHidden = true
            
            labelStackView.alignment = .leading
            
            titleLabel.textAlignment = .left
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
            imageView.snp.makeConstraints { imageView in
                imageView.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
                imageView.leading.equalToSuperview().offset(12)
                imageView.height.equalTo(70)
                imageView.width.equalTo(70)
            }

            stackView.snp.makeConstraints { stackView in
                stackView.centerY.equalTo(imageView)
                stackView.trailing.equalToSuperview().offset(-12)
                stackView.width.equalTo(50)
            }
            
            
            labelStackView.snp.makeConstraints { labelStackView in
                labelStackView.leading.equalTo(imageView.snp.trailing).offset(12)
                labelStackView.trailing.equalTo(stackView.snp.leading).offset(0)
                labelStackView.centerY.equalTo(imageView)
            }
            
//            titleLabel.snp.makeConstraints { titleLabel in
//                titleLabel.leading.equalTo(imageView.snp.trailing).offset(6)
//                titleLabel.trailing.equalTo(stackView.snp.leading).offset(6)
//                titleLabel.centerY.equalTo(imageView)
//            }
            
            
        case .tip:
            stackView.insertArrangedSubview(prevButton, at: 0)
            
            imageView.snp.removeConstraints()
            //titleLabel.snp.removeConstraints()
            slider.snp.removeConstraints()
            stackView.snp.removeConstraints()
            labelStackView.snp.removeConstraints()
            
            labelStackView.alignment = .center
            
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            
            imageView.snp.makeConstraints { imageView in
                imageView.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
                imageView.centerX.equalToSuperview()
                imageView.height.equalTo(330)
                imageView.width.equalTo(330)
            }
            
            labelStackView.snp.makeConstraints { labelStackView in
                labelStackView.centerX.equalToSuperview()
                labelStackView.top.equalTo(imageView.snp.bottom).offset(32)
                labelStackView.width.equalTo(imageView.snp.width)
            }
            
            slider.snp.makeConstraints { slider in
                //slider.top.equalTo(titleLabel.snp.bottom).offset(24)
                slider.top.equalTo(labelStackView.snp.bottom).offset(24)
                slider.width.equalTo(imageView.snp.width)
                slider.centerX.equalToSuperview()
            }
            
            stackView.snp.makeConstraints { stackView in
                stackView.top.equalTo(slider.snp.bottom).offset(32)
                stackView.width.equalTo(imageView.snp.width)
                stackView.centerX.equalToSuperview()
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
            
            imageView.snp.removeConstraints()
            stackView.snp.removeConstraints()
            //titleLabel.snp.removeConstraints()
            labelStackView.snp.removeConstraints()
            
            stackView.removeArrangedSubview(prevButton)
            prevButton.removeFromSuperview()
            
            slider.isHidden = true
            
            labelStackView.alignment = .leading
            
            titleLabel.textAlignment = .left
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
            imageView.snp.makeConstraints { imageView in
                imageView.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
                imageView.leading.equalToSuperview().offset(12)
                imageView.height.equalTo(70)
                imageView.width.equalTo(70)
            }

            stackView.snp.makeConstraints { stackView in
                stackView.centerY.equalTo(imageView)
                stackView.trailing.equalToSuperview().offset(-12)
                stackView.width.equalTo(50)
            }
            
//            titleLabel.snp.makeConstraints { titleLabel in
//                titleLabel.leading.equalTo(imageView.snp.trailing).offset(6)
//                titleLabel.trailing.equalTo(stackView.snp.leading).offset(6)
//                titleLabel.centerY.equalTo(imageView)
//            }
            labelStackView.snp.makeConstraints { labelStackView in
                labelStackView.leading.equalTo(imageView.snp.trailing).offset(12)
                labelStackView.trailing.equalTo(stackView.snp.leading).offset(0)
                labelStackView.centerY.equalTo(imageView)
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
    
    func updateLayout() {
        imageView.snp.removeConstraints()
        stackView.snp.removeConstraints()
        titleLabel.snp.removeConstraints()
        
        stackView.removeArrangedSubview(prevButton)
        prevButton.removeFromSuperview()
        
        slider.isHidden = true
        
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    
        imageView.snp.makeConstraints { imageView in
            imageView.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
            imageView.leading.equalToSuperview().offset(12)
            imageView.height.equalTo(70)
            imageView.width.equalTo(70)
        }

        stackView.snp.makeConstraints { stackView in
            stackView.centerY.equalTo(imageView)
            stackView.trailing.equalToSuperview().offset(-12)
            stackView.width.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints { titleLabel in
            titleLabel.leading.equalTo(imageView.snp.trailing).offset(6)
            titleLabel.trailing.equalTo(stackView.snp.leading).offset(6)
            titleLabel.centerY.equalTo(imageView)
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
        musicPlayer.currentIndex = 0
        
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
