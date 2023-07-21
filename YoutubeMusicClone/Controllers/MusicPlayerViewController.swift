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
    
    let imageView = UIImageView()
    let playButton = UIButton()
    let nextButton = UIButton()
    let prevButton = UIButton()
    
    var artist = ""
    
    var musicPlayer = MusicPlayerSingleton.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicPlayer.artist = artist
        
        setUp()
        setBinding()
        
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
    }
    
    @objc func touchPrevButton(_ sender: Any) {
        let currentTime = musicPlayer.player?.currentTime().seconds ?? 0
        
        // 현재 재생 시간이 3초보다 작을 경우 이전 노래 재생
        if currentTime < 3 {
            musicPlayer.prevMusic()
            playButton.isSelected = musicPlayer.isPlaying ?? false ? true : false
        } else {
            // 현재 재생 시간이 3초보다 클 경우 현재 노래 처음부분으로 이동
            let time = CMTime(seconds: 0, preferredTimescale: 1000)
            musicPlayer.player?.seek(to: time)
        }
    }
    
    // setUp
    func setUp() {
        view.backgroundColor = .black
        
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
        
        let stackView = UIStackView(arrangedSubviews: [prevButton, playButton, nextButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 30
        
        view.addSubview(imageView)
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { stackView in
            stackView.centerX.equalToSuperview()
            stackView.centerY.equalToSuperview()
            stackView.width.equalTo(200)
        }
        
        imageView.snp.makeConstraints { imageView in
            imageView.bottom.equalTo(stackView.snp.top)
            imageView.height.equalTo(300)
            imageView.width.equalTo(300)
            imageView.centerX.equalToSuperview()
        }
        
    }
    
    // binding
    func setBinding() {
        MusicPlayerSingleton.shared.image.bind { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
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
        fpc.surfaceView.backgroundColor = #colorLiteral(red: 0.149019599, green: 0.149019599, blue: 0.149019599, alpha: 1)
        
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 8.0
        
        fpc.surfaceView.appearance = appearance
        
        fpc.addPanel(toParent: self, animated: true)
    }
}

// MARK: - FloatingPanelControllerDelegate
extension MusicPlayerViewController: FloatingPanelControllerDelegate {
    
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        
        if fpc == self.fpc {
            print("fpc")
            if fpc.state == .full {
                self.imageView.snp.removeConstraints()
                
                self.imageView.snp.makeConstraints { imageView in
                    imageView.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
                    imageView.leading.equalToSuperview().offset(12)
                    imageView.height.equalTo(70)
                    imageView.width.equalTo(70)
                }
            } else if fpc.state == .tip {
                self.imageView.snp.removeConstraints()
                
                self.imageView.snp.makeConstraints { imageView in
                    imageView.bottom.equalTo(self.playButton.snp.top)
                    imageView.height.equalTo(300)
                    imageView.width.equalTo(300)
                    imageView.centerX.equalToSuperview()
                }
            }
        } else {
            print("playerfpc")
            if fpc.state == .tip {
                fpc.isRemovalInteractionEnabled = true
                
                UIView.animate(withDuration: 0.3) {
                    self.tabBarController?.tabBar.isHidden = false
                    
                    self.view.backgroundColor = #colorLiteral(red: 0.149019599, green: 0.149019599, blue: 0.149019599, alpha: 1)
                    
                    self.imageView.snp.removeConstraints()
                    
                    self.imageView.snp.makeConstraints { imageView in
                        imageView.top.equalToSuperview().offset(6)
                        imageView.leading.equalToSuperview().offset(12)
                        imageView.height.equalTo(70)
                        imageView.width.equalTo(70)
                    }
                }
                self.view.layoutIfNeeded()
                
                
            } else {
                fpc.isRemovalInteractionEnabled = false
                
                UIView.animate(withDuration: 0.3) {
                    self.tabBarController?.tabBar.isHidden = true
                    
                    self.view.backgroundColor = .black
                    
                    self.imageView.snp.removeConstraints()
                    
                    self.imageView.snp.makeConstraints { imageView in
                        imageView.bottom.equalTo(self.playButton.snp.top)
                        imageView.height.equalTo(300)
                        imageView.width.equalTo(300)
                        imageView.centerX.equalToSuperview()
                    }
                }
                self.view.layoutIfNeeded()
                
            }
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
