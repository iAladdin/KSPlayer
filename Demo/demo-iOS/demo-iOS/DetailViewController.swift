//
//  DetailViewController.swift
//  Demo
//
//  Created by kintan on 2018/4/15.
//  Copyright © 2018年 kintan. All rights reserved.
//

import CoreServices
import KSPlayer
import UIKit
protocol DetailProtocol: UIViewController {
    var resource: KSPlayerResource? { get set }
}

class DetailViewController: UIViewController, DetailProtocol {
    #if os(iOS)
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        !playerView.isMaskShow
    }
    private let playerView = IOSVideoPlayerView()
    #else
    private let playerView = CustomVideoPlayerView()
    #endif
    var resource: KSPlayerResource? {
        didSet {
            if let resource = resource {
                playerView.set(resource: resource)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(playerView)
        playerView.delegate = self
        playerView.translatesAutoresizingMaskIntoConstraints = false
        #if os(iOS)
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
            playerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            playerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        #else
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            playerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        #endif
        view.layoutIfNeeded()
        playerView.backBlock = { [unowned self] in
            #if os(iOS)
            if UIApplication.shared.statusBarOrientation.isLandscape {
                self.playerView.updateUI(isLandscape: false)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            #else
            self.navigationController?.popViewController(animated: true)
            #endif
        }
        playerView.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension DetailViewController: PlayerControllerDelegate {
    func playerController(state: KSPlayerState) {

    }

    func playerController(currentTime: TimeInterval, totalTime: TimeInterval) {

    }

    func playerController(finish error: Error?) {

    }

    func playerController(maskShow: Bool) {
        #if os(iOS)
        setNeedsStatusBarAppearanceUpdate()
        #endif
    }

    func playerController(action: PlayerButtonType) {

    }

    func playerController(bufferedCount: Int, consumeTime: TimeInterval) {

    }

}

class CustomVideoPlayerView: VideoPlayerView {
    override func customizeUIComponents() {
        super.customizeUIComponents()
        toolBar.isHidden = true
        toolBar.timeSlider.isHidden = true
    }

    override open func player(layer: KSPlayerLayer, state: KSPlayerState) {
        super.player(layer: layer, state: state)
        if state == .readyToPlay, let player = layer.player {
            print(player.naturalSize)
            // list the all subtitles
            let subtitleInfos = srtControl.filterInfos { _ in true }
            subtitleInfos.forEach {
                print($0.name)
            }
            subtitleInfos.first?.makeSubtitle { result in
                self.resource?.subtitle = try? result.get()
            }
            for track in player.tracks(mediaType: .audio) {
                print("audio name: \(track.name) language: \(track.language ?? "")")
            }
            for track in player.tracks(mediaType: .video) {
                print("video name: \(track.name) bitRate: \(track.bitRate) fps: \(track.nominalFrameRate) bitDepth: \(track.bitDepth) colorPrimaries: \(track.colorPrimaries ?? "") colorPrimaries: \(track.transferFunction  ?? "") yCbCrMatrix: \(track.yCbCrMatrix ?? "") codecType:  \(track.codecType.string)")
            }
        }
    }

    override func onButtonPressed(type: PlayerButtonType, button: UIButton) {
        if type == .landscape {
            // xx
        } else {
            super.onButtonPressed(type: type, button: button)
        }
    }
}
