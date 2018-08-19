//
//  ViewController.swift
//  CamDetect
//
//  Created by Justin Hsu on 8/18/18.
//  Copyright © 2018 Justin Hsu. All rights reserved.
//

import UIKit
import AVKit
import Vision
var linkObj = "Chair"
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
//    @IBOutlet weak var infoText: UILabel!
    
    @IBOutlet weak var infoText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let captureSesh = AVCaptureSession()
        captureSesh.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSesh.addInput(input)
        
        captureSesh.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSesh)
        previewLayer.frame = view.frame
        
        view.layer.addSublayer(previewLayer)

        infoText.layer.zPosition = 1
//        infoText.numberOfLines = 0
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSesh.addOutput(dataOutput)
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let urlBase = "https://en.wikipedia.org/wiki/"
        let urlSearchObj = linkObj
        let urlFinal = urlBase + urlSearchObj
        let url = URL(string: urlFinal)
        print(urlFinal)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error)
            }
            else {
                let htmlContent = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                var htmlContentString = htmlContent as! String
//                print(htmlContentString)
                
                //after line 29 div
                //starting after next paragraph start tag
                
                //or just find the find the first <p></p>
                
                let htmlMax = htmlContentString.count
                var count = 0
                
                var foundStart = false
                var foundDeleteStart = false
                var foundDeleteStartClose = false
                
                var deleteStart = htmlContentString.startIndex
                var deleteEnd = htmlContentString.startIndex
                var deleteStartClose = htmlContentString.startIndex
                var deleteEndClose = htmlContentString.startIndex
                
                var deleteRange = deleteStart..<deleteEnd
                var deleteRangeClose = deleteStartClose..<deleteEndClose
                
                var startInd = htmlContentString.startIndex
                var endInd = htmlContentString.endIndex
                var Ind = htmlContentString.startIndex;
                
                while (count < htmlMax) {
                    if (htmlContentString[Ind] == "p") {
                        //find start of text
                        if (htmlContentString[htmlContentString.index(after: Ind)] == ">"
                            &&  htmlContentString[htmlContentString.index(before: Ind)] == "<") {
                            startInd = htmlContentString.index(after: htmlContentString.index(after: Ind))
                            foundStart = true
                        }
                        //find end of text
                        if (htmlContentString[htmlContentString.index(after: Ind)] == ">"
                            &&  htmlContentString[htmlContentString.index(before: Ind)] == "/"
                            &&  foundStart == true) {
                            
                            endInd = htmlContentString.index(before: htmlContentString.index(before: Ind))
                            //break out of loop
                            break
                        }
                        
                    }
                    //remove hyperlinks
                    if (htmlContentString[Ind] == "a") {
                        //find start tag
                        if (htmlContentString[htmlContentString.index(before: Ind)] == "<") {
                            foundDeleteStart = true
                            deleteStart = htmlContentString.index(before: Ind)
                        }
                        if (htmlContentString[htmlContentString.index(after: Ind)] == ">"
                            && htmlContentString[htmlContentString.index(before: Ind)] == "/") {
                            foundDeleteStart = true
                            deleteStart = htmlContentString.index(before: htmlContentString.index(before: Ind))
                        }
                    }
                    if (htmlContentString[Ind] == "s") {
                        if (htmlContentString[htmlContentString.index(before: Ind)] == "<"
                            && htmlContentString[htmlContentString.index(after: Ind)] == "u") {
                            foundDeleteStart = true
                            deleteStart = htmlContentString.index(before: Ind)
                        }
                    }
                    if (htmlContentString[Ind] == "b") {
                        if (htmlContentString[htmlContentString.index(before: Ind)] == "<"
                            && htmlContentString[htmlContentString.index(after: Ind)] == ">") {
                            foundDeleteStart = true
                            deleteStart = htmlContentString.index(before: Ind)
                        }
                    }
                    if (htmlContentString[Ind] == "i") {
                        if (htmlContentString[htmlContentString.index(before: Ind)] == "<"
                            && htmlContentString[htmlContentString.index(after: Ind)] == ">") {
                            foundDeleteStart = true
                            deleteStart = htmlContentString.index(before: Ind)
                        }
                    }
                    if (htmlContentString[Ind] == "/"
                        && htmlContentString[htmlContentString.index(before: Ind)] == "<"
                        && (htmlContentString[htmlContentString.index(after: Ind)] == "a"
                            ||  htmlContentString[htmlContentString.index(after: Ind)] == "b"
                            ||  htmlContentString[htmlContentString.index(after: Ind)] == "i"
                            ||  htmlContentString[htmlContentString.index(after: Ind)] == "s")) {
                        foundDeleteStartClose = true
                        deleteStartClose = htmlContentString.index(before: Ind)
                    }
                    
                    //generic delete for end of any special start tag (i.e. <a>)
                    if (htmlContentString[Ind] == ">"
                        && foundDeleteStart == true) {
                        foundDeleteStart = false
                        deleteEnd = htmlContentString.index(after: Ind)
                        deleteRange = deleteStart..<deleteEnd
                        Ind = htmlContentString.index(before: deleteStart)
                        htmlContentString.replaceSubrange(deleteRange, with: "")
//                        print(htmlContentString[deleteRange])
                    }
                    //generic delete for end of any special end tag (i.e. </a>)
                    if (htmlContentString[Ind] == ">"
                        && foundDeleteStartClose == true) {
                        foundDeleteStartClose = false
                        deleteEndClose = htmlContentString.index(after: Ind)
                        deleteRangeClose = deleteStartClose..<deleteEndClose
//                        print(htmlContentString[deleteRangeClose])
                        Ind = htmlContentString.index(before: deleteStartClose)
                        htmlContentString.replaceSubrange(deleteRangeClose, with: "")
                    }
                    
                   
                    Ind = htmlContentString.index(after: Ind)
                    count += 1
                }
                let range = startInd..<endInd
                let result = htmlContentString[range]
                print(result)
                DispatchQueue.main.async {
                    self.infoText.text = String(result)
//                    self.infoText.sizeToFit()
                }
                
                
            }
        }
        task.resume()
    }
    
    
    
    func buttonClicked(button: UIButton) {
        switch button.tag {
        case 1:
            print("TOUCHED")
            break
            
        default: ()
            break
        }
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            //check error TODO
            
//            print(finishedReq.results)
            
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObs = results.first else { return }
            DispatchQueue.main.async {
            }
//            print(firstObs.identifier)
            var objRaw = String(firstObs.identifier)
            if (objRaw.contains(" ")) {
                if let first = objRaw.components(separatedBy: " ").first {
                    // Do something with the first component.
                    objRaw = first
                }
                if (!objRaw.isEmpty) {
                    if (objRaw[objRaw.index(before: objRaw.endIndex)] == ",") {
                        objRaw = String(objRaw.dropLast())
                    }
                }
            }
            
            
            
            linkObj = objRaw
        }

        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

