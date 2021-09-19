//
//  NewsTableViewCell.swift
//  SurfTask
//
//  Created by Артём Калинин on 15.09.2021.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    let headlineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()

    var thumbnail: URL? {
        willSet {
            guard let URL = newValue else { return }

            DispatchQueue.global(qos: .utility).async {
                if let data = try? Data(contentsOf: URL) {

                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.thumbnailImageView.image = UIImage(data: data)
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.thumbnailImageView.image = UIImage(named: "theguardian.png")
                    }
                }
            }
        }
    }

    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(thumbnailImageView)
        addSubview(headlineLabel)

        setImageViewConstraints()
        setLabelConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        headlineLabel.text = ""
        thumbnailImageView.image = UIImage(named: "theguardian.png")
    }

    func setImageViewConstraints() {
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor,
                                                  multiplier: 16/9).isActive = true
    }

    func setLabelConstraints() {
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        headlineLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 15).isActive = true
        headlineLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        headlineLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
    }
}
