//
//  FloatingPanelLayout.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/07/14.
//

import FloatingPanel
import Foundation

class MusicFloatingPanelLayout: FloatingPanelLayout {

    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .full
    

    let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
        .full: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .superview),
        .tip: FloatingPanelLayoutAnchor(absoluteInset: 165, edge: .bottom, referenceGuide: .superview)
    ]
    
}

class MusicWithCoreDataFloatingPanelLayout: FloatingPanelLayout {

    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .tip
    

    let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
        .full: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .superview),
        .tip: FloatingPanelLayoutAnchor(absoluteInset: 165, edge: .bottom, referenceGuide: .superview)
    ]
    
}


class MusicListFloatingPanel: FloatingPanelLayout {

    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .tip

    let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
        .full: FloatingPanelLayoutAnchor(absoluteInset: 83, edge: .top, referenceGuide: .safeArea),
        .tip: FloatingPanelLayoutAnchor(absoluteInset: 83, edge: .bottom, referenceGuide: .superview)
    ]
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        switch state {
        case .full, .half: return 0.0
        default: return 0.0
        }
    }
}
