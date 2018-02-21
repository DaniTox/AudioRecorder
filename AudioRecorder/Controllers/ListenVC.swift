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
    var slider : UISlider!
    var leftLabel : UILabel!
    var rightLabel : UILabel!
    var titleLabel : UILabel!
    
    var isPlaying : Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.isPlaying == true {
                    guard let url = self.fileSelected else { return }
                    do {
                        self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                        self.audioPlayer?.delegate = self
                        self.audioPlayer?.currentTime = TimeInterval(self.slider.value)
                        self.audioPlayer?.volume = 1.0
                        self.audioPlayer?.prepareToPlay()
                        self.audioPlayer?.play()
                        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.loadControlsTime), userInfo: nil, repeats: true)
                        self.timer?.fire()
                    }
                    catch {
                        print("ERRORE PLAYER: \(error)")
                    }
                    self.playButton.setTitle("Stop", for: .normal)
                    self.slider.isHidden = false
                    [self.slider, self.leftLabel, self.rightLabel].forEach({ $0.isHidden = false })
                    self.slider.minimumValue = 0
                    self.slider.maximumValue = Float(self.audioPlayer?.duration ?? 0)
                    
                } else {
                    self.playButton.setTitle("Play", for: .normal)
                    [self.slider, self.leftLabel, self.rightLabel].forEach({ $0.isHidden = true })
                    self.audioPlayer?.stop()
                    self.audioPlayer = nil
                    self.timer?.invalidate()
                    self.timer = nil
                    self.slider.value = 0
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        loadViews()
        navigationItem.title = "Condividi"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func playButtonTapped() {
        play_pause()
    }
    
    var timer : Timer?
    private func play_pause() {
        if audioPlayer == nil {
            isPlaying = true
        } else {
            isPlaying = false
        }
    }
    @objc private func loadControlsTime() {
        slider.value = Float(audioPlayer?.currentTime ?? 0)
        
        let secondsD = Int(audioPlayer?.duration ?? 0)
        let sS = String(format: "%02d", Int(secondsD % 60))
        let mS = String(format: "%02d", Int(secondsD / 60))
        rightLabel.text = "\(mS):\(sS)"
        
        let secondsN = Int(audioPlayer?.currentTime ?? 0)
        let sN = String(format: "%02d", Int(secondsN % 60))
        let mN = String(format: "%02d", Int(secondsN / 60))
        leftLabel.text = "\(mN):\(sN)"
        
    }
    
    @objc func shareTapped() {
        guard let item = fileSelected else { return }
        let shareVC = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        shareVC.popoverPresentationController?.sourceView = self.titleLabel
        present(shareVC, animated: true, completion: nil)
    }

    
    @objc func sliderMoved() {
        audioPlayer?.currentTime = TimeInterval(slider.value)
    }
}

extension ListenVC {
    func loadViews() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.gray
        containerView.alpha = 0.3
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 15
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                             leading: view.safeAreaLayoutGuide.leadingAnchor,
                             bottom: nil,
                             trailing: view.safeAreaLayoutGuide.trailingAnchor,
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
        
        
        titleLabel = UILabel()
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
        
        
        
        leftLabel = UILabel()
        leftLabel.text = "00:00"
        leftLabel.textColor = .white
        leftLabel.textAlignment = .center
        leftLabel.adjustsFontSizeToFitWidth = true
        leftLabel.isHidden = true
        view.addSubview(leftLabel)
        leftLabel.anchor(top: nil,
                      leading: containerView.leadingAnchor,
                      bottom: containerView.bottomAnchor,
                      trailing: nil,
                      padding: .init(top: 0, left: 10, bottom: 20, right: 0),
                      size: .init(width: 30, height: 30))
        
        
        rightLabel = UILabel()
        rightLabel.text = "00:00"
        rightLabel.textColor = .white
        rightLabel.textAlignment = .center
        rightLabel.adjustsFontSizeToFitWidth = true
        rightLabel.isHidden = true
        view.addSubview(rightLabel)
        rightLabel.anchor(top: nil,
                         leading: nil,
                         bottom: containerView.bottomAnchor,
                         trailing: containerView.trailingAnchor,
                         padding: .init(top: 0, left: 0, bottom: 20, right: 10),
                         size: .init(width: 30, height: 30))
        
        
        slider = UISlider()
        slider.tintColor = .green
        slider.isHidden = true
        slider.addTarget(self, action: #selector(sliderMoved), for: .valueChanged)
        view.addSubview(slider)
        slider.anchor(top: nil,
                      leading: leftLabel.trailingAnchor,
                      bottom: containerView.bottomAnchor,
                      trailing: rightLabel.leadingAnchor,
                      padding: .init(top: 0, left: 5, bottom: 20, right: 5),
                      size: .zero)
        
        
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "finder-icon"))
        view.addSubview(imageView)
        imageView.anchor(top: shareButton.bottomAnchor,
                         leading: nil,
                         bottom: nil,
                         trailing: nil,
                         padding: .init(top: 65, left: 0, bottom: 0, right: 0),
                         size: .init(width: 256, height: 256))
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
}

extension ListenVC : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}





