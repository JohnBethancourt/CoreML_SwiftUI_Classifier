//
//  ObjectClassifierModel.swift
//  ObjectClassifier
//
//  Created by John Bethancourt on 10/2/21.
//

import CoreML
import SwiftUI
import Vision

class ObjectClassifierModel: ObservableObject {
    @Published var resultText = ""
    var visionMLRequest: VNCoreMLRequest?
    
    init() {
        visionMLRequest = createVisionMLRequest()
    }
    
    // MARK: - Methods
    func createVisionMLRequest() -> VNCoreMLRequest {
        let config = MLModelConfiguration()
        guard let mlModel = try? Resnet50(configuration: config).model else {
            fatalError("Couldn't load ML model")
        }
        guard let model = try? VNCoreMLModel(for: mlModel) else {
            fatalError("can't load the Vision Container ML model")
        }
        
        // Create a Vision request with completion handler
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    self.resultText = "Unable to classify image."
                }
            } else {
                guard let classifications = request.results as? [VNClassificationObservation] else {
                    self.resultText = "Unable to classify image."
                    return
                }
                self.handleClassifications(classifications)
            }
        }
        request.imageCropAndScaleOption = .centerCrop
        return request
    }
    
    func handleClassifications(_ classifications: [ClassificationObservation]) {
        DispatchQueue.main.async {
            var resultString = ""
            for (index, result) in classifications.prefix(5).enumerated() {
                let confidence = String(format: "Confidence %.2f", result.confidence * 100)
                resultString += "\(index + 1). \(result.identifier) - \(confidence)%\n"
            }
            self.resultText = resultString
        }
    }
    
    func classifyImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("CI Image creation failed.")
            DispatchQueue.main.async {
                self.resultText = "Unable to load image."
            }
            return
        }
        
        guard let visionMLRequest = self.visionMLRequest else {
            print("visionMLRequest not initialized.")
            return
        }
        
        resultText = "Classifying image..."
        
        // Run the Core ML Resnet50 classifier on global dispatch queue
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([visionMLRequest])
            } catch {
                print("Unable to handle vision request. \(error)")
            }
        }
    }
}
