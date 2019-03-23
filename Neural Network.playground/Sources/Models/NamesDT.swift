//
// NamesDT.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML

public struct ClassificationResult {
    public enum Gender: String {
        case male = "M"
        case female = "F"
        
        public var string: String {
            switch self {
            case .male:
                return "Male"
            case .female:
                return "Female"
            }
        }
    }
    
    public let gender: Gender
    public let probability: Double
}

public final class NameClassificationService {
    
    public init() {}
    
    public enum Error: Swift.Error {
        case unknownGender
        case probabilityMissing(gender: ClassificationResult.Gender)
    }
    
    private let model = NamesDT()
    
    // MARK: - Prediction
    public func predictGender(from firstName: String) throws -> ClassificationResult {
        let output = try? model.prediction(input: features(from: firstName))
        
        guard let gender = ClassificationResult.Gender(rawValue: output!.classLabel) else {
            throw Error.unknownGender
        }
        
        guard let probability = output!.classProbability[output!.classLabel] else {
            throw Error.probabilityMissing(gender: gender)
        }
        
        return ClassificationResult(gender: gender, probability: probability)
    }
}

// MARK: - Features
private extension NameClassificationService {
    func features(from string: String) -> [String: Double] {
        guard !string.isEmpty else {
            return [:]
        }
        
        let string = string.lowercased()
        var keys = [String]()
        
        keys.append("first-letter=\(string.prefix(1))")
        keys.append("first2-letters=\(string.prefix(2))")
        keys.append("first3-letters=\(string.prefix(3))")
        keys.append("last-letter=\(string.suffix(1))")
        keys.append("last2-letters=\(string.suffix(2))")
        keys.append("last3-letters=\(string.suffix(3))")
        
        return keys.reduce([String: Double]()) { (result, key) -> [String: Double] in
            var result = result
            result[key] = 1.0
            return result
        }
    }
}

/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class NamesDTInput : MLFeatureProvider {
    
    /// Features extracted from the first name. as dictionary of strings to doubles
    var input: [String : Double]
    
    var featureNames: Set<String> {
        get {
            return ["input"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "input") {
            return try! MLFeatureValue(dictionary: input as [NSObject : NSNumber])
        }
        return nil
    }
    
    init(input: [String : Double]) {
        self.input = input
    }
}

/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class NamesDTOutput : MLFeatureProvider {
    
    /// Source provided by CoreML
    
    private let provider : MLFeatureProvider
    
    
    /// The most likely gender, for the given input. (F|M) as string value
    lazy var classLabel: String = {
        [unowned self] in return self.provider.featureValue(for: "classLabel")!.stringValue
        }()
    
    /// The probabilities for each gender, for the given input. as dictionary of strings to doubles
    lazy var classProbability: [String : Double] = {
        [unowned self] in return self.provider.featureValue(for: "classProbability")!.dictionaryValue as! [String : Double]
        }()
    
    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }
    
    init(classLabel: String, classProbability: [String : Double]) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["classLabel" : MLFeatureValue(string: classLabel), "classProbability" : MLFeatureValue(dictionary: classProbability as [AnyHashable : NSNumber])])
    }
    
    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class NamesDT {
    public var model: MLModel
    
    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: NamesDT.self)
        return bundle.url(forResource: "NamesDT", withExtension:"mlmodelc")!
    }
    
    /**
     Construct a model with explicit path to mlmodelc file
     - parameters:
     - url: the file url of the model
     - throws: an NSError object that describes the problem
     */
    init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }
    
    /// Construct a model that automatically loads the model from the app's bundle
    public convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }
    
    /**
     Construct a model with configuration
     - parameters:
     - configuration: the desired model configuration
     - throws: an NSError object that describes the problem
     */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }
    
    /**
     Construct a model with explicit path to mlmodelc file and configuration
     - parameters:
     - url: the file url of the model
     - configuration: the desired model configuration
     - throws: an NSError object that describes the problem
     */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    init(contentsOf url: URL, configuration: MLModelConfiguration) throws {
        self.model = try MLModel(contentsOf: url, configuration: configuration)
    }
    
    /**
     Make a prediction using the structured interface
     - parameters:
     - input: the input to the prediction as NamesDTInput
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as NamesDTOutput
     */
    func prediction(input: NamesDTInput) throws -> NamesDTOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }
    
    /**
     Make a prediction using the structured interface
     - parameters:
     - input: the input to the prediction as NamesDTInput
     - options: prediction options
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as NamesDTOutput
     */
    func prediction(input: NamesDTInput, options: MLPredictionOptions) throws -> NamesDTOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return NamesDTOutput(features: outFeatures)
    }
    
    /**
     Make a prediction using the convenience interface
     - parameters:
     - input: Features extracted from the first name. as dictionary of strings to doubles
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as NamesDTOutput
     */
    func prediction(input: [String : Double]) throws -> NamesDTOutput {
        let input_ = NamesDTInput(input: input)
        return try self.prediction(input: input_)
    }
    
    /**
     Make a batch prediction using the structured interface
     - parameters:
     - inputs: the inputs to the prediction as [NamesDTInput]
     - options: prediction options
     - throws: an NSError object that describes the problem
     - returns: the result of the prediction as [NamesDTOutput]
     */
    @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    func predictions(inputs: [NamesDTInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [NamesDTOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [NamesDTOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  NamesDTOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
