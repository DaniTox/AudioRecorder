//
//  ListenVC.swift
//  AudioRecorder
//
//  Created by Dani Tox on 31/01/18.
//  Copyright © 2018 Dani Tox. All rights reserved.
//

import UIKit
import AVFoundation

class ListenVC: UIViewController {

    var playButton : UIButton!
    var fileSelected : URL?
    
    var audioPlayer : AVAudioPlayer?
    
    var isPlaying : Bool = false {
        didSet {
            if isPlaying == true {
                playButton.setTitle("Stop", for: .normal)
            } else {
                playButton.setTitle("Play", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViews()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func playButtonTapped() {
        play_pause()
    }
    
    private func play_pause() {
        guard let url = self.fileSelected else { return }
        if audioPlayer == nil {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                isPlaying = true
            }
            catch {
                print("ERRORE PLAYER: \(error)")
            }
        } else {
            audioPlayer?.stop()
            audioPlayer = nil
            isPlaying = false
        }
    }
    
    
    @objc func shareTapped() {
        guard let item = fileSelected else { return }
        let shareVC = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        present(shareVC, animated: true, completion: nil)
    }

}

extension ListenVC {
    func loadViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.alpha = 0.3
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 15
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             leading: view.leadingAnchor,
                             bottom: nil,
                             trailing: view.trailingAnchor,
                             padding: .init(top: 20, left: 20, bottom: 0, right: 20),
                             size: .init(width: 0, height: 200))
        
        
        
        playButton = UIButton()
        playButton.setTitle("Play", for: .normal)
        playButton.layer.masksToBounds = true
        playButton.layer.cornerRadius = 10
        playButton.backgroundColor = .orange
        playButton.titleLabel?.textColor = .white
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        view.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        playButton.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, padding: .zero, size: .init(width: 70, height: 50))
        
        
        let titleLabel = UILabel()
        titleLabel.text = fileSelected?.lastPathComponent
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.anchor(top: containerView.topAnchor,
                          leading: containerView.leadingAnchor,
                          bottom: nil,
                          trailing: containerView.trailingAnchor,
                          padding: .init(top: 20, left: 15, bottom: 0, right: 15),
                          size: .init(width: 0, height: 40))
        
        
        let shareButton = UIButton()
        shareButton.setTitle("Condividi", for: .normal)
        shareButton.layer.masksToBounds = true
        shareButton.layer.cornerRadius = 10
        shareButton.backgroundColor = .red
        shareButton.titleLabel?.textColor = .white
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        view.addSubview(shareButton)
        shareButton.anchor(top: containerView.bottomAnchor,
                           leading: containerView.leadingAnchor,
                           bottom: nil,
                           trailing: containerView.trailingAnchor,
                           padding: .init(top: 20, left: 0, bottom: 0, right: 0),
                           size: .init(width: 0, height: 40))
        
    }
}







