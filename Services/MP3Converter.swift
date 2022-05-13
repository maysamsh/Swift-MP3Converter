//
//  MP3Converter.swift
//  MP3Converter
//
//  Created by Maysam Shahsavari on 2022-05-12.
//

import Foundation
import Combine

final class MP3Converter {
    enum MP3ConverterError: Error, LocalizedError {
        case invalidSettings
        
        var errorDescription: String? {
            switch self {
            case .invalidSettings:
                return "The settings are not correct for output."
            }
        }
    }
    
    
    func convert(input: URL, output: URL) -> AnyPublisher<URL, Error> {
        let converter = ExtAudioConverter()
        converter.inputFile = input.path
        converter.outputFile = output.path
        converter.outputFileType = kAudioFileMP3Type
        /// To convert to MP3 you should set the outputFormatID to kAudioFormatMPEGLayer3, the default value will fail. 
        converter.outputFormatID = kAudioFormatMPEGLayer3
        let result = converter.convert()
        if result {
            return Just(output)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: MP3ConverterError.invalidSettings)
                .eraseToAnyPublisher()
        }
    }
}
