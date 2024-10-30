import UIKit
import AVFoundation

class ViewController: UIViewController {

    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var isRecording = false  // To track recording state
    var recordings: [URL] = []  // To store multiple recordings
    let statusLabel = UILabel()  // Label to display status (Recording, Stopped, etc.)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background color of the view
        view.backgroundColor = .white
        
        // Call setupUI to add the buttons for recording and playback
        setupUI()
    }

    // Function to set up user interface elements (like buttons)
    func setupUI() {
        // Create a button to start and stop recording
        let recordButton = UIButton(type: .system)
        recordButton.setTitle("Start Recording", for: .normal)
        recordButton.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        recordButton.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
        view.addSubview(recordButton)  // Add the button to the view

        // Create a button to play the last recorded audio
        let playButton = UIButton(type: .system)
        playButton.setTitle("Play Last Recording", for: .normal)
        playButton.frame = CGRect(x: 100, y: 300, width: 200, height: 50)
        playButton.addTarget(self, action: #selector(playRecording), for: .touchUpInside)
        view.addSubview(playButton)

        // Status label to show recording/playback state
        statusLabel.frame = CGRect(x: 100, y: 400, width: 200, height: 50)
        statusLabel.text = "Status: Ready"
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)
    }

    // Function to toggle between starting and stopping recording
    @objc func toggleRecording() {
        if isRecording {
            stopRecording()  // If already recording, stop it
        } else {
            startRecording()  // If not recording, start it
        }
        isRecording.toggle()  // Toggle the recording state
    }

    // Function to start audio recording with a unique filename
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            print("Trying to start recording")
            
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession.setActive(true)

            // Generate a unique filename using a timestamp
            let timestamp = Int(Date().timeIntervalSince1970)
            let url = getDocumentsDirectory().appendingPathComponent("recording_\(timestamp).m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            // Initialize and start the audio recorder
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()

            // Update UI
            statusLabel.text = "Status: Recording..."
            print("Recording started...")
            
            // Save the recording URL
            recordings.append(url)
        } catch {
            print("Failed to start recording: \(error)")
            statusLabel.text = "Error: Could not record"
        }
    }

    // Function to stop audio recording
    func stopRecording() {
        if let recorder = audioRecorder {
            recorder.stop()
            statusLabel.text = "Status: Recording stopped."
            print("Recording stopped.")
        } else {
            print("No active recorder found.")
            statusLabel.text = "Error: No active recording."
        }
    }

    // Function to play the last recorded audio
    @objc func playRecording() {
        guard let lastRecording = recordings.last else {
            print("No recordings found.")
            statusLabel.text = "Error: No recordings found."
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: lastRecording)
            audioPlayer?.play()
            statusLabel.text = "Status: Playing recording..."
            print("Playing recording...")
        } catch {
            print("Failed to play recording: \(error)")
            statusLabel.text = "Error: Could not play recording"
        }
    }

    // Helper function to get the documents directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]  // Return the first path (the documents directory)
    }
}

