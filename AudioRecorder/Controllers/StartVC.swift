//
//  ViewController.swift
//  AudioRecorder
//
//  Created by Dani Tox on 30/01/18.
//  Copyright © 2018 Dani Tox. All rights reserved.
//

import UIKit
import AVFoundation

class StartVC: UIViewController {

    var tableView : UITableView?
    var recordButton : UIButton?
    
    var recordSession : AVAudioRecorder!
    
    var files : [String] = []
    
    
    
    var isRecording : Bool = false {
        didSet {
            if isRecording == true {
                recordButton?.setTitle("Sto registrando...", for: .normal)
                
                let filePath = getDir()
                let settings = [AVFormatIDKey : Int(kAudioFormatMPEG4AAC), AVNumberOfChannelsKey : 1, AVSampleRateKey : 12000, AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue]
                
                do {
                    recordSession = try AVAudioRecorder(url: filePath, settings: settings)
                    recordSession.delegate = self
                    recordSession.prepareToRecord()
                    recordSession.record()
                } catch {
                    print("ERRORE: \(error)")
                }
                
            } else {
                recordSession.stop()
                recordButton?.setTitle("Registra", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setViews()
        
        AVAudioSession.sharedInstance().requestRecordPermission { (perm) in
            if perm { print("YEAH") }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFiles()
    }

    private func getFiles() {
        do {
            files.removeAll()
            let temp = try FileManager.default.contentsOfDirectory(at: getDocDir(), includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            temp.forEach({ files.append($0.lastPathComponent) })
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        } catch {
            print("ERRORE: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func getDir() -> URL {
        let offset = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return offset.appendingPathComponent("temp1.m4a")
    }
    private func getDocDir() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    private func getDocDirStr() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    private func getStringRandom() -> String {
        let characters = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm1234567890".sorted()
        var random = ""
        for _ in 0...5 {
            let asd = Int(arc4random_uniform(UInt32(characters.count - 1)))
            random.append(characters[asd])
        }
        return random
    }

}

extension StartVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = files[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

extension StartVC : AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag == false { return }
        print("Recorded successfully")
        
        let alert = UIAlertController(title: "Scrivi il titolo", message: "Che nome vuoi dare a questo file?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "temp1"
        }
        alert.addAction(UIAlertAction(title: "Conferma", style: .default, handler: { (action) in
            let textOfAlert = alert.textFields![0].text!
            let origin = self.getDir()
            let dest = self.getDocDir().appendingPathComponent(textOfAlert.isEmpty ? self.getStringRandom() : textOfAlert).appendingPathExtension("m4a")
            do {
                try FileManager.default.moveItem(at: origin, to: dest)
                self.getFiles()
            } catch {
                print("ERRORE FILEMAN : \(error)")
            }
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
        
    }
}

extension StartVC {
    func setViews() {
        tableView = UITableView()
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = .clear
        tableView?.tableFooterView = UIView()
        view.addSubview(tableView!)
        
        tableView?.anchor(top: view.topAnchor,
                          leading: view.leadingAnchor,
                          bottom: view.bottomAnchor,
                          trailing: view.trailingAnchor,
                          padding: .init(top: 100, left: 0, bottom: 200, right: 0),
                          size: .zero)
        
        
        
        
        
        recordButton = UIButton()
        recordButton?.addTarget(self, action: #selector(recButtonTapped), for: .touchUpInside)
        recordButton?.layer.masksToBounds = true
        recordButton?.layer.cornerRadius = 15
        recordButton?.backgroundColor = .red
        recordButton?.setTitle("Registra", for: .normal)
        view.addSubview(recordButton!)
        recordButton?.anchor(top: nil,
                             leading: view.leadingAnchor,
                             bottom: view.bottomAnchor,
                             trailing: view.trailingAnchor,
                             padding: .init(top: 0, left: 20, bottom: 50, right: 20),
                             size: .zero)
    }
    
    @objc func recButtonTapped() {
        isRecording = !isRecording
    }
    
    
    
    
    
    
    
    
}









