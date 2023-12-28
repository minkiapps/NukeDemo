// The MIT License (MIT)
//
// Copyright (c) 2015-2023 Alexander Grebenyuk (github.com/kean).

import UIKit
import Nuke
import SwiftSVG
import SVGKit

final class SwiftSVGDemoViewController: UIViewController {
    
    let urls = [
        "https://preview-assets-ch-itw.kc-usercontent.com:443/657e7b5a-00ee-3f9b-45d4-67449fdc0e72/ee6d5e29-555d-4edb-a900-343bd3abd533/iw-footer-qualitylabel-play-fair-code-colour.svg",
        "https://preview-assets-ch-itw.kc-usercontent.com:443/657e7b5a-00ee-3f9b-45d4-67449fdc0e72/52afd871-769d-47de-8506-1c653ec43ef0/iw-footer-qualitylabel-mga-lizenz-colour.svg",
        "https://preview-assets-ch-itw.kc-usercontent.com:443/657e7b5a-00ee-3f9b-45d4-67449fdc0e72/7b427c67-35c4-4915-9aae-efc266251b31/iw-footer-qualitylabel-18plus-colour.svg",
        "https://preview-assets-ch-itw.kc-usercontent.com:443/657e7b5a-00ee-3f9b-45d4-67449fdc0e72/183d1a1e-6b30-43c8-bc32-9cfe3b7984d4/iw-footer-qualitylabel-ibia-colour.svg",
        "https://preview-assets-ch-itw.kc-usercontent.com:443/657e7b5a-00ee-3f9b-45d4-67449fdc0e72/c9437f3d-8d0e-4bad-a7d2-2be0bbea08ff/iw-footer-qualitylabel-gambling-therapy-colour.svg",
        "https://preview-assets-ch-itw.kc-usercontent.com:443/657e7b5a-00ee-3f9b-45d4-67449fdc0e72/f237af7e-45c9-4be0-a2b5-60b612fa7b45/iw-footer-qualitylabel-thawte-colour.svg"]
    
    let paymentIndicies = [1,2,10,11,13,15,16,21,28,20,23,30,38,43,66,86,95,96]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupScrollView()

        ImageDecoderRegistry.shared.register { context in
            // Replace this with whatever works for. There are no magic numbers
            // for SVG like are used for other binary formats, it's just XML.
            let isSVG = context.urlResponse?.url?.absoluteString.hasSuffix(".svg") ?? false
            return isSVG ? ImageDecoders.Empty() : nil
        }
        
        loadSVGsWithSVGKit()
    }
    
    private func loadSVGsWithSVGKit() {
        paymentIndicies.enumerated().forEach(
            { (index, item) in
                let url = URL(string:"https://appapi.interwetten.com/de/payment/icon/\(item).svg")!
                DispatchQueue.global(qos: .background).async {
                    let image = SVGKImage(contentsOf:url)
                    DispatchQueue.main.async {
                        let svgView = SVGKFastImageView(svgkImage: image)!
                        svgView.widthAnchor.constraint(equalToConstant: 50).isActive = true
                        svgView.heightAnchor.constraint(equalToConstant: 50).isActive = true
                        self.scrollStackViewContainer.addArrangedSubview(svgView)
                    }
                }
            }
        )
    }
    
    private func loadWithSwiftSVG() {
        paymentIndicies.enumerated().forEach(
            { (index, item) in
                print(index, item)
                let url = URL(string: "https://appapi.interwetten.com/de/payment/icon/\(item).svg")!
                ImagePipeline.shared.loadImage(with: url) { [weak self] result in
                    guard let self = self, let data = try? result.get().container.data else {
                        return
                    }

                    // You can render image using whatever size you want, vector!
                    let targetBounds = CGRect(origin: .zero, size: CGSize(width: 150, height: 150))
                    let svgView = UIView(SVGData: data) { layer in
                        layer.resizeToFit(targetBounds)
                    }
                    
                    //svgView.backgroundColor = randomUIColor()
                    
                    svgView.widthAnchor.constraint(equalToConstant: 150).isActive = true
                    svgView.heightAnchor.constraint(equalToConstant: 150).isActive = true
                    scrollStackViewContainer.addArrangedSubview(svgView)
                }
            }
        )
    }
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scrollStackViewContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 30
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = UIStackView.Alignment.center;
        return view
    }()
    
    private func setupScrollView() {
        let margins = view.layoutMarginsGuide
        view.addSubview(scrollView)
        scrollView.addSubview(scrollStackViewContainer)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        scrollStackViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        scrollStackViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        scrollStackViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        scrollStackViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        scrollStackViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    func randomUIColor() -> UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
