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
                tableView?.layer.borderColor = UIColor.red.cgColor
                
                let filePath = getDir()
                print(filePath.absoluteString)
                let settings = [AVFormatIDKey : Int(kAudioFormatMPEG4AAC), AVNumberOfChannelsKey : 1, AVSampleRateKey : 12000, AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue]
                
                do {
                    recordSession = try AVAudioRecorder(url: filePath, settings: settings)
                    recordSession.delegate = self
                    recordSession.prepareToRecord()
                    if recordSession.record() == false {
                        print("ERROR STARTING RECORDING")
                        print("TRYING AGAIN...")
                        if recordSession.record() == false {
                            print("FAILED AGAIN...")
                        }
                        else {
                            print("NOW IT WORKS")
                        }
                    }
                } catch {
                    print("ERRORE: \(error)")
                }
                
            } else {
                tableView?.layer.borderColor = UIColor.green.cgColor
                recordSession.stop()
                recordButton?.setTitle("Registra", for: .normal)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationItem.title = "Home"
        
        setViews()

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ListenVC()
        let file = files[indexPath.row]
        let url = getDocDir().appendingPathComponent(file)
        vc.fileSelected = url
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
               try FileManager.default.removeItem(at: getDocDir().appendingPathComponent(files[indexPath.row]))
            } catch {
                print("ERRORE RIMOZIONE FILE: \(error)")
            }
            files.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
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
            var dest = self.getDocDir().appendingPathComponent(textOfAlert.isEmpty ? self.getStringRandom() : textOfAlert).appendingPathExtension("m4a")
            do {
                try FileManager.default.moveItem(at: origin, to: dest)
                self.getFiles()
            } catch {
                dest = self.getDocDir().appendingPathComponent(self.getStringRandom()).appendingPathExtension("m4a")
                try? FileManager.default.moveItem(at: origin, to: dest)
                self.getFiles()
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
        
        
        tableView = UITableView()
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = .clear
        tableView?.tableFooterView = UIView()
        tableView?.layer.masksToBounds = true
        tableView?.layer.cornerRadius = 20
        tableView?.layer.borderWidth = 1
        tableView?.layer.borderColor = UIColor.green.cgColor
        view.addSubview(tableView!)
        
        tableView?.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          leading: view.safeAreaLayoutGuide.leadingAnchor,
                          bottom: recordButton?.topAnchor,
                          trailing: view.safeAreaLayoutGuide.trailingAnchor,
                          padding: .init(top: 20, left: 0, bottom: 20, right: 0),
                          size: .zero)
        
        
        
        
        
        
    }
    
    @objc func recButtonTapped() {
        isRecording = !isRecording
    }
    
    
    
    
    
    
    
    
}









